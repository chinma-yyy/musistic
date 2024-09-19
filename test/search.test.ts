import { describe, test } from "@jest/globals";
/**
 * search song ka pata nahi
 */
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

describe("For searching", () => {
	test("should global search users and posts", async () => {
		await sleep(1000);
	});
	test("should search user", async () => {
		await sleep(1000);
	});
	test("should search song over soptify API", async () => {
		await sleep(1000);
	});
});
