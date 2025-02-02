import boto3

s3 = boto3.client('s3')
bucket_name = "my-iceberg-data-lake"
file_name = "data/sample_data.csv"

s3.upload_file(file_name, bucket_name, "sample_data.csv")
print("File uploaded successfully!")
