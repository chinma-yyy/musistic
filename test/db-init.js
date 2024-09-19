// Import necessary modules
const { MongoClient } = require("mongodb");
const fs = require("fs");
require("dotenv").config();

// MongoDB connection URL from .env
const url = process.env.MONGO_URL;

// Database name
const dbName = "rewind-test";
let dummyData;

// Function to read JSON file and parse dummy data
fs.readFile("dummy-database.json", "utf8", (err, data) => {
  if (err) {
    console.error("Error reading JSON file:", err);
    return;
  }

  try {
    dummyData = JSON.parse(data);  // Parse JSON data
  } catch (error) {
    console.error("Error parsing JSON:", error);
  }
});

// Function to connect to MongoDB, drop the database if it exists, and insert dummy data
async function insertData() {
  try {
    console.log("Connecting to MongoDB server...");

    // Connect to MongoDB
    const client = await MongoClient.connect(url);
    console.log("Connected successfully to server.");

    const db = client.db(dbName);

    // Drop the database if it exists
    const adminDb = client.db().admin();
    const dbList = await adminDb.listDatabases();

    // Check if the database exists and drop it
    if (dbList.databases.some(db => db.name === dbName)) {
      await db.dropDatabase();
      console.log(`Database "${dbName}" dropped successfully.`);
    }

    // Insert user data
    const userCollection = db.collection("users");
    await userCollection.insertOne(dummyData.users.user1);
    await userCollection.insertOne(dummyData.users.user2);
    console.log("Users data inserted successfully.");

    // Insert post data
    const postCollection = db.collection("posts");
    await postCollection.insertOne(dummyData.posts.post1);
    await postCollection.insertOne(dummyData.posts.post2);
    console.log("Posts data inserted successfully.");

    // Close the connection
    await client.close();
    console.log("Connection closed.");
  } catch (error) {
    console.error("Error inserting data:", error);
  }
}

// Run the insertData function
insertData();
