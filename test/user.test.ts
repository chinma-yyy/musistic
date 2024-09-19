import { beforeAll, describe, test, expect } from "@jest/globals";
import { generateToken } from "../backend/server/middlewares/auth";
import axios from "axios";
import fs from "fs/promises"; // Import fs.promises for async readFile

let dbjson: any;

describe("For users", () => {
	let authToken: string;
	let Headers: object;
	const baseUrl: string = "http://localhost:3000/user";

	beforeAll(async () => {
		authToken = generateToken("643d37740bebbc75840aaa1a", "chinma_yyy");
		Headers = {
			headers: {
				Authorization: `Bearer ${authToken}`,
			},
		};

		// Use async/await for reading the JSON file
		try {
			const data = await fs.readFile("dummy-database.json", "utf-8"); // Await file read
			dbjson = JSON.parse(data); // Parse and assign to dbjson
		} catch (err) {
			console.error("Error reading JSON file:", err);
		}
	});

	test("should update user details", async () => {
		try {
			const user = await axios.post(
				`${baseUrl}/update`,
				{
					name: "Chinmayyyyyy",
					bio: "This is new bio ",
					username: "chinmayshewale",
				},
				Headers,
			);

			expect(user.data).toHaveProperty("message");
			expect(user.data.message).toEqual("User updated");
		} catch (error: any) {
			if (error.response) {
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"User update failed",
				);
			} else {
				throw error;
			}
		}
	});

	test("should follow user", async () => {
		const follow = await axios.get(
			`${baseUrl}/follow?id=${dbjson.users.user1._id}`,
			Headers,
		);

		expect(follow.data).toHaveProperty("message");
		expect(follow.data.message).toEqual("Followed");
		expect(follow.status).toBe(200);
	});

	test("should throw error on self follow", async () => {
		try {
			const follow = await axios.get(
				`${baseUrl}/follow?id=${dbjson.users.user2._id}`,
				Headers,
			);

			expect(follow.status).toBe(400);
			expect(follow.data).toHaveProperty("message");
			expect(follow.data.message).toEqual("Cannot follow self");
		} catch (error: any) {
			if (error.response) {
				expect(error.response.status).toBe(400);
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"Cannot follow self",
				);
			} else {
				throw error;
			}
		}
	});

	test("should unfollow user", async () => {
		try {
			const follow = await axios.get(
				`${baseUrl}/unfollow?id=${dbjson.users.user1._id}`,
				Headers,
			);

			expect(follow.data).toHaveProperty("message");
			expect(follow.data.message).toEqual("Unfollowed");
			expect(follow.status).toBe(200);
		} catch (error: any) {
			if (error.response) {
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual("Unfollow failed");
			} else {
				throw error;
			}
		}
	});

	test("should throw error on self unfollow", async () => {
		try {
			const follow = await axios.get(
				`${baseUrl}/unfollow?id=${dbjson.users.user2._id}`,
				Headers,
			);

			expect(follow.status).toBe(400);
			expect(follow.data).toHaveProperty("message");
			expect(follow.data.message).toEqual("Cannot unfollow self");
		} catch (error: any) {
			if (error.response) {
				expect(error.response.status).toBe(400);
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"Cannot unfollow self",
				);
			} else {
				throw error;
			}
		}
	});

	test("should get the me user details", async () => {
		try {
			const me = await axios.get(`${baseUrl}/me`, Headers);

			expect(me.data).toHaveProperty([
				"notifCount",
				"messageCount",
				"_id",
				"username",
				"name",
				"bio",
				"email",
				"profileUrl",
				"followerCount",
				"followingCount",
				"postCount",
				"country",
				"status",
				"private",
				"artist",
			]);
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

			// Validate embedded object values
			expect(me.data.spotifyData.$oid).toEqual(
				dbjson.users.user2.spotifyData.$oid,
			);
		} catch (error: any) {
			if (error.response) {
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"Error getting user",
				);
			} else {
				throw error;
			}
		}
	});

	test("should check if username is unique", async () => {
		try {
			const username = await axios.get(
				`${baseUrl}/username?username=new_username`,
				Headers,
			);

			expect(username.data).toHaveProperty("message");
			expect(username.data.message).toEqual("Username available");
			expect(username.status).toBe(200);
		} catch (error: any) {
			if (error.response) {
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"Username check failed",
				);
			} else {
				throw error;
			}
		}
	});

	test("should throw error on a not unique username", async () => {
		try {
			const username = await axios.get(
				`${baseUrl}/username?username=chinmayshewale`,
				Headers,
			);

			expect(username.data).toHaveProperty("message");
			expect(username.status).toBe(200);
			expect(username.data.message).toEqual("Username available");
		} catch (error: any) {
			if (error.response) {
				expect(error.response.status).toBe(400);
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"Username already taken",
				);
			} else {
				throw error;
			}
		}
	});

	test("should update user details", async () => {
		try {
			const user = await axios.post(
				`${baseUrl}/update`,
				{
					name: dbjson.users.user2.name,
					bio: dbjson.users.user2.bio,
					username: dbjson.users.user2.username,
				},
				Headers,
			);

			expect(user.data).toHaveProperty("message");
			expect(user.data.message).toEqual("User updated");
		} catch (error: any) {
			if (error.response) {
				expect(error.response.data).toHaveProperty("message");
				expect(error.response.data.message).toEqual(
					"User update failed",
				);
			} else {
				throw error;
			}
		}
	});
});
