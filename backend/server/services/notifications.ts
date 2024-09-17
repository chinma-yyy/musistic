import { Types } from "mongoose";
import notificationModel from "../models/notificationSchema";
import { NotificationTypes } from "../enums/notificationEnums";
import client from "../redis";
import { Authenticated } from "../types/declarations/jwt";
import { RequestHandler } from "express";
import axios from "axios";
const socketServerURL = process.env.SOCKET_SERVER_URL;
/**
 *
 * @param recipient person receiving notif
 * @param sender person sending notif
 * @param type type of notif
 * @param post postId of the
 * @returns boolean
 */
export const sendNotification = async (
	recipient: any,
	sender: any,
	type: string,
	postId?: Types.ObjectId,
) => {
	if (sender == recipient) {
		return false;
	}
	let alreadyNotified: boolean;
	if (
		type == NotificationTypes.comment ||
		NotificationTypes.dedicate ||
		NotificationTypes.like ||
		NotificationTypes.reshare
	) {
		alreadyNotified = await notificationModel
			.find({ sender, type, post: postId })
			.then((notifs) => {
				if (notifs.length == 0) {
					return false;
				}
				return true;
			})
			.catch((err) => {
				console.log(err);
				return false;
			});
	} else {
		alreadyNotified = await notificationModel
			.find({ sender, type })
			.then((notifs) => {
				if (notifs.length == 0) {
					return false;
				}
				return true;
			})
			.catch((err) => {
				return false;
			});
	}
	if (alreadyNotified) {
		return false;
	}
	try {
		const notification = new notificationModel({
			sender,
			recipient,
			type,
			post: postId,
		});
		await notification.save();
		const populatedNotification =
			await notification.populate("sender recipient");

		const notificationKey = `notification:unseen:${recipient}`;
		const notificationData = populatedNotification.toObject();

		// Store the populated notification data in Redis
		await client.lPush(notificationKey, JSON.stringify(notificationData));
		axios.get(`${socketServerURL}/notification?recipient=${recipient}`);
		return true;
	} catch (err) {
		console.log(err);
		return false;
	}
};

/**
 *
 * @param userId get all seen and unseen notifs
 * {
 * 		notifications:{}
 * }
 * @returns
 */
export const getAllNotifications: RequestHandler = async (
	req: Authenticated,
	res,
	next,
) => {
	try {
		const userId = req.user!.id as string;
		const notifications = await notificationModel
			.find({
				recipient: userId,
			})
			.populate("sender recipient");

		res.status(200).json({ notifications });
	} catch (err) {
		next(err);
	}
};

export const getUnseenNotifications: RequestHandler = async (
	req: Authenticated,
	res,
	next,
) => {
	try {
		const userId = req?.user!.id as string;
		const notificationKey = `notification:unseen:${userId}`;
		const notifications = await client.LRANGE(notificationKey, 0, -1);
		await client.del(notificationKey);

		const notificationsObjectArray = notifications
			.map((notif) => {
				try {
					return JSON.parse(notif);
				} catch (error) {
					console.error(
						"Failed to parse notification:",
						notif,
						error,
					);
					return null;
				}
			})
			.filter((notif) => notif !== null);

		res.status(200).json({ notifications: notificationsObjectArray });
	} catch (err) {
		console.log(err);
		next(err);
	}
};
