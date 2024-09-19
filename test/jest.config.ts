import type { Config } from "@jest/types";
import dotenv from "dotenv";

// Load environment variables from .env file
dotenv.config();
const config: Config.InitialOptions = {
	setupFiles: ["<rootDir>/jest.setup.ts"],
	coverageReporters: ["text"],
	transform: {
		"^.+\\.(t|j)sx?$": "@swc/jest",
	},
	roots: ["<rootDir>"],
	testRegex: "(/__tests__/.*|(\\.|/)(test|spec))\\.[jt]sx?$",
	moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
	testTimeout: 100000,
	//   setupFiles: ['./test/jest.setup.ts'],
	collectCoverageFrom: ["backend/dist/**"],
	maxWorkers: 1,
};

export default config;
