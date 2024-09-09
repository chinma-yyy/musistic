#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update >> /dev/null
sudo apt-get install -y unzip nginx jq >> /dev/null
echo "Packages installed."
su - ubuntu -c '
cd ~
export DEBIAN_FRONTEND=noninteractive
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash >> /dev/null
source ~/.nvm/nvm.sh
nvm install 18 >> /dev/null
echo "nvm and Node.js installed."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" >> /dev/null
unzip awscliv2.zip >> /dev/null && sudo ./aws/install >> /dev/null
echo "AWS CLI installed."
git clone https://github.com/chinma-yyy/rewind.git >> /dev/null
cd rewind/frontend
aws secretsmanager get-secret-value --secret-id rewind/frontend --query "SecretString" --output text | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" > .env
npm install -g yarn >> /dev/null
yarn >> /dev/null
yarn build >> /dev/null
source ~/.nvm/nvm.sh
nvm use 18 >> /dev/null
sudo chmod 755 /home/ubuntu
sudo chmod 755 /home/ubuntu/rewind
sudo chmod 755 /home/ubuntu/rewind/frontend
sudo chmod 755 /home/ubuntu/rewind/frontend/dist
sudo cp nginx.conf /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl restart nginx && sudo systemctl enable nginx >> /dev/null
echo "Setup completed."
'