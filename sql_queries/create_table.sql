CREATE TABLE iceberg_db.sales_data (
    order_id BIGINT,
    customer_name STRING,
    total_amount DOUBLE,
    order_date TIMESTAMP
)
LOCATION 's3://my-iceberg-data-lake/sales_data/'
TBLPROPERTIES (
    'table_type'='ICEBERG',
    'format'='parquet'
);
