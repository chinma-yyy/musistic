import { createClient } from "redis";
import { config } from "dotenv";

config();

const host = process.env.REDIS_HOST!;
const redisPort = process.env.REDIS_PORT;
const port = redisPort ? parseInt(redisPort, 10) : 6379;
const tls = process.env.REDIS_TLS == "true";

const client = createClient({
	socket: {
		host,
		port,
		tls,
	},
});

client.on("error", (err) => console.log("Redis Client Error", err));

// client.connect().then(() => {
// 	console.log("Connected to redis client");
// });

export default client;
