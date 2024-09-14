import globals from "globals";
import tsParser from "@typescript-eslint/parser"; // Import TypeScript parser

export default [
	{
		files: ["**/*.{ts,tsx}"], // Apply this config to TypeScript files
		languageOptions: {
			globals: globals.browser,
			parser: tsParser, // Use the TypeScript parser
		},
		rules: {
			"no-unreachable": "error", // Only check for unreachable code
		},
	},
];
