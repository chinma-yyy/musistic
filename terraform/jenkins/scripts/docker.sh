#!/bin/bash
# Function to handle errors
handle_error() {
  echo "Error occurred in script at line $1."
  exit 1
}
# Trap errors and call handle_error function
trap 'handle_error $LINENO' ERR
echo "Updating package list..."
sudo apt update -qq >/dev/null
# Install required packages
echo "Installing fontconfig and OpenJDK 17..."
sudo apt install -y -qq fontconfig openjdk-17-jre >/dev/null
# Verify Java installation
echo "Checking Java version..."
java -version
# Update package list
echo "Updating package list..."
sudo apt-get update -qq >/dev/null
# Install necessary packages
echo "Installing required packages (ca-certificates, curl)..."
sudo apt-get install -y -qq ca-certificates curl >/dev/null
# Create the keyrings directory
echo "Creating keyring directory..."
sudo install -m 0755 -d /etc/apt/keyrings >/dev/null
# Download Docker's official GPG key
echo "Downloading Docker's GPG key..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >/dev/null
# Change permissions for the GPG key
echo "Setting permissions for Docker's GPG key..."
sudo chmod a+r /etc/apt/keyrings/docker.asc >/dev/null
# Add Docker repository to apt sources
echo "Adding Docker repository to sources list..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
# Update package list again
echo "Updating package list with Docker repository..."
sudo apt-get update -qq >/dev/null
# Install Docker packages
echo "Installing Docker (docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin)..."
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null
# Test Docker installation by running hello-world
echo "Running Docker hello-world container to verify installation..."
sudo docker run hello-world >/dev/null
# Add user 'ubuntu' to Docker group
echo "Adding user 'ubuntu' to the Docker group..."
sudo usermod -aG docker ubuntu >/dev/null
# Apply new group membership without requiring a logout
echo "Applying new Docker group membership for 'ubuntu'..."
echo "Docker installation and verification complete!"
