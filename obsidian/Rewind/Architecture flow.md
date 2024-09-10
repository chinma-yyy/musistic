 # Checklist

- [x] **Main Route Table**  
- [x] **Rewind VPC**  
- [x] **IGW for Rewind**  
- [x] **Attach IGW to VPC**  
- [x] **Create Subnets**  
  - [x] 2 Public subnets in 2 different AZ (A,B)  
  - [x] 4 Private subnets in 2 different AZ (A1,B1,A2,B2)  
- [x] **NAT Gateway in one public subnet**  
- [x] **Subnet Route Tables**  
  - [x] 1 Public subnet  
  - [x] 2 for Private subnets for 2 levels  
- [x] **Create a Security Group for Rewind Servers**  
- [x] **Create a Security Group for Bastion Host**  
- [x] **Create Security Groups for ALB**  
  - [x] Internet-facing  
  - [x] Internal  
- [x] **Create an IAM EC2 Role for Accessing Secrets**  
- [ ] **Create a Key Pair and Download it on the Instance**  
- [x] **Create Launch Templates**  
  - [x] Server  
  - [x] Sockets  
  - [x] MongoDB  
  - [x] Frontend  
- [x] **Create an EFS for MongoDB**  
- [x] **Create an NLB for MongoDB in Private Subnet**  
- [x] **Create a Target Group for MongoDB**  
- [x] **Create an ASG for MongoDB**  
- [x] **Create Redis Clusters in Private Subnet Using ElastiCache**  
- [ ] **Create an S3 Bucket**  
- [ ] **Create a VPC Endpoint for the S3 Bucket**  
- [x] **Create ALBs for Server Socket and Frontend**  
- [x] **Modify Rules of the Listener on ALB for /socket.io* to Sockets ALB**  
- [x] **Create Target Groups for Server Socket and Frontend**  
- [x] **Create ASGs for Server Socket and Frontend**  
- [x] **Access Route53 Record for Domain and Add Records for AB of Frontend and Backend**

1. Main Route table 
2. Rewind VPC
3. IGW for rewind
4. Attach IGW to VPC
5. Create Subnets 
	1. 2 Public subnets in 2 different AZ (A,B)
	2. 4 Private subnets in 2 different AZ (A1,B1,A2,B2)
6. NAT Gateway in one public subnet
7. Subnet Route tables 
	1. 1 Public subnet
	2. 2 for Private subnet for 2 levels
8. Create a security group for rewind servers
9. Create a security group for bastion host
10. Create security group for ALB which are internet facing and internal respectively 
11. Create a IAM EC2 role for accessing the secrets 
12. Create a key pair and download it on the instance
13. Create launch templates for server, sockets, mongodb and frontend
14. Create an EFS for mongodb
15. Create an ALB for mongoDB in private subnet
16. Create a Target Group for mongoDB
17. Create an ASG for mongoDB 
18. Create Redis clusters in private subnet using elasticache
19. Create an S3 bucket
20. Create a VPC endpoint for the S3 bucket
21. Create ALB for server socket and frontend
22. Modify the rules of the listener on the ALB for /socket.io* to sockets ALB
23. Create a target group for server socket and frontend
24. Create ASG for server socket and frontend
25. Access the route53 record for the domain we already have and add the records for AB of frontend and backend