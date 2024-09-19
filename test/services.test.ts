import { describe, test } from "@jest/globals";
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

describe("For notifications", () => {
	test("should send a notification", async () => {
		await sleep(1000);
	});
	test("should update that the notifications has been seen by the user", async () => {
		await sleep(1000);
	});
	test("should fetch all notifications for user", async () => {
		await sleep(1000);
	});
});

describe("For AI server", () => {
	test("should set tagline of the user", () => {});
});
