#!/bin/bash
set -e
set -o pipefail
echo $PWD
export DEBIAN_FRONTEND=noninteractive
echo "Updating package lists and installing required packages..."
sudo apt-get update >> /dev/null
sudo apt-get install -y unzip nginx >> /dev/null
echo "Packages installed successfully."
echo "Installing nvm and Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash >> /dev/null
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install 18 >> /dev/null
echo "nvm and Node.js installed successfully."
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" >> /dev/null
unzip awscliv2.zip >> /dev/null && sudo ./aws/install >> /dev/null
echo "AWS CLI installed successfully."
echo "Cloning the repository..."
git clone https://github.com/chinma-yyy/rewind.git >> /dev/null
cd rewind/backend/server
echo "Repository cloned successfully."
echo "Configuring Nginx..."
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx && sudo systemctl enable nginx
echo "Nginx configured and restarted successfully."
echo "Fetching secrets and installing npm packages..."
aws secretsmanager get-secret-value --secret-id rewind/backend/server --query 'SecretString' --output text | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' > .env
npm install >> /dev/null
sudo npm install -g typescript pm2 >> /dev/null
tsc >> /dev/null
echo "Secrets fetched and npm packages installed successfully."
echo "Starting the server with pm2..."
touch logs.txt
pm2 start dist/app.js --name rewind-server --log logs.txt --time
echo "Server started successfully with pm2."
