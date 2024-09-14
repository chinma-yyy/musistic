import { RequestHandler } from "express";
import { IError } from "../types/basic/IError";
import multer from "multer";
import path from "path";
import AWS from "aws-sdk";
import { v4 as uuidv4 } from "uuid";

// Configure AWS SDK
const s3 = new AWS.S3({
	accessKeyId: process.env.AWS_ACCESS_KEY_ID, // Set your AWS access key
	secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY, // Set your AWS secret key
	region: process.env.AWS_REGION, // Set the region of your S3 bucket
});

// Use memory storage for multer
const storage = multer.memoryStorage();

const upload = multer({ storage: storage });

// S3 Upload function
const uploadToS3 = async (
	fileBuffer: Buffer,
	fileName: string,
	fileType: string,
) => {
	const params = {
		Bucket: process.env.AWS_S3_BUCKET_NAME!, // Your S3 bucket name
		Key: `${fileType}/${fileName}`, // The path inside the S3 bucket
		Body: fileBuffer,
		ContentType: fileType, // Use the correct content type
	};

	// Upload the file to S3
	const data = await s3.upload(params).promise();
	return data.Location; // Return the file URL from S3
};

// File Upload Request Handler
export const fileUpload: RequestHandler = (req, res, next) => {
	upload.single("file")(req, res, async function (err) {
		if (err instanceof multer.MulterError) {
			return next(new IError("Multer file upload error", 500));
		} else if (err) {
			return next(new IError("Unknown file upload error", 500));
		}

		try {
			if (!req.file) {
				throw new IError("No file provided", 400);
			}

			// Determine the file type based on the mimetype
			let fileType;
			if (req.file.mimetype.includes("audio")) {
				fileType = "audios";
			} else if (req.file.mimetype.includes("image")) {
				fileType = "images";
			} else if (req.file.mimetype.includes("video")) {
				fileType = "videos";
			} else {
				throw new IError("Invalid file type", 400);
			}

			// Create a unique filename
			const ext = path.extname(req.file.originalname);
			const filename = `${Date.now()}-${req.user?.id || uuidv4()}${ext}`;

			// Upload file to S3
			const fileUrl = await uploadToS3(
				req.file.buffer,
				filename,
				req.file.mimetype,
			);

			// Save file details in the request body (optional)
			req.body.fileType = fileType;
			req.body.filename = filename;
			req.body.fileUrl = fileUrl; // S3 URL of the uploaded file

			// Continue to the next middleware
			next();
		} catch (err) {
			next(err);
		}
	});
};
