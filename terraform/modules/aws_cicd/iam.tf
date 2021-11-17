resource "aws_iam_role" "codebuild_Service_role" {
  name = "ecs-go-app-codebuild_Service_role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "codebuild.amazonaws.com"
     },
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "ecs-go-app-codebuild_policy"
  role = aws_iam_role.codebuild_Service_role.name

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Action":[
            "ecr:BatchCheckLayerAvailability",
            "ecr:CompleteLayerUpload",
            "ecr:GetAuthorizationToken",
            "ecr:InitiateLayerUpload",
            "ecr:PutImage",
            "ecr:UploadLayerPart"
         ],
         "Resource":"${var.ecr_repo_arn}",
         "Effect":"Allow"
      },
      {
        "Action":[
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ],
        "Resource":"*",
        "Effect":"Allow"
      },
      {
        "Effect":"Allow",
        "Action":[
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl"
        ],
        "Resource":[
            "${aws_s3_bucket.codepipeline_artifacts_bucket.arn}",
            "${aws_s3_bucket.codepipeline_artifacts_bucket.arn}/*"
         ]
      }
   ]
}
EOF
}

resource "aws_iam_role" "codepipeline_Service_role" {
  name = "ecs-go-app-codebpipeline_Service_role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "codepipeline.amazonaws.com"
     },
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "ecs-go-app-codepipeline_policy"
  role = aws_iam_role.codepipeline_Service_role.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:CreateLogStream"
      ],
      "Resource": "*",
      "Effect": "Allow" 
    },
    {
        "Effect":"Allow",
        "Action":[
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObjectAcl"
        ],
        "Resource":[
            "${aws_s3_bucket.codepipeline_artifacts_bucket.arn}",
            "${aws_s3_bucket.codepipeline_artifacts_bucket.arn}/*"
         ]
    }    
  ]
}
EOF
}