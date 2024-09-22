#!/bin/bash
# Function to handle errors
handle_error() {
  echo "Error occurred in script at line $1."
  exit 1
}
# Trap errors and call handle_error function
trap 'handle_error $LINENO' ERR
# Update package list
echo "Updating package list..."
sudo apt update -qq >/dev/null
# Install required packages
echo "Installing fontconfig and OpenJDK 17..."
sudo apt install -y -qq fontconfig openjdk-17-jre >/dev/null
# Verify Java installation
echo "Checking Java version..."
java -version
# Download Jenkins GPG key
echo "Downloading Jenkins GPG key..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2023.key >/dev/null
# Add Jenkins repository
echo "Adding Jenkins repository to sources list..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
# Update package list again
echo "Updating package list with Jenkins repository..."
sudo apt-get update -qq >/dev/null
# Install Jenkins and Nginx
echo "Installing Jenkins and Nginx..."
sudo apt-get install -y -qq jenkins nginx >/dev/null
# Restart Jenkins service
echo "Restarting Jenkins service..."
sudo systemctl restart jenkins >/dev/null
# Create Nginx configuration for Jenkins
echo "Configuring Nginx for Jenkins..."
cat <<EOL | sudo tee /etc/nginx/nginx.conf >/dev/null
http {
    upstream backend {
        server 127.0.0.1:8080;
    }
    server {
        listen 80;
        location / {
            proxy_pass http://backend/; 
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Host \$host;
            proxy_set_header X-Forwarded-Proto \$scheme;           
        }
    }
}
    events {
        # You can put your events configuration here if needed
    }
EOL
# Restart Nginx service
echo "Restarting Nginx service..."
sudo systemctl restart nginx >/dev/null
echo "Jenkins and Nginx installation and configuration complete!"
