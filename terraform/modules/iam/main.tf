resource "aws_iam_role" "ec2_secrets_role" {
  name = "secrets_role_ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = var.project
  }
}

resource "aws_iam_role_policy" "ec2_secrets_role_policy" {
  name = "secrets_role_policy"
  role = aws_iam_role.ec2_secrets_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "BasePermissions",
        Effect = "Allow",
        Action = [
          "secretsmanager:*",
          "cloudformation:CreateChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:DescribeStackResource",
          "cloudformation:DescribeStacks",
          "cloudformation:ExecuteChangeSet",
          "docdb-elastic:GetCluster",
          "docdb-elastic:ListClusters",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "kms:DescribeKey",
          "kms:ListAliases",
          "kms:ListKeys",
          "lambda:ListFunctions",
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances",
          "redshift:DescribeClusters",
          "redshift-serverless:ListWorkgroups",
          "redshift-serverless:GetNamespace",
          "tag:GetResources"
        ],
        Resource = "*"
      },
      {
        Sid    = "LambdaPermissions",
        Effect = "Allow",
        Action = [
          "lambda:AddPermission",
          "lambda:CreateFunction",
          "lambda:GetFunction",
          "lambda:InvokeFunction",
          "lambda:UpdateFunctionConfiguration"
        ],
        Resource = "arn:aws:lambda:*:*:function:SecretsManager*"
      },
      {
        Sid    = "SARPermissions",
        Effect = "Allow",
        Action = [
          "serverlessrepo:CreateCloudFormationChangeSet",
          "serverlessrepo:GetApplication"
        ],
        Resource = "arn:aws:serverlessrepo:*:*:applications/SecretsManager*"
      },
      {
        Sid    = "S3Permissions",
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "arn:aws:s3:::awsserverlessrepo-changesets*",
          "arn:aws:s3:::secrets-manager-rotation-apps-*/*"
        ]
      }
    ]
  })
}
