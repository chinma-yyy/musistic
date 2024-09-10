import express from "express";
import {
	followUser,
	getMe,
	unfollow,
	updateUser,
	usernameUnique,
} from "../controllers/users";
import { isAuth } from "../middlewares/auth";
import { getAllNotifications, getUnseenNotifications } from "../services/notifications";

const userRouter = express.Router();

userRouter.get("/notifications/all", isAuth, getAllNotifications);

userRouter.get("/notifications/unseen", isAuth, getUnseenNotifications);

userRouter.get("/follow", isAuth, followUser);

userRouter.get("/unfollow", isAuth, unfollow);

userRouter.get("/me", isAuth, getMe);

userRouter.get("/username", usernameUnique);

userRouter.post("/update", isAuth, updateUser);

export default userRouter;
