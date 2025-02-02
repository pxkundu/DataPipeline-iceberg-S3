### **📜 `troubleshooting.md` - Troubleshooting Guide for Apache Iceberg on AWS S3 & Athena**  

This document provides solutions for **common issues** when working with **Apache Iceberg on AWS S3, Athena, Glue, and Spark**.

---

## **🚀 Common Issues & Fixes**

---

### **🔹 1. Query Returns Empty Results in Athena**
#### **Issue:**  
- Running `SELECT * FROM iceberg_db.sales_data;` in **Athena** returns an empty result set.

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** Data has not been committed.  
✅ **Fix:** Check if there are snapshots available. Run:  
```sql
SELECT * FROM iceberg_db.sales_data$snapshots;
```
If no snapshots exist, commit the data using Spark or a proper write mechanism.

✔️ **Cause 2:** AWS Glue catalog is outdated.  
✅ **Fix:** Refresh the AWS Glue catalog manually:
```sh
aws glue start-crawler --name my-iceberg-crawler
```
✔️ **Cause 3:** Querying the wrong database.  
✅ **Fix:** Ensure you're running the query in the correct **Athena Workgroup** with the right database selected.

---

### **🔹 2. `TABLE NOT FOUND` Error in Athena**
#### **Issue:**  
- Running a query results in:  
  ```
  HIVE_METASTORE_ERROR: Table iceberg_db.sales_data does not exist
  ```

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** Table name is incorrect.  
✅ **Fix:** Run this query to list available Iceberg tables:
```sql
SHOW TABLES IN iceberg_db;
```
✔️ **Cause 2:** AWS Glue catalog is not updated.  
✅ **Fix:** Refresh Athena’s metadata:
```sql
MSCK REPAIR TABLE iceberg_db.sales_data;
```
✔️ **Cause 3:** The table creation failed.  
✅ **Fix:** Check the **AWS Glue Catalog** console and verify if the table exists.

---

### **🔹 3. Slow Queries on Iceberg Tables**
#### **Issue:**  
- Queries on **Iceberg tables** in **Athena/Trino/Spark** take too long.

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** No partitioning defined.  
✅ **Fix:** Check partitions:
```sql
SELECT * FROM iceberg_db.sales_data$partitions;
```
If empty, enable partitioning:
```sql
ALTER TABLE iceberg_db.sales_data ADD PARTITION FIELD order_date;
```
✔️ **Cause 2:** Small files causing performance issues.  
✅ **Fix:** Compact files:
```sql
CALL iceberg.system.rewrite_data_files('iceberg_db.sales_data');
```

✔️ **Cause 3:** Too many outdated snapshots slowing down queries.  
✅ **Fix:** Expire old snapshots:
```sql
CALL iceberg.system.expire_snapshots('iceberg_db.sales_data') WHERE committed_at < TIMESTAMP '2024-01-01 00:00:00';
```

---

### **🔹 4. `HIVE_BAD_DATA` Error in Athena**
#### **Issue:**  
- Queries return the following error:  
  ```
  HIVE_BAD_DATA: Error processing Iceberg table
  ```

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** Athena is trying to query old, deleted metadata.  
✅ **Fix:** **Invalidate old cache**:
```sql
ALTER TABLE iceberg_db.sales_data EXECUTE DELETE WHERE order_date < TIMESTAMP '2024-01-01 00:00:00';
```

✔️ **Cause 2:** S3 bucket permissions prevent Athena from reading data.  
✅ **Fix:** Ensure your **IAM Role** has the following S3 permissions:
```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::my-iceberg-data-lake/*"
  ]
}
```

---

### **🔹 5. `SERIALIZATION ERROR` When Running Iceberg Queries in Athena**
#### **Issue:**  
- Running Iceberg queries in Athena causes:
  ```
  SERIALIZATION ERROR: Error while serializing schema
  ```

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** Schema changes were made, but Athena is using outdated metadata.  
✅ **Fix:** Refresh Athena metadata:
```sql
MSCK REPAIR TABLE iceberg_db.sales_data;
```

✔️ **Cause 2:** Table schema has too many evolutions without compaction.  
✅ **Fix:** Optimize metadata:
```sql
CALL iceberg.system.rewrite_manifests('iceberg_db.sales_data');
```

---

### **🔹 6. Data is Not Updating After Running an `INSERT` or `DELETE` Query**
#### **Issue:**  
- **Newly inserted or deleted records** are not reflected in **Athena queries**.

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** Iceberg uses snapshot isolation; queries default to the latest **committed snapshot**.  
✅ **Fix:** Verify if new snapshots exist:
```sql
SELECT * FROM iceberg_db.sales_data$snapshots ORDER BY committed_at DESC;
```
To query the latest snapshot manually:
```sql
SELECT * FROM iceberg_db.sales_data FOR SYSTEM_VERSION AS OF 123456789;
```

✔️ **Cause 2:** Query engine is not set to use Iceberg’s latest snapshot.  
✅ **Fix:** Force query engine to read updated metadata:
```sql
ALTER TABLE iceberg_db.sales_data REFRESH;
```

---

### **🔹 7. Data Corruption After Schema Changes**
#### **Issue:**  
- Schema changes cause data corruption or missing fields.

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** Queries are still referencing the old schema.  
✅ **Fix:** Verify schema history:
```sql
SELECT * FROM iceberg_db.sales_data$history;
```
To apply schema updates:
```sql
ALTER TABLE iceberg_db.sales_data ADD COLUMNS (new_column STRING);
```

✔️ **Cause 2:** Schema evolution is causing compatibility issues.  
✅ **Fix:** Convert queries to match the latest schema version:
```sql
SELECT order_id, COALESCE(new_column, 'N/A') AS new_column FROM iceberg_db.sales_data;
```

---

### **🔹 8. `S3AccessDenied` Error When Querying Iceberg Tables**
#### **Issue:**  
- Running an **Athena or Trino query** results in:
  ```
  ACCESS DENIED: S3AccessDeniedException
  ```

#### **Possible Causes & Fixes:**  
✔️ **Cause 1:** IAM Role doesn’t have permission to read Iceberg data.  
✅ **Fix:** Attach the following permissions:
```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::my-iceberg-data-lake/*"
  ]
}
```

✔️ **Cause 2:** S3 bucket encryption settings are blocking Athena.  
✅ **Fix:** Ensure that Athena is allowed to read **KMS-encrypted data**.

---

### **🚀 Final Recommendations**
✅ **Enable Table Optimization:** Run periodic optimizations:  
```sql
CALL iceberg.system.rewrite_data_files('iceberg_db.sales_data');
```
✅ **Use Partitioning for Faster Queries:**  
```sql
ALTER TABLE iceberg_db.sales_data ADD PARTITION FIELD year(order_date);
```
✅ **Monitor Iceberg Table Metadata Growth:**  
```sql
SELECT * FROM iceberg_db.sales_data$metadata;
```

---

### **📌 Need Further Help?**
If you encounter issues not listed here:
1. **Check AWS Glue logs for metadata issues.**
2. **Look at Athena Query Execution Logs (`QueryExecutionId`).**
3. **Use AWS CloudTrail to monitor S3 access issues.**

---

### **🚀 Conclusion**
By following these troubleshooting steps, you can resolve **common Apache Iceberg issues** related to **Athena, S3, Glue, and Trino/Spark integrations**.

If you still have issues, reach out via **GitHub Issues** or AWS Support! 🚀🔥

---
