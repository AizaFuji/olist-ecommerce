# Brazilian E-Commerce Analytics — Olist Dataset

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?style=flat&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791?style=flat&logo=postgresql&logoColor=white)
![Tableau](https://img.shields.io/badge/Tableau-Public-E97627?style=flat&logo=tableau&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?style=flat&logo=jupyter&logoColor=white)

An end-to-end data analytics portfolio project — from raw data ingestion to an interactive business dashboard — built on the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (~100K orders, 2016–2018).

🔗 **[View Live Tableau Dashboard →](https://public.tableau.com/views/OlistE-CommerceSalesDashboard_17794179297180/BrazilianE-CommercePerformanceDashboard)**

---

## Table of Contents

- [Project Overview](#project-overview)
- [Key Findings](#key-findings)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Workflow](#workflow)
- [EDA Preview](#eda-preview)
- [How to Run](#how-to-run)
- [Data Source](#data-source)
- [Author](#author)

---

## Project Overview

Olist is a Brazilian marketplace platform connecting small businesses to major e-commerce channels. This project analyzes order, delivery, payment, and review data to surface actionable business insights across five analytical dimensions:

| # | Question |
|---|----------|
| 1 | How did revenue and order volume grow over time? |
| 2 | Which product categories drive the most revenue? |
| 3 | Does faster delivery actually lead to higher review scores? |
| 4 | What are the most popular payment methods? |
| 5 | How does delivery performance vary across Brazilian states? |

---

## Key Findings

**📈 Revenue Growth**
Revenue grew consistently throughout 2017, peaking in **November 2017** — aligned with Black Friday / Cyber Monday — before stabilizing into 2018.

**🛍️ Top Categories**
`health_beauty` led all categories with **R$ 1.4M+** in revenue, followed by `watches_gifts` and `bed_bath_table`. The top 10 categories account for the majority of total platform revenue.

**🚚 Delivery vs. Satisfaction**
Pearson correlation between delivery days and review score is **negative** — faster deliveries consistently receive higher ratings. The boxplot shows a clear drop in median delivery days from 1-star (slowest) to 5-star (fastest) reviews.

**⭐ Review Distribution**
63,481 customers gave a **5-star rating**, but 13,825 gave **1 star** — suggesting a bimodal satisfaction pattern. Customers either love the experience or are strongly disappointed by it.

**💳 Payment Methods**
Credit card dominates as the preferred payment method, frequently used with installments — reflecting typical Brazilian consumer behavior for larger purchases.

---

## Tech Stack

| Layer | Tool |
|---|---|
| Data Storage | PostgreSQL 16 |
| Data Wrangling | SQL (cleaning & analysis queries) |
| EDA & Visualization | Python — pandas, matplotlib, seaborn, SQLAlchemy |
| Dashboard | Tableau Public |
| Environment | python-dotenv, Jupyter Notebook |

---

## Project Structure

```
olist-ecommerce/
├── Data/
│   └── processed/          # Cleaned data for dashboard consumption
├── sql/                    # PostgreSQL scripts (schema, cleaning, analysis)
├── notebooks/              # Jupyter notebooks — EDA & analysis
├── output/
│   └── figures/            # Exported chart PNGs
├── dashboard/              # Tableau & Looker Studio links
├── requirements.txt        # Python dependencies
└── README.md
```

> **Note:** Raw Kaggle CSV files are not committed to this repository. See [Data Source](#data-source) for download instructions.

---

## Workflow

### 1. Data Ingestion & Storage
Raw CSV files from Kaggle were imported into a **PostgreSQL** database. The schema follows the original Olist relational model — orders, customers, products, sellers, reviews, payments, and geolocation tables.

### 2. Data Cleaning (SQL)
Key transformations performed in SQL:
- Joined all relevant tables into a single `clean_orders_master` view
- Filtered out cancelled and unavailable orders
- Computed derived columns: `delivery_days`, `delivery_status` (On Time / Late), `year_month`, `total_item_value`
- Handled missing values in review scores and delivery timestamps

### 3. Exploratory Data Analysis (Python)
Loaded the clean master table via SQLAlchemy and performed EDA across five areas:
- **Revenue Trend** — Monthly revenue & order volume (2017–2018)
- **Top Categories** — Top 10 product categories by total revenue
- **Delivery Performance** — On-time vs. late rates, delivery day distribution
- **Review Score Analysis** — Score distribution + Pearson correlation with delivery speed
- **Payment Methods** — Order volume and average order value by payment type

### 4. Dashboard (Tableau)
Interactive dashboard built in Tableau Public with dynamic filters by state, date range, and product category.

🔗 **[View Live Dashboard →](https://public.tableau.com/views/OlistE-CommerceSalesDashboard_17794179297180/BrazilianE-CommercePerformanceDashboard)**

---

## EDA Preview

| Monthly Revenue | Delivery vs. Review Score | Payment Methods |
|---|---|---|
| ![Monthly Revenue](output/figures/01_monthly_revenue.png) | ![Review & Delivery](output/figures/04_review_delivery.png) | ![Payment Methods](output/figures/05_payment_methods.png) |

---

## How to Run

**Prerequisites:** Python 3.10+, PostgreSQL 16, Jupyter Notebook

```bash
# 1. Clone the repository
git clone https://github.com/AizaFuji/olist-ecommerce.git
cd olist-ecommerce

# 2. Install Python dependencies
pip install -r requirements.txt

# 3. Configure database connection
cp .env.example .env
# Edit .env with your PostgreSQL credentials

# 4. Download the dataset from Kaggle and place CSVs in data/raw/
# https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

# 5. Run SQL scripts to create schema and load data
# (see sql/ directory for ordered scripts)

# 6. Open and run the Jupyter notebooks
jupyter notebook notebooks/
```

---

## Data Source

> Olist. (2018). *Brazilian E-Commerce Public Dataset by Olist*. Kaggle.
> https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

Licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

---

## Author

**Aiza Fuji Sari**
Data Analyst · SQL · Python · Tableau

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/aiza-fuji-sari/)
