#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update >> /dev/null
sudo apt-get install -y unzip nginx curl git jq >> /dev/null
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
cd rewind/backend/server
source ~/.nvm/nvm.sh
nvm use 18 >> /dev/null
sudo cp nginx.conf /etc/nginx/nginx.conf >> /dev/null
sudo systemctl restart nginx && sudo systemctl enable nginx >> /dev/null
aws secretsmanager get-secret-value --secret-id rewind/backend/server --query "SecretString" --output text | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" > .env
npm install >> /dev/null
npm install -g typescript pm2 >> /dev/null
tsc >> /dev/null
touch logs.txt
pm2 start dist/app.js --name rewind-server --log logs.txt --time >> /dev/null
echo "Setup completed."
'