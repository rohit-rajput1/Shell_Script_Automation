# This line tell the system to use the Bash Shell to interpret the script and "#!/bin/bash" is called shebang.
#!/bin/bash

# This line `set -x` in a shell script turns on the debugging mode, which means that shell will display each command before it executing it.
set -x

# This line in a shell script retrieves the AWS Account ID of the user who is currently authenticated with AWS CLI in a variable called `aws_account_id`.
aws_account_id = $(aws sts get-caller-identity --query 'Account' --output text)

# This line displays the account ID for the user who is currently authenticated with AWS CLI.
echo "AWS ACCOUNT ID: $aws_account_id"

# Now we will create a new S3 bucket with the name `s3-shell-trigger` in the region `ap-south-1`, so these variables will be used later in the script to interact with AWS Services.
aws_region = 'ap-south-1'
bucket_name = 's3-shell-trigger'
lambda_function_name = 's3-shell-trigger-lambda'
role_name = 's3-shell-trigger-role'
email_address = 'rohit31rajput2001@gmail.com'

# This line creates a IAM role in AWS called "s3-lambda-sns" and allows it to be used by specific AWS services like Lambda, S3, and SNS. Then, it stores information about this role in a variable called "role_response".
role_reponse = $(aws iam create-role --role-name s3-lambda-sns --assume-role-policy-document '{
   "Version": "2012-10-17",
   "Statement": [{
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal":{
         "Service":[
            "lambda.amazonaws.com",
            "s3.amazonaws.com",
            "sns.amazonaws.com"
         ]
      }
   }]
}')

# Now we will extract the IAM Role ARN from the JSON reponse and store it in a variable called "role_arn".
role_arn = $(echo "$role_response" | jq -r '.Role.Arn')
# jq is used to parse, filter and manipulate JSON Data.

# After this we will print the IAM Role ARN to the console.
echo "IAM ROLE ARN: $role_arn"

# Now we will attach the IAM Permission Policy to the IAM Role, so that it can be used by AWS Services.
aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam attach-role-policy --role-name $role_name --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess