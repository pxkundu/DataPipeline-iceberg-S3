## **📌 Apache Iceberg SQL Queries for Core Functionalities & Special Features**

Apache Iceberg stands out due to its **powerful functionalities**, such as **time travel, schema evolution, partition evolution, hidden partitioning, snapshot management, and ACID transactions**. Below is a **comprehensive collection of SQL queries** that showcase **Iceberg's core strengths and unique features**.

---

# **1️⃣ Core Functionalities of Apache Iceberg**
## **📍 1. ACID Transactions**
### **🔹 Insert Data (Atomic Insert)**
```sql
INSERT INTO iceberg_db.sales_data VALUES
    (1, 'Alice', 250.50, TIMESTAMP '2024-02-02 10:00:00'),
    (2, 'Bob', 300.75, TIMESTAMP '2024-02-02 11:15:00');
```

### **🔹 Delete Data (Atomic Delete)**
```sql
DELETE FROM iceberg_db.sales_data WHERE customer_name = 'Alice';
```

### **🔹 Update Data (ACID Update)**
```sql
UPDATE iceberg_db.sales_data SET total_amount = 400.00 WHERE order_id = 2;
```

### **🔹 Upsert Data (MERGE INTO)**
```sql
MERGE INTO iceberg_db.sales_data AS target
USING (SELECT 2 AS order_id, 'Bob' AS customer_name, 450.00 AS total_amount, TIMESTAMP '2024-02-02 11:15:00' AS order_date) AS source
ON target.order_id = source.order_id
WHEN MATCHED THEN UPDATE SET total_amount = source.total_amount
WHEN NOT MATCHED THEN INSERT VALUES (source.order_id, source.customer_name, source.total_amount, source.order_date);
```

---

## **📍 2. Time Travel (Query Historical Data)**
### **🔹 List All Available Snapshots**
```sql
SELECT * FROM iceberg_db.sales_data$snapshots;
```

### **🔹 Query a Specific Snapshot**
```sql
SELECT * FROM iceberg_db.sales_data FOR SYSTEM_VERSION AS OF 123456789;
```
*(Replace `123456789` with a valid snapshot ID.)*

### **🔹 Query Data from a Specific Timestamp**
```sql
SELECT * FROM iceberg_db.sales_data FOR SYSTEM_TIME AS OF TIMESTAMP '2024-02-01 12:00:00';
```

### **🔹 Rollback Table to a Previous Snapshot**
```sql
CALL iceberg.system.rollback_to_snapshot('iceberg_db.sales_data', 123456789);
```

---

## **📍 3. Schema Evolution (Modify Schema Without Data Rewriting)**
### **🔹 Add a New Column**
```sql
ALTER TABLE iceberg_db.sales_data ADD COLUMNS (customer_email STRING);
```

### **🔹 Rename an Existing Column**
```sql
ALTER TABLE iceberg_db.sales_data RENAME COLUMN total_amount TO total_price;
```

### **🔹 Drop an Unused Column**
```sql
ALTER TABLE iceberg_db.sales_data DROP COLUMN customer_name;
```

---

## **📍 4. Partition Evolution (Change Partitioning Dynamically)**
### **🔹 View Current Partitions**
```sql
SELECT * FROM iceberg_db.sales_data$partitions;
```

### **🔹 Enable Hidden Partitioning**
```sql
ALTER TABLE iceberg_db.sales_data SET TBLPROPERTIES (
    'write.distribution-mode'='hash',
    'write.partitioning'='order_date'
);
```

### **🔹 Change Partitioning Without Rewriting Data**
```sql
ALTER TABLE iceberg_db.sales_data DROP PARTITION FIELD order_date;
ALTER TABLE iceberg_db.sales_data ADD PARTITION FIELD year(order_date);
```

---

# **2️⃣ Advanced Iceberg Functionalities**
## **📍 5. Metadata & Performance Optimization**
### **🔹 View Iceberg Metadata**
```sql
SELECT * FROM iceberg_db.sales_data$metadata;
```

