// Import necessary modules
const { MongoClient } = require("mongodb");
require("dotenv").config();

// MongoDB connection URL from .env
const url = process.env.MONGO_URL;

// Database name
const dbName = "rewind-test";

// Function to delete the database
async function deleteDatabase() {
  try {
    console.log("Connecting to MongoDB server...");

    // Connect to MongoDB
    const client = await MongoClient.connect(url);
    console.log("Connected successfully to server.");

    const db = client.db(dbName);

    // Drop the database
    await db.dropDatabase();
    console.log(`Database "${dbName}" dropped successfully.`);

    // Close the connection
    await client.close();
    console.log("Connection closed.");
  } catch (error) {
    console.error("Error deleting database:", error);
  }
}

// Run the deleteDatabase function
deleteDatabase();
