#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update >> /dev/null
sudo apt-get install gnupg curl
sudo apt-get install -y amazon-efs-utils
mount -t efs ${efs_file_system_id_placeholder}:/ /var/lib/mongodb
echo "${efs_file_system_id_placeholder}:/ /var/lib/mongodb efs defaults,_netdev 0 0" >> /etc/fstab
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update >> /dev/null
sudo apt-get install -y mongodb-org
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections
sudo systemctl start mongod
sudo systemctl status mongod
sudo systemctl enable mongod
MONGO_CONF="/etc/mongod.conf"
MONGO_ADMIN_USER="admin"
MONGO_ADMIN_PASS="Password@123" 
TRUSTED_IP="0.0.0.0/0" 
echo "Configuring MongoDB to listen on all IPs..."
sudo sed -i "s/^  bindIp:.*/  bindIp: 0.0.0.0/" $MONGO_CONF
echo "Enabling MongoDB authentication..."
sudo sed -i "/#security:/a security:\n  authorization: enabled" $MONGO_CONF
echo "Restarting MongoDB service..."
sudo systemctl restart mongod
sleep 5
echo "Creating MongoDB admin user..."
mongosh <<EOF
use admin
db.createUser({
  user: "$MONGO_ADMIN_USER",
  pwd: "$MONGO_ADMIN_PASS",
  roles: [ { role: "userAdminAnyDatabase", db: "admin" }, { role: "readWriteAnyDatabase", db: "admin" }]
})
exit
EOF
if sudo ufw status | grep -q "Status: active"; then
    echo "Configuring UFW to allow port 27017..."
    sudo ufw allow 27017/tcp
    sudo ufw reload
fi
echo "You can now connect to MongoDB using the following command:"
echo "mongosh 'mongodb://<EC2_PUBLIC_IP>:27017' --username $MONGO_ADMIN_USER --password $MONGO_ADMIN_PASS --authenticationDatabase 'admin'"