import { RequestHandler } from "express";
import { getIoInstance, getUserSocketIdFromRedis } from "./ioConfig";

export const notificationController: RequestHandler = async (
	req,
	res,
	next,
) => {
	try {
		const recipient = req.query.recipient as string;
		const io = getIoInstance();
		const socketId = await getUserSocketIdFromRedis(recipient);
		if (!socketId) {
			console.log("no socket");
			res.status(200).json({ mess: "none" });
			return;
		}
		io.to(socketId).emit("notif");
		res.status(200).json({ message: "done" });
	} catch (error) {
		console.log(error);
	}
};
