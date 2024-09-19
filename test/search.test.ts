import { describe, test, beforeAll, expect } from "@jest/globals";
import axios from "axios";
import { generateToken } from "../backend/server/middlewares/auth";
import fs from "fs/promises";
/**
 * search song ka pata nahi
 */
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));
let dbjson: any;
describe("For searching", () => {
	let authToken: string;
	let Headers: object;
	const baseUrl: string = "http://localhost:3000/search";
	beforeAll(async () => {
		authToken = generateToken("643d37740bebbc75840aaa1a", "chinma_yyy");
		Headers = {
			headers: {
				Authorization: `Bearer ${authToken}`,
			},
		};
		try {
			const data = await fs.readFile("dummy-database.json", "utf-8"); // Await file read
			dbjson = JSON.parse(data); // Parse and assign to dbjson
		} catch (err) {
			console.error("Error reading JSON file:", err);
		}
	});
	test("should global search users and posts", async () => {
		await sleep(1000);
		const search = await axios.get(
			`${baseUrl}/global?text=chinmay`,
			Headers,
		);
		expect(search.data).toHaveProperty(["users"]);
		expect(search.status).toBe(200);
	});
	test("should search user", async () => {
		await sleep(1000);
		const me = await axios.get(
			`${baseUrl}/user?username=chinma_yyy`,
			Headers,
		);
		// Use toHaveProperty to check for each property at the root level
		expect(me.data).toHaveProperty("_id");
		expect(me.data).toHaveProperty("username");
		expect(me.data).toHaveProperty("name");
		expect(me.data).toHaveProperty("bio");
		expect(me.data).toHaveProperty("email");
		expect(me.data).toHaveProperty("profileUrl");
		expect(me.data).toHaveProperty("followerCount");
		expect(me.data).toHaveProperty("followingCount");
		expect(me.data).toHaveProperty("postCount");
		expect(me.data).toHaveProperty("country");
		expect(me.data).toHaveProperty("status");
		expect(me.data).toHaveProperty("private");
		expect(me.data).toHaveProperty("artist");
		// Validate specific property values against dbjson users data
		expect(me.data._id).toEqual(dbjson.users.user2._id);
		expect(me.data.name).toEqual(dbjson.users.user2.name);
		expect(me.data.username).toEqual(dbjson.users.user2.username);
		expect(me.data.country).toEqual(dbjson.users.user2.country);
		expect(me.data.status).toEqual(dbjson.users.user2.status);
		expect(me.data.email).toEqual(dbjson.users.user2.email);
		expect(me.data.profileUrl).toEqual(dbjson.users.user2.profileUrl);
		expect(me.data.private).toEqual(dbjson.users.user2.private);
		expect(me.data.artist).toEqual(dbjson.users.user2.artist);
		expect(me.data.bio).toEqual(dbjson.users.user2.bio);
	});

	test("should search user", async () => {
		await sleep(1000);
		const me = await axios.get(
			`${baseUrl}/user?email=shewalechinmay54@gmail.com`,
			Headers,
		);
		// Use toHaveProperty to check for each property at the root level
		expect(me.data).toHaveProperty("_id");
		expect(me.data).toHaveProperty("username");
		expect(me.data).toHaveProperty("name");
		expect(me.data).toHaveProperty("bio");
		expect(me.data).toHaveProperty("email");
		expect(me.data).toHaveProperty("profileUrl");
		expect(me.data).toHaveProperty("followerCount");
		expect(me.data).toHaveProperty("followingCount");
		expect(me.data).toHaveProperty("postCount");
		expect(me.data).toHaveProperty("country");
		expect(me.data).toHaveProperty("status");
		expect(me.data).toHaveProperty("private");
		expect(me.data).toHaveProperty("artist");
		// Validate specific property values against dbjson users data
		expect(me.data._id).toEqual(dbjson.users.user2._id);
		expect(me.data.name).toEqual(dbjson.users.user2.name);
		expect(me.data.username).toEqual(dbjson.users.user2.username);
		expect(me.data.country).toEqual(dbjson.users.user2.country);
		expect(me.data.status).toEqual(dbjson.users.user2.status);
		expect(me.data.email).toEqual(dbjson.users.user2.email);
		expect(me.data.profileUrl).toEqual(dbjson.users.user2.profileUrl);
		expect(me.data.private).toEqual(dbjson.users.user2.private);
		expect(me.data.artist).toEqual(dbjson.users.user2.artist);
		expect(me.data.bio).toEqual(dbjson.users.user2.bio);
	});

	test("should search song over soptify API", async () => {});
});
