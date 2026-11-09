
# Northwind Retail Analytics & Business Performance Report

This repository contains an end-to-end data analytics project based on the classic Northwind trading database. The project includes PostgreSQL relational data analysis, complex SQL analytical scripts (CTEs, Window Functions, Segmentation), and a 3-page interactive Power BI dashboard.

---

## Executive Summary & Consulting Report

### 1. Problem Statement
Northwind Traders operates as an international B2B specialty food distributor. Managing global inventory, pricing strategies, and customer accounts introduced key operational challenges:
* **Revenue Visibility & Seasonality:** Difficulty isolating core monthly revenue drivers from period-over-period sales fluctuation.
* **Product Inventory Risks:** Identifying active product lines dropping below safety stock levels to prevent order unfulfillment.
* **Customer Concentration:** Lack of clear spend quartiles and RFM-style analytics to differentiate high-value key accounts from high-churn single-order clients.

This project delivers targeted SQL queries and an executive Power BI report to equip management with actionable insights for stock replenishment, pricing optimization, and client retention.

---

### 2. Data & Architecture
The analysis builds upon relational core tables (`orders`, `order_details`, `products`, `categories`, `customers`, and `employees`).

* **Fact Representation:** Transactional line-items joining `orders` and `order_details` to calculate net revenue after discounts.
* **Key Dimensions:**
  * `products` & `categories`: Product details, reorder levels, and line classifications.
  * `customers`: Geographical tracking and account identities across global markets.
  * `employees`: Sales performance tracking per representative.

---

### 3. Methodology
* **a) Data Preparation & ETL:** Cleaned and validated raw transactional tables in PostgreSQL; mapped primary/foreign keys and handled numeric precision casting (`::numeric`).
* **b) Advanced SQL Analytics:** Executed Common Table Expressions (CTEs), window functions (`DISTINCT ON`, `NTILE`, `LAG`, `SUM OVER`), and aggregated pricing logic.
* **c) Data Modeling:** Structured 1-to-many single-direction relationships between dimension tables and transaction records in Power BI.
* **d) Dashboard Development:** Built a 3-page interactive report (*Executive Summary*, *Sales Analysis*, *Customer Analysis*) with dedicated DAX measures.

---

### 4. Key Findings
* **Geographical & Account Concentration:** The United States and Germany represent the largest market shares by total revenue, with top accounts (e.g., QUICK-Stop, Ernst Handel) driving a significant portion of total sales.
* **Product Portfolio Leaders:** Beverages and Dairy Products lead total category revenue, while specific high-ticket items drive maximum overall profitability.
* **Inventory Alerts:** Several active items (e.g., Gorgonzola Telino, Louisiana Hot Spiced Okra) sit below designated reorder levels, requiring immediate purchase orders.
  
* Executive Summary
  
![Executive Summary](https://github.com/user-attachments/assets/855bd896-2755-4ae3-82a8-db08a49a081d)

* Sales Analysis
  
![Sales Analysis](https://github.com/user-attachments/assets/508c9e52-bbb3-461a-8db7-d61ae8539a0f)

* Customer Analysis
  
![Customer Analysis](https://github.com/user-attachments/assets/d3aa3344-5a3d-461c-aa84-39413293e65b)


---

### 5. Strategic Recommendations
* **a) Automated Inventory Triggers:** Set up automated REST/SQL alerts when `units_in_stock <= reorder_level` for non-discontinued items to eliminate stockouts.
* **b) Tiered Customer Loyalty Programs:** Tailor VIP terms for Top Quartile (`NTILE = 1`) customers while re-engaging single-order accounts to increase lifetime value (LTV).
* **c) Discount Standardizations:** Audit high-discount items to ensure price reductions consistently yield proportional increases in total volume sold.

---

### 6. Limitations
* **Historical Scope:** Analyzes static historical transactional data without live streaming database integrations.
* **Cost Granularity:** Lacks internal supplier Cost of Goods Sold (COGS) to calculate net profit margins beyond gross revenue.

---

## KPI Metrics Dictionary

| Metric | DAX / Logic | Description | Business Purpose |
| :--- | :--- | :--- | :--- |
| **Total Revenue** | `SUMX(order_details, unit_price * quantity * (1 - discount))` | Net sales volume after item discounts | Tracks total gross earnings across transactions |
| **Total Orders** | `DISTINCTCOUNT(orders[order_id])` | Count of unique completed orders | Measures operational volume & order throughput |
| **Average Order Value (AOV)** | `DIVIDE([Total Revenue], [Total Orders], 0)` | Average revenue generated per order | Evaluates buyer cart size and spending trends |
| **Total Customers** | `DISTINCTCOUNT(customers[customer_id])` | Count of unique active client accounts | Tracks active customer reach across markets |

---

## Repository Structure

* `northwind_sql_analysis.sql` : PostgreSQL script containing all CTEs, window functions, and analytical queries.
* `README.md` : Project documentation and business report.
