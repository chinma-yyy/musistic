# Use the official Node.js 18 image as a base
FROM node:18

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and yarn.lock files to the working directory
COPY package*.json ./

# Install dependencies
RUN yarn install

# Copy the rest of the application code to the working directory
COPY . .

# Build the React app
RUN yarn build

# Install a simple HTTP server to serve the static files
RUN yarn global add serve

# Expose the port that serve uses by default
EXPOSE 5000

# Set the command to serve the app
CMD ["serve", "-s", "dist"]

