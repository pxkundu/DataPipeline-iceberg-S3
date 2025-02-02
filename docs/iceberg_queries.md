A **comprehensive list of SQL queries** for **Apache Iceberg**, categorized from **basic to advanced**, which you can store for future reference.

---

# **📌 Apache Iceberg SQL Query Collection**
### **📂 Structure**
- **Basic Queries** → Creating databases, tables, inserting & selecting data.
- **Intermediate Queries** → Partitioning, Time Travel, Schema Evolution.
- **Advanced Queries** → Data compaction, Metadata management, Optimizations.

---

## **1️⃣ Basic Queries (Table Creation & Data Operations)**

### **Create Database**
```sql
CREATE DATABASE iceberg_db;
```

---

### **Create an Iceberg Table**
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

### **Insert Data into Iceberg Table**
```sql
INSERT INTO iceberg_db.sales_data VALUES
    (1, 'Alice', 250.50, TIMESTAMP '2024-02-02 10:00:00'),
    (2, 'Bob', 300.75, TIMESTAMP '2024-02-02 11:15:00');
```

---

### **Simple SELECT Query**
```sql
SELECT * FROM iceberg_db.sales_data;
```

---

## **2️⃣ Intermediate Queries (Partitioning, Time Travel, Schema Evolution)**

### **List Partitions in Iceberg Table**
```sql
SELECT * FROM iceberg_db.sales_data$partitions;
```

---

### **Enable Hidden Partitioning in Iceberg**
```sql
ALTER TABLE iceberg_db.sales_data SET TBLPROPERTIES (
    'write.distribution-mode'='hash',
    'write.partitioning'='order_date'
);
```

---

### **List Available Snapshots (Time Travel)**
```sql
SELECT * FROM iceberg_db.sales_data$snapshots;
```

---

### **Query a Specific Snapshot (Time Travel)**
```sql
SELECT * FROM iceberg_db.sales_data FOR SYSTEM_VERSION AS OF 123456789;
```
*(Replace `123456789` with a valid snapshot ID from the previous query.)*

---

### **Query Data from a Specific Timestamp**
```sql
SELECT * FROM iceberg_db.sales_data FOR SYSTEM_TIME AS OF TIMESTAMP '2024-02-01 12:00:00';
```

---

### **Schema Evolution - Add a New Column**
```sql
ALTER TABLE iceberg_db.sales_data ADD COLUMNS (customer_email STRING);
```

---

### **Schema Evolution - Rename a Column**
```sql
ALTER TABLE iceberg_db.sales_data RENAME COLUMN total_amount TO total_price;
```

---

### **Schema Evolution - Drop a Column**
```sql
ALTER TABLE iceberg_db.sales_data DROP COLUMN customer_name;
```

---

## **3️⃣ Advanced Queries (Optimizations, Metadata, Compaction)**

### **View Iceberg Metadata Information**
```sql
SELECT * FROM iceberg_db.sales_data$metadata;
```

---

### **Optimize Table - Merge Small Files**
```sql
CALL iceberg.system.rewrite_data_files('iceberg_db.sales_data');
```

---

### **Optimize Table - Compact Manifests**
```sql
CALL iceberg.system.rewrite_manifests('iceberg_db.sales_data');
```

---

### **Remove Older Snapshots (Data Retention)**
```sql
CALL iceberg.system.expire_snapshots('iceberg_db.sales_data') WHERE committed_at < TIMESTAMP '2024-01-01 00:00:00';
```

---

### **Set Table Properties for Performance**
```sql
ALTER TABLE iceberg_db.sales_data SET TBLPROPERTIES (
    'write.format.default'='parquet',
    'write.metadata.delete-after-commit.enabled'='true',
    'write.metadata.previous-versions-max'='5'
);
```

---

### **Rollback to a Previous Snapshot**
```sql
CALL iceberg.system.rollback_to_snapshot('iceberg_db.sales_data', 123456789);
```
*(Replace `123456789` with the correct snapshot ID.)*

---

### **Delete Data with Condition**
```sql
DELETE FROM iceberg_db.sales_data WHERE order_date < TIMESTAMP '2024-01-01 00:00:00';
```

---

### **Upsert Data Using MERGE INTO (Update + Insert)**
```sql
MERGE INTO iceberg_db.sales_data AS target
USING (SELECT 1 AS order_id, 'Charlie' AS customer_name, 400.00 AS total_price, TIMESTAMP '2024-02-03 15:00:00' AS order_date) AS source
ON target.order_id = source.order_id
WHEN MATCHED THEN UPDATE SET total_price = source.total_price
WHEN NOT MATCHED THEN INSERT VALUES (source.order_id, source.customer_name, source.total_price, source.order_date);
```

---

### **Insert Overwrite (Replace Existing Data)**
```sql
INSERT OVERWRITE iceberg_db.sales_data 
SELECT * FROM iceberg_db.sales_data WHERE order_date >= TIMESTAMP '2024-01-01 00:00:00';
```

---

### **View Table History (Snapshots & Metadata)**
```sql
SELECT * FROM iceberg_db.sales_data$history;
```

---

### **Expire Old Data and Keep Only Latest Snapshots**
```sql
CALL iceberg.system.expire_snapshots(
  table => 'iceberg_db.sales_data',
  retain_last => 5
);
```

---

## **🎯 Summary**
| **Category** | **Queries** |
|-------------|-------------|
| 🟢 **Basic** | `CREATE`, `INSERT`, `SELECT` |
| 🔵 **Intermediate** | `PARTITIONING`, `TIME TRAVEL`, `SCHEMA EVOLUTION` |
| 🔴 **Advanced** | `DATA OPTIMIZATION`, `MERGE`, `EXPIRE SNAPSHOTS` |

---