terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0" # 최신 버전
    }
  }
  backend "s3" { # backend를 s3를 사용할꺼라는 명시
    bucket = "tf-backend-ansu"
    key = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}

provider "aws" {
  region = "ap-northeast-2"
}


# 권한 설정도 필요함
resource "aws_s3_bucket" "tf_backend" {
  bucket = "tf-backend-ansu"

  tags = {
    Name = "tf-backend"
  }
}

resource "aws_s3_bucket_versioning" "tf_backend_versioning" {
  bucket = aws_s3_bucket.tf_backend.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 23.04월 부터 바뀐 정책으로 ownership_control을 추가해 acl을 추가 할 수 있다.
resource "aws_s3_bucket_ownership_controls" "tf_backend_ownership_controls" {
  bucket = aws_s3_bucket.tf_backend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" {
  # ownership에 대한 의존성 주입
  depends_on = [aws_s3_bucket_ownership_controls.tf_backend_ownership_controls]

  bucket = aws_s3_bucket.tf_backend.id
  acl = "private"
}