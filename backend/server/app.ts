import express from "express";
import mongoose from "mongoose";
import { Request, Response, NextFunction } from "express";
import cors from "cors";
import { IError } from "./types/basic/IError";
import spotifyRouter from "./routes/spotifyRoutes";
import postRouter from "./routes/postRouter";
import { isAuth, testToken } from "./middlewares/auth";
// import { Server } from "socket.io";
import convoRouter from "./routes/conversationRoutes";
import userRouter from "./routes/userRoutes";
import http from "http";
import { config } from "dotenv";
import searchRouter from "./routes/searchRoutes";
// import { ioConfig } from "./sockets/ioconfig";
import morgan from "morgan";
// import { createAdapter } from "@socket.io/mongo-adapter";
// import cron from "node-cron";
config();

const app = express();
const port = process.env.SERVER_PORT || 3000;
const env = process.env.NODE_ENV;

app.use(morgan("short"));

// Serve static media folder
app.use("/media", express.static("media"));
//Use body-parser
app.use(express.json());
const origin = process.env.FRONTEND_ORIGIN;
// Configure CORS
const corsOptions = {
	origin, // Allow requests from this domain
	methods: "GET,HEAD,PUT,PATCH,POST,DELETE", // Allowed HTTP methods
	credentials: true, // Allow cookies and other credentials
	optionsSuccessStatus: 200, // For legacy browsers
};

// Apply CORS middleware
app.use(cors(corsOptions));

//test route
app.use("/test", async (req, res, next) => {
	try {
		res.status(200).json({ message: "Recieved" });
	} catch (e) {
		res.status(200).json({ message: "Error" });
	}
});

// Call to get token and check auth
app.get("/ping", isAuth);
app.post("/ping", testToken);

// Post routes
app.use("/posts", postRouter);

// User routes
app.use("/user", userRouter);

//Conversation routes
app.use("/conversation", convoRouter);

//Spotify routes
app.use("/spotify", spotifyRouter);

// Search routes
app.use("/search", searchRouter);

// Error handling
app.use((error: IError, req: Request, res: Response, next: NextFunction) => {
	if (error.location) {
		console.error(location);
	}
	console.log(error);
	res.status(error.code || 500).json({ message: error.text });
});

// Start the server
const server = http.createServer(app);
// const io = new Server(server, {
// 	path: "",
// 	cors: {
// 		origin: "*",
// 		methods: ["GET", "POST", "DELETE", "PATCH", "PUT"],
// 		allowedHeaders: ["Authorization"],
// 	},
// 	cleanupEmptyChildNamespaces: true,
// 	transports: ["websocket"],
// });

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

// ioConfig(io);

export default app;
