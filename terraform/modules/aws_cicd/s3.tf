resource "aws_s3_bucket" "codepipeline_artifacts_bucket" {
  bucket = "${var.codepipeline_name}-us-east-1-artifcats-bucket"
  acl    = "private"
  versioning {
    enabled = true
  }
}