import { Server, Socket } from "socket.io";
import { DefaultEventsMap } from "socket.io/dist/typed-events";
import { chatSocket } from "./conversation";
import jwt from "jsonwebtoken";
import client from "../redis";

// Helper functions to store/remove user in Redis
const storeUserInRedis = async (userId: string, socketId: string) => {
	try {
		await client.set(`redis:${userId}`, socketId);
	} catch (error) {
		console.log("Error storing user in redis");
	}
};

const removeUserFromRedis = async (userId: string) => {
	try {
		await client.del(`redis:${userId}`);
	} catch (error) {
		console.log("error removing the user from redis");
	}
};

export const getUserSocketIdFromRedis = async (
	userId: string,
): Promise<string | null> => {
	try {
		const socketId = await client.get(`redis:${userId}`);
		return socketId;
	} catch (err) {
		console.error(
			`Error retrieving socketId for user ${userId} from Redis:`,
			err,
		);
		return null; // Return null if there's an error
	}
};

// Variable to hold the io instance
let io: Server<DefaultEventsMap, DefaultEventsMap, DefaultEventsMap, any>;

// ioConfig function to initialize and configure Socket.IO
export const ioConfig = (
	ioInstance: Server<
		DefaultEventsMap,
		DefaultEventsMap,
		DefaultEventsMap,
		any
	>,
) => {
	io = ioInstance; // Store the io instance for later use in controllers

	io.on("connection", async (socket: Socket) => {
		console.log("connected to main room ", socket.id);
		const token = socket.handshake.query.token as string;
		try {
			const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
				id: string;
				type: string;
				_v: string;
			};
			const userId = decoded.id;
			await storeUserInRedis(userId, socket.id);
		} catch (err) {
			console.log(err);
		}
	});

	const chatRooms = io.of("/chat");
	chatRooms.on("connection", (socket: Socket) => {
		const token = socket.handshake.query.token as string;
		try {
			const decoded = jwt.verify(token!, process.env.JWT_SECRET!) as {
				id: string;
				type: string;
				_v: string;
			};
			chatSocket(socket, decoded.id, io);
		} catch (err) {
			console.log("Unauthorized");
		}
	});

	io.on("notification", async (event) => {
		const recipient = event.recipient;
		const socketId = await getUserSocketIdFromRedis(recipient);
		if (socketId) {
			// Emit the notification to the recipient's socket
			io.to(socketId).emit("notif");
		} else {
			console.log(`User ${recipient} is not connected`);
		}
	});
	io.on("disconnect", async (socket: Socket) => {
		const token = socket.handshake.query.token as string;
		try {
			const decoded = jwt.verify(token, process.env.JWT_SECRET!) as {
				id: string;
				type: string;
				_v: string;
			};
			const userId = decoded.id;
			await removeUserFromRedis(userId);
		} catch (err) {
			console.log(err);
		}
	});
};

// Function to retrieve the io instance
export const getIoInstance = () => {
	if (!io) {
		throw new Error("Socket.IO is not initialized");
	}
	return io;
};