### **🔹 Compact Small Files (Rewrite Data Files)**
```sql
CALL iceberg.system.rewrite_data_files('iceberg_db.sales_data');
```

### **🔹 Optimize Manifest Files (Metadata Compaction)**
```sql
CALL iceberg.system.rewrite_manifests('iceberg_db.sales_data');
```

### **🔹 Set Table Properties for Better Performance**
```sql
ALTER TABLE iceberg_db.sales_data SET TBLPROPERTIES (
    'write.format.default'='parquet',
    'write.metadata.delete-after-commit.enabled'='true',
    'write.metadata.previous-versions-max'='5'
);
```

---

## **📍 6. Snapshot Management (Data Retention & Cleanup)**
### **🔹 View Table History**
```sql
SELECT * FROM iceberg_db.sales_data$history;
```

### **🔹 Expire Old Snapshots (Data Retention Policy)**
```sql
CALL iceberg.system.expire_snapshots(
  table => 'iceberg_db.sales_data',
  retain_last => 5
);
```

### **🔹 Manually Remove Older Snapshots**
```sql
CALL iceberg.system.expire_snapshots('iceberg_db.sales_data') WHERE committed_at < TIMESTAMP '2024-01-01 00:00:00';
```

---

## **📍 7. Insert Overwrite & Incremental Queries**
### **🔹 Replace Existing Data (Insert Overwrite)**
```sql
INSERT OVERWRITE iceberg_db.sales_data 
SELECT * FROM iceberg_db.sales_data WHERE order_date >= TIMESTAMP '2024-01-01 00:00:00';
```

### **🔹 Query Only New Changes Since Last Snapshot**
```sql
SELECT * FROM iceberg_db.sales_data CHANGES SINCE SYSTEM_VERSION 123456789;
```

---

## **📍 8. Multi-Engine Querying (Presto, Trino, Spark, Hive)**
### **🔹 Query Iceberg Table in Presto/Trino**
```sql
SELECT * FROM iceberg.iceberg_db.sales_data;
```

### **🔹 Query Iceberg Table in Spark**
```python
spark.read.format("iceberg").load("iceberg_db.sales_data").show()
```

---

## **🚀 Why Iceberg is Better than Delta Lake & Apache Hudi?**
| **Feature**                  | **Apache Iceberg** | **Delta Lake** | **Apache Hudi** |
|------------------------------|--------------------|---------------|---------------|
| **ACID Transactions**        | ✅ Yes             | ✅ Yes        | ✅ Yes        |
| **Time Travel (Snapshots)**  | ✅ Yes             | ✅ Yes        | 🟠 Limited   |
| **Schema Evolution**         | ✅ Full Support    | ✅ Full Support | 🟠 Partial   |
| **Partition Evolution**      | ✅ Yes             | ❌ No         | ❌ No        |
| **Hidden Partitioning**      | ✅ Yes             | ❌ No         | ❌ No        |
| **Small File Compaction**    | ✅ Automatic       | ✅ Manual     | ✅ Manual    |
| **Multi-Engine Support**     | ✅ Yes (Spark, Presto, Trino, Hive, Flink) | ❌ Mostly Databricks Only | ✅ Yes (Flink Focused) |

---

## **🎯 Summary of Iceberg's Unique SQL Features**
| **Category**         | **Key Queries** |
|----------------------|---------------|
| 🟢 **ACID Transactions** | `INSERT`, `UPDATE`, `MERGE INTO`, `DELETE` |
| 🔵 **Time Travel** | `SELECT FOR SYSTEM_VERSION`, `ROLLBACK TO SNAPSHOT` |
| 🟠 **Schema Evolution** | `ADD COLUMNS`, `RENAME COLUMN`, `DROP COLUMN` |
| 🔴 **Partition Evolution** | `ADD PARTITION FIELD`, `DROP PARTITION FIELD` |
| 🔵 **Metadata Optimization** | `REWRITE DATA FILES`, `REWRITE MANIFESTS` |
| 🟣 **Snapshot Management** | `EXPIRE SNAPSHOTS`, `VIEW HISTORY` |

---
