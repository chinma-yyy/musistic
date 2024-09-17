import { Types } from "mongoose";
import mongoose from "mongoose";

export interface IConversation {
	_id: Types.ObjectId;
	lastMessage: string;
	participants: Array<Types.ObjectId>;
	messages: Array<Types.ObjectId>;
	group: IGroup;
	seen: boolean;
	by: Types.ObjectId;
}

interface IGroup {
	name: string;
	description: string;
	createdBy: mongoose.Schema.Types.ObjectId;
}
