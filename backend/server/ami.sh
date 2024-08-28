#!/bin/bash
sudo apt update && sudo apt install -y unzip nginx npm jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
unzip awscliv2.zip && sudo ./aws/install 
git clone https://github.com/chinma-yyy/rewind.git 
cd rewind/backend/server 
sudo cp nginx.conf /etc/nginx/nginx.conf 
sudo systemctl restart nginx && sudo systemctl enable nginx 
aws secretsmanager get-secret-value --secret-id rewind/backend/server --query 'SecretString' --output text | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' > .env 
npm install 
sudo npm install -g typescript pm2 
tsc 
touch logs.txt 
pm2 start dist/app.js --name rewind-server --log logs.txt --time 
