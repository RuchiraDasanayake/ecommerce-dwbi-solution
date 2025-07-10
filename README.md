
---

## 🚀 Features

### 🔧 Data Warehouse (Assignment 01)
- **Source**: Brazilian E-Commerce dataset from Kaggle
- **ETL**: Implemented using **SQL Server Integration Services (SSIS)**
- **Schema**: Star schema with one Fact Table and four Dimension Tables
- **SCD Type 2** for Customer Dimension
- **Accumulating Fact Table** tracking transaction lifecycle

### 📦 OLAP & Cube (Assignment 02)
- **SSAS Cube**: Built using SQL Server Analysis Services
- **Hierarchies**: Time (Year → Quarter → Month → Day), Location (State → City)
- **OLAP Operations**: Slice, Dice, Roll-Up, Drill-Down, Pivot (via Excel)

### 📊 Power BI Integration
- Live connection to SSAS cube
- 4 Interactive reports:
  - Matrix Table
  - Cascading Slicers
  - Drill-down Visualizations
  - Drill-through Dashboards

---

## 📎 Dataset

- **Source**: [Brazilian E-Commerce Dataset by Olist on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Files Used**:
  - `olist_orders_dataset.csv`
  - `olist_order_items_dataset.csv`
  - `olist_customers_dataset.csv`
  - `olist_products_dataset.csv`
  - `olist_order_payments_dataset.csv`
  - `olist_sellers_dataset.csv`

---

## 🛠 Tools & Technologies

- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS)
- SQL Server Analysis Services (SSAS)
- Microsoft Excel (OLAP analysis)
- Power BI Desktop
- Visual Studio with SQL Server Data Tools (SSDT)

---

## 👨‍💻 Author

**Ruchira Dasanayake**  

---

## 📜 License

This repository is intended for academic use only.  
Original dataset is available under Kaggle’s terms of use.
