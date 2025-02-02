# 🚀 Apache Iceberg with AWS S3 & Athena

## 📌 Overview
This project demonstrates how to use **Apache Iceberg** with **AWS S3, AWS Glue, and AWS Athena** to create a modern, efficient, and scalable **data lakehouse**.

### **🔹 Features**
- ✅ **ACID Transactions** on AWS S3 using Iceberg
- ✅ **Schema Evolution** (add, rename, drop columns)
- ✅ **Time Travel** queries with historical snapshots
- ✅ **Partition Evolution** for optimized query performance
- ✅ **Integration with AWS Athena, Glue, and Terraform**

---

## 📂 Project Structure
.
├── infrastructure   # Terraform scripts for AWS setup
│   ├── main.tf
│   ├── glue_catalog.tf
│   ├── s3_bucket.tf
│   ├── athena_iceberg.tf
│   ├── variables.tf
├── sql_queries      # SQL scripts for table creation & querying
│   ├── create_database.sql
│   ├── create_table.sql
│   ├── insert_data.sql
│   ├── query_data.sql
│   ├── time_travel.sql
│   ├── schema_evolution.sql
│   ├── optimize_table.sql
├── scripts          # Python scripts for data automation
│   ├── s3_upload.py
│   ├── iceberg_query.py
│   ├── optimize_table.py
├── notebooks        # Jupyter Notebook for interactive demo
│   ├── Iceberg_Demo.ipynb
├── config           # Configuration files
│   ├── aws_config.json
│   ├── glue_crawler_config.json
│   ├── iceberg_table_properties.json
├── data             # Sample dataset
│   ├── sample_data.csv
├── docs             # Documentation
│   ├── setup_guide.md
│   ├── architecture_diagram.png
│   ├── troubleshooting.md
└── README.md        # Project documentation

---

## 🚀 **Setup Guide**
### **🔹 1️⃣ Prerequisites**
- **AWS CLI** configured with valid credentials
- **Terraform** installed (`terraform -v`)
- **Python 3** with `boto3` installed (`pip install boto3`)
- **Athena Workgroup** & **S3 Bucket** created

### **🔹 2️⃣ Provision AWS Infrastructure**
Run the following commands to create **S3, AWS Glue, and Athena** resources using Terraform:

```sh
cd infrastructure
terraform init
terraform apply
```
**Resources created:**
- `S3 Bucket` for Iceberg data lake (`s3://my-iceberg-data-lake/`)
- `AWS Glue Database` (`iceberg_db`)
- `Athena Workgroup` for querying Iceberg tables

---

## 🛠️ **Usage Instructions**
### **🔹 3️⃣ Upload Sample Data to S3**
```sh
python scripts/s3_upload.py
```

---

### **🔹 4️⃣ Create Iceberg Table**
Run the following **SQL script in Athena**:
```sql
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
```

---

### **🔹 5️⃣ Insert Data**
```sql
INSERT INTO iceberg_db.sales_data VALUES
    (1, 'Alice', 250.50, TIMESTAMP '2024-02-02 10:00:00'),
    (2, 'Bob', 300.75, TIMESTAMP '2024-02-02 11:15:00');
```

---

### **🔹 6️⃣ Query Iceberg Table via Athena**
```sql
SELECT * FROM iceberg_db.sales_data;
```

OR using Python:
```sh
python scripts/iceberg_query.py
```

---

## 📌 **Advanced Features**
### **🔹 7️⃣ Time Travel Queries**
Apache Iceberg stores snapshots of your table. Use **Time Travel Queries** to view historical data.

1️⃣ **List available snapshots**:
```sql
SELECT * FROM iceberg_db.sales_data$snapshots;
```
2️⃣ **Query a previous snapshot**:
```sql
SELECT * FROM iceberg_db.sales_data FOR SYSTEM_VERSION AS OF 123456789;
```
*(Replace `123456789` with a valid snapshot ID)*

---

### **🔹 8️⃣ Schema Evolution**
Modify table schema **without rewriting the entire dataset**.

- **Add a new column**:
```sql
ALTER TABLE iceberg_db.sales_data ADD COLUMNS (customer_email STRING);
```
- **Rename a column**:
```sql
ALTER TABLE iceberg_db.sales_data RENAME COLUMN total_amount TO total_price;
```
- **Drop a column**:
```sql
ALTER TABLE iceberg_db.sales_data DROP COLUMN customer_name;
```

---

### **🔹 9️⃣ Optimize Table Performance**
Iceberg manages **small files** and **table compaction**.

**Manually trigger optimization**:
```sql
CALL iceberg.system.rewrite_data_files('iceberg_db.sales_data');
```

---

## 🛠 **Troubleshooting**
If you encounter **Athena query failures**, check:
1. AWS Glue **database and table names** are correctly set.
2. The **S3 location** for Iceberg tables is correct (`s3://my-iceberg-data-lake/`).
3. **Permissions**:
   - AWS Glue IAM role has `AthenaQueryExecution` permissions.
   - S3 bucket allows **Athena read/write access**.

More details in 📁 `docs/troubleshooting.md`.

---

## 📌 **Comparison: Iceberg vs Delta Lake vs Hudi**
| Feature          | Apache Iceberg | Delta Lake | Apache Hudi |
|-----------------|---------------|------------|-------------|
| **ACID Transactions** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Schema Evolution** | ✅ Yes | ✅ Yes | 🟠 Partial |
| **Partition Evolution** | ✅ Yes | ❌ No | ❌ No |
| **Time Travel** | ✅ Yes | ✅ Yes | 🟠 Limited |
| **AWS Glue Support** | ✅ Yes | ✅ Yes | ❌ No |

---

## 🎯 **Next Steps**
- ✅ **Integrate with Apache Spark for batch processing**
- ✅ **Deploy AWS Lambda for real-time data ingestion**
- ✅ **Automate deployment using GitHub Actions**
- ✅ **Connect Iceberg with AWS EMR & Redshift Spectrum**

---

## 📜 **License**
This project is licensed under the **MIT License**.

---

## ⭐ **Support & Contributions**
🔹 Found this useful? **Give a star ⭐ on GitHub!**  
🔹 Want to contribute? **Fork and submit a PR!**  

📩 **Need Help?** Contact via **GitHub Issues**.

---

### **🚀 Happy Data Engineering with Apache Iceberg & AWS! 🎉**
```

---

## **🚀 Next Steps**
1. **GitHub Actions workflow** to automate deployment
2. **Need an architecture diagram for documentation**

