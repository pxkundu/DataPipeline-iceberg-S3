import boto3

client = boto3.client('athena')

query = "SELECT * FROM iceberg_db.sales_data;"
response = client.start_query_execution(
    QueryString=query,
    QueryExecutionContext={"Database": "iceberg_db"},
    ResultConfiguration={"OutputLocation": "s3://my-iceberg-data-lake/query-results/"}
)

print("Query executed successfully! Check S3 for results.")
