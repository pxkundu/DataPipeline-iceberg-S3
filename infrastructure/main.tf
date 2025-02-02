provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "iceberg_bucket" {
  bucket = "my-iceberg-data-lake"
}

resource "aws_glue_catalog_database" "iceberg_db" {
  name = "iceberg_db"
}

resource "aws_athena_workgroup" "iceberg_workgroup" {
  name = "iceberg_workgroup"
  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.iceberg_bucket.bucket}/query-results/"
    }
  }
}
