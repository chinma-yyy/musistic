import http from "http";
import { Server } from "socket.io";
import express from "express";
import { config } from "dotenv";
import mongoose from "mongoose";
import { ioConfig } from "./controllers/ioConfig";

config();

const app = express();
const port = process.env.SOCKET_PORT || 3001;
const env = process.env.NODE_ENV;

app.use(express.json());

app.use("/test", (req, res, next) => {
	console.log("Here");
	res.status(200).json({ message: "Recieved" });
});
const origin = process.env.FRONTEND_ORIGIN;

// Start the server
const server = http.createServer(app);
const io = new Server(server, {
	cors: {
		origin,
		methods: ["GET", "POST", "DELETE", "PATCH", "PUT"],
		allowedHeaders: ["Authorization"],
	},
	cleanupEmptyChildNamespaces: true,
	transports: ["websocket"],
});

const mongoUrl =
	env == "development"
		? process.env.MONGO_URL!
		: `mongodb://${process.env.MONGO_INITDB_ROOT_USERNAME}:${process.env.MONGO_INITDB_ROOT_PASSWORD}@mongo:27017/rewind-test?authSource=admin`;

server.listen(port, async () => {
	console.log("Server started on port " + port);
	mongoose
		.connect(mongoUrl)
		.then(() => {
			console.log("Connected to mongo db");
		})
		.catch((err: Error) =>
			console.log("Couldn't connect to mongodb :" + err),
		);
});

ioConfig(io);

export default app;
