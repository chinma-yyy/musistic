import { RequestHandler } from "express";
import { IError } from "../types/basic/IError";
import multer, { MulterError } from "multer";
import { S3 } from "aws-sdk";
import { v4 as uuidv4 } from "uuid"; // For generating unique file names

// Initialize AWS S3
const s3 = new S3({});

// Configure Multer to store files in memory (temporary storage)
const storage = multer.memoryStorage();

// Initialize Multer middleware
const upload = multer({
	storage,
	limits: { fileSize: 50 * 1024 * 1024 }, // Limit file size to 50MB
});

// Middleware to upload file to S3
export const fileUpload: RequestHandler = (req, res, next) => {
	upload.single("file")(req, res, async (err) => {
		if (err instanceof MulterError) {
			return next(new IError(`Multer upload error: ${err.message}`, 500));
		} else if (err) {
			return next(
				new IError(`Unknown upload error: ${err.message}`, 500),
			);
		}

		if (!req.file) {
			return next();
		}
		try {
			// Define S3 upload parameters
			//@ts-ignore
			const fileExtension = req.file.originalname.split(".").pop();
			const fileName = `${uuidv4()}.${fileExtension}`; // Generate a unique filename

			const params = {
				Bucket: process.env.AWS_S3_BUCKET_NAME!, // Your S3 bucket name
				Key: fileName, // File name to save as in S3
				//@ts-ignore
				Body: req.file.buffer, // File data from multer
				//@ts-ignore
				ContentType: req.file.mimetype, // Set appropriate content type
				ACL: "public-read", // File will be publicly accessible
			};

			// Upload the file to S3
			const data = await s3.upload(params).promise();

			// Store the S3 file URL in request body to use in the next middleware/route
			req.body.fileName = data.Location;
			console.log(fileName);

			next();
		} catch (s3Err) {
			console.error("S3 upload error: ", s3Err);
			return next(new IError("Failed to upload file to S3", 500));
		}
	});
};
