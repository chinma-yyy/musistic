import express from "express";
import mongoose from "mongoose";
import { Request, Response, NextFunction } from "express";
import cors from "cors";
import { IError } from "./types/basic/IError";
import spotifyRouter from "./routes/spotifyRoutes";
import postRouter from "./routes/postRouter";
import convoRouter from "./routes/conversationRoutes";
import userRouter from "./routes/userRoutes";
import http from "http";
import { config } from "dotenv";
import searchRouter from "./routes/searchRoutes";
import morgan from "morgan";

config({ debug: false });

const app = express();
const port = process.env.SERVER_PORT || 5000;

app.use(morgan("short"));

app.set("trust proxy", true);
// Serve static media folder
app.use("/media", express.static("media"));

//Use body-parser
app.use(express.json());

// Configure CORS
const origin = process.env.FRONTEND_ORIGIN;
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

const server = http.createServer(app);

const mongoUrl =
	process.env.NODE_ENV == "test"
		? process.env.MONGO_URL + "rewind-test"
		: process.env.MONGO_URL;

server.listen(port, async () => {
	console.log("Server started on port " + port);
	console.log(mongoUrl);
	mongoose
		.connect(mongoUrl!)
		.then(() => {
			console.log("Connected to mongo db");
		})
		.catch((err: Error) =>
			console.log("Couldn't connect to mongodb :" + err),
		);
});

export default app;
