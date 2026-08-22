# 📊 End-to-End Credit Risk & Portfolio Performance Analytics

![Power BI](https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-150458?style=for-the-badge&logo=pandas&logoColor=white)

## 📌 Executive Summary

This enterprise-grade **End-to-End Data Analytics Pipeline** evaluates credit risk exposure, borrower default probabilities, and portfolio concentration for a **$304.62M consumer loan portfolio**.

By extracting raw data from Kaggle, transforming it through Python ETL pipelines, staging and querying it within PostgreSQL, and designing a dynamic, localized Power BI application, this project delivers actionable intelligence to optimize credit underwriting policies, reduce non-performing loans (NPLs), and establish automated risk thresholds — uncovering the precise demographic and behavioral drivers of loan defaults.

---

## 🎯 Business Problem & Objectives

Financial institutions face substantial capital loss when default rates breach acceptable operational limits. The primary objective of this project is to move beyond static reporting and deliver an interactive risk management system:

1. **Identify Critical Default Hotspots** — Pinpoint exact combinations of borrower attributes (Housing status, Age, Loan Grade, Historical Default) driving disproportionate credit loss.
2. **Evaluate Underwriting Scoring Systems** — Test whether assigned credit grades (Grade A through G) reflect true underlying default behavior and locate the exact "risk breakpoint."
3. **Analyze Debt Consolidation Vulnerability** — Assess the risk profile of high-risk loan intentions (e.g., refinancing existing debt vs. capital investment).
4. **Optimize Underwriting Strategies** — Evaluate the performance of different loan grades (A-G) and loan intents to adjust future interest rates and approval criteria.
5. **Deliver Executive Decision Tools** — Build a self-service BI dashboard featuring custom view toggling, conditional heatmap rules, and one-click filter resets, allowing risk executives to seamlessly drill down from high-level portfolio KPIs to granular risk heatmaps.

---

## 🏗️ Tech Stack & End-to-End Data Architecture

The project implements a full production-style data analytics pipeline:

```
[Kaggle Raw CSV] ──> [Python / Pandas ETL] ──> [PostgreSQL Database] ──> [SQL Analysis] ──> [Power BI Dashboard]
```

**1. Data Source**
- Kaggle Credit Risk Dataset.

**2. Extraction & Transformation (Python)**
- Cleaned null values using median imputation (`person_emp_length` and `loan_int_rate` grouped by loan grade).
- Removed statistical anomalies and extreme outliers.
- Engineered new dimensional columns using `Pandas`: `age_group` (18-25, 26-35, 36-50, 50+) and `loan_risk_tier` (Aşağı Risk, Orta Risk, Yüksək Risk).

**3. Database Staging & Querying (PostgreSQL)**
- Exported the transformed data to a relational PostgreSQL database via `SQLAlchemy`.
- Executed 5 core analytical SQL scripts to calculate baseline portfolio KPIs, cross-tabulations, and risk matrices, validating aggregations and extracting preliminary analytical insights.

**4. Data Visualization & UX (Power BI)**
- Designed an interactive dashboard localized in Azerbaijani for regional business stakeholders.
- Implemented custom DAX measures, dynamic bookmark navigation (Charts View vs. Matrix View), 5-tier conditional formatting heatmaps, micro-sparklines inside KPI cards, and an automated slicer reset button.

---

## 🐍 Python ETL Pipeline & Data Cleaning

Executed inside `scripts/01_credit_risk_data_cleaning.ipynb`:

**Missing Value Imputation**
- Imputed missing employment length (`person_emp_length`) using the column median.
- Imputed missing interest rates (`loan_int_rate`) using the median rate corresponding to each loan grade (`loan_grade`).

**Feature Engineering Logic**
- `age_group`: Segmented `person_age` into discrete brackets (18-25, 26-35, 36-50, 50+).
- `loan_risk_tier`: Categorized `loan_percent_income` into:
  - `< 0.15` → Aşağı Risk
  - `0.15 – 0.25` → Orta Risk
  - `>= 0.25` → Yüksək Risk

---

## 🗄️ Analytical SQL Queries & Empirical Findings

Prior to visualization, the data was rigorously analyzed in PostgreSQL using 5 core queries, executed via `scripts/02_credit_risk_queries.sql`:

| # | Script | Purpose |
|---|---|---|
| 1 | `01_table_inspection.sql` | Schema verification and data integrity checks |
| 2 | `02_portfolio_kpi_summary.sql` | Calculated core portfolio metrics, establishing the baseline 21.59% default rate |
| 3 | `03_default_by_grade_and_intent.sql` | Grouped default rates by credit scores (A-G) and borrower intent (Medical, Education, Debt Consolidation) |
| 4 | `04_risk_tier_and_history_analysis.sql` | Cross-analyzed debt-to-income tiers against historical default records to map severe risk clusters |
| 5 | `05_homeownership_age_matrix.sql` | Investigated the demographic correlation between renting status, youth (18-25), and default likelihood |

### 1. Overall Portfolio & Default KPIs

Establishes the baseline parameters of the total credit portfolio. Out of $304.62M in total issued loans across 31,522 applicants, $75.03M is currently exposed to default risk, resulting in an overall default rate of 21.59%.

```sql
SELECT 
    COUNT(*) AS Toplam_Müştəri,
    ROUND(SUM(loan_amnt), 2) AS Toplam_Kredit_Məbləği,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2) AS Riskdə_Olan_Məbləğ,
    ROUND(AVG(loan_status) * 100, 2) AS Defolt_Faizi_Pct,
    ROUND(AVG(loan_int_rate), 2) AS Orta_Faiz_Dərəcəsi
FROM cleaned_credit_risk_dataset;
```

| Toplam Müştəri | Toplam Kredit Məbləği ($) | Riskdə Olan Məbləğ ($) | Defolt Faizi (%) | Orta Faiz Dərəcəsi (%) |
|---|---|---|---|---|
| 31,522 | $304,621,400.00 | $75,032,850.00 | 21.59% | 11.04% |

### 2. Risk Distribution by Loan Intent

Evaluates default likelihood across different loan purposes. Debt Consolidation (28.45%) and Medical Expenses (26.60%) hold the highest risk profiles, whereas Venture/Business (14.70%) represents the safest utilization.

```sql
SELECT 
    loan_intent AS Kredit_Məqsədi,
    COUNT(*) AS Müraciət_Sayı,
    ROUND(SUM(loan_amnt), 2) AS Toplam_Məbləğ,
    ROUND(AVG(loan_int_rate), 2) AS Orta_Faiz,
    ROUND(AVG(loan_status) * 100, 2) AS Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY loan_intent
ORDER BY Defolt_Faizi_Pct DESC;
```

| Kredit Məqsədi (Loan Intent) | Müraciət Sayı | Toplam Məbləğ ($) | Orta Faiz (%) | Defolt Faizi (%) |
|---|---|---|---|---|
| DEBT CONSOLIDATION | 5,044 | $48,820,500.00 | 11.02% | 28.45% |
| MEDICAL | 5,869 | $54,949,800.00 | 11.08% | 26.60% |
| HOME IMPROVEMENT | 3,499 | $36,568,550.00 | 11.21% | 25.61% |
| PERSONAL | 5,346 | $51,577,825.00 | 11.02% | 19.51% |
| EDUCATION | 6,246 | $59,453,450.00 | 10.99% | 16.99% |
| VENTURE | 5,518 | $53,251,275.00 | 10.99% | 14.70% |

### 3. Scoring Grade Breakpoint Analysis

Examines actual default rates against internal credit risk grades (A to G). The analysis reveals a massive non-linear jump at Grade D (58.78%), ascending to 98.44% for Grade G.

```sql
SELECT 
    loan_grade AS Risk_Dərəcəsi,
    COUNT(*) AS Müştəri_Sayı,
    ROUND(AVG(loan_int_rate), 2) AS Orta_Faiz_Dərəcəsi,
    ROUND(AVG(loan_amnt), 2) AS Orta_Kredit_Məbləği,
    ROUND(AVG(loan_status) * 100, 2) AS Faktiki_Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY loan_grade
ORDER BY loan_grade ASC;
```

| Risk Dərəcəsi (Grade) | Müştəri Sayı | Orta Faiz Dərəcəsi (%) | Orta Kredit Məbləği ($) | Faktiki Defolt Faizi (%) | Risk Profile |
|---|---|---|---|---|---|
| A | 10,300 | 7.69% | $8,606.85 | 9.56% | Stable Low Risk |
| B | 10,121 | 11.00% | $10,070.85 | 15.97% | Moderate Risk |
| C | 6,301 | 13.21% | $9,283.14 | 20.31% | Acceptable Risk |
| D | 3,549 | 14.97% | $10,890.41 | 58.78% | 🚨 Severe Breakpoint |
| E | 951 | 16.49% | $12,942.40 | 64.25% | High Risk |
| F | 236 | 17.73% | $14,796.08 | 70.34% | Critical Exposure |
| G | 64 | 19.53% | $17,195.70 | 98.44% | Near Total Default |

### 4. Cross-Sectional Analysis: Debt Tier x Historical Default

Cross-analyzes income burden (`loan_risk_tier`) against credit history records (`cb_person_default_on_file`). Applicants in the Yüksək Risk tier with a prior default history suffer an extreme default rate of 83.33%.

```sql
SELECT 
    loan_risk_tier AS Borc_Yükü_Səviyyəsi,
    CASE WHEN cb_person_default_on_file = 1 THEN 'Bəli' ELSE 'Xeyr' END AS Keçmişdə_Defolt_Olub,
    COUNT(*) AS Müştəri_Sayı,
    ROUND(AVG(loan_status) * 100, 2) AS Cari_Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY loan_risk_tier, cb_person_default_on_file
ORDER BY loan_risk_tier, Cari_Defolt_Faizi_Pct DESC;
```

| Borc Yükü Səviyyəsi | Keçmişdə Defolt Olub? | Müştəri Sayı | Cari Defolt Faizi (%) |
|---|---|---|---|
| Yüksək Risk | Bəli | 222 | 83.33% 🚨 |
| Yüksək Risk | Xeyr | 838 | 72.55% |
| Orta Risk | Bəli | 1,900 | 49.26% |
| Orta Risk | Xeyr | 7,734 | 30.05% |
| Aşağı Risk | Bəli | 3,492 | 28.38% |
| Aşağı Risk | Xeyr | 17,336 | 10.17% |

### 5. Demographic Risk (Housing Status x Age Group)

Investigates the relationship between homeownership, age brackets, and debt obligations. Borrowers who RENT demonstrate elevated default rates across all age groups (29.71% – 35.00%), whereas homeowners (OWN) exhibit low risk (5.00% – 7.47%).

```sql
SELECT 
    person_home_ownership AS Mənzil_Statusu,
    age_group AS Yaş_Qrupu,
    COUNT(*) AS Müştəri_Sayı,
    ROUND(AVG(loan_percent_income) * 100, 2) AS Gəlirə_Borc_Nisbəti_Pct,
    ROUND(AVG(loan_status) * 100, 2) AS Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY person_home_ownership, age_group
ORDER BY person_home_ownership, Defolt_Faizi_Pct DESC;
```

| Mənzil Statusu | Yaş Qrupu | Müştəri Sayı | Gəlirə Borc Nisbəti (%) | Defolt Faizi (%) |
|---|---|---|---|---|
| RENT | 50+ | 160 | 18.36% | 35.00% |
| RENT | 18-25 | 7,876 | 18.57% | 32.41% |
| RENT | 26-35 | 6,490 | 17.85% | 29.77% |
| RENT | 36-50 | 1,481 | 17.69% | 29.71% |
| OTHER | 18-25 | 64 | 19.94% | 32.81% |
| OTHER | 36-50 | 13 | 12.38% | 30.77% |
| OTHER | 26-35 | 29 | 20.31% | 27.59% |
| MORTGAGE | 50+ | 99 | 13.07% | 14.14% |
| MORTGAGE | 18-25 | 5,724 | 15.57% | 12.70% |
| MORTGAGE | 26-35 | 5,860 | 14.86% | 12.42% |
| MORTGAGE | 36-50 | 1,335 | 14.55% | 11.84% |
| OWN | 18-25 | 1,125 | 18.83% | 7.47% |
| OWN | 36-50 | 259 | 18.31% | 6.95% |
| OWN | 26-35 | 987 | 18.63% | 6.38% |
| OWN | 50+ | 20 | 15.15% | 5.00% |

---

## 🖼️ Interactive Power BI Dashboard

The report consists of two synchronized view states managed via Bookmarks & Selection Panes:

### 1. Executive Overview Dashboard
Visualizes core portfolio metrics, interest rate distribution, purpose-wise risk, and age demographics. Features dynamic KPI cards with embedded **Sparkline trend lines**, providing an immediate pulse on the portfolio's health (Total Loan Amount, Default Rate %, Portfolio Risk %, Avg Interest Rate).

> ![Executive Overview](images/overview_dashboard.png)

### 2. Deep-Dive Risk Heatmap Matrix
Toggles into a detailed matrix cross-analyzing Housing Status, Loan Grade, and Age Groups, highlighted by a **5-tier conditional formatting color scale** (0% to 100%). This reveals the cross-sectional risk between Homeownership, Loan Grade, and Age Groups.

> ![Matrix Heatmap](images/matrix_heatmap_view.png)

### Key Interactivity & UI Engineering Features

- **Dynamic Bookmark Toggling** — Navigation icons at the top right toggle seamlessly between the Visual Overview and Matrix Heatmap without clearing user-selected slicer states (Data option turned OFF in Bookmark properties).
- **5-Tier Conditional Formatting (Heatmap Rules)**:
  - 0% – 10% → `#10B981` (Emerald Green - Low Risk)
  - 10% – 20% → `#A3E635` (Lime Green - Acceptable)
  - 20% – 30% → `#FBBF24` (Amber Yellow - Moderate Risk)
  - 30% – 50% → `#F97316` (Orange - Elevated Risk)
  - 50% – 100% → `#DC2626` (Crimson Red - Critical Risk)
- **Micro Trend Sparklines** — Custom Area Charts embedded within KPI cards showing trend behavior across employment length (`person_emp_length`).
- **One-Click Reset Button** — Custom "Reset Slicers" button configured with Clear all slicers / Data = ON action to instantly return the application to its baseline state.
- **Custom Navigation** — Bookmark action buttons to toggle between charts and matrix views without losing filter context.

---

## 💡 Key Business Insights

- **The Renters Risk Hotspot**: Renting status (RENT) is a strong driver of credit default. Renters across all age groups exhibit default rates between 29.71% and 35.00%, compared to under 7.50% for property owners (OWN). Renters who additionally fall into lower credit grades (E, F, G) exhibit even more extreme default rates, ranging from **70% up to 87.27%**.
- **Grade D Credit Breakpoint**: Assigned interest rates fail to compensate for the exponential risk jump occurring at Grade D. Default rates surge from 20.31% (Grade C) to 58.78% (Grade D), eventually reaching 98.44% (Grade G).
- **Debt-to-Income is Critical**: The engineered `loan_risk_tier` proved highly predictive of behavior. Customers categorized in the **Yüksək Risk (High Risk)** tier default at rates as high as **74.81%**, compared to just **13.22%** for low-risk borrowers.
- **Refinancing Vulnerability**: Loans for Debt Consolidation (28.45%) and Medical Expenses (26.60%) present significant default exposure, signaling that refinancing pre-existing debt carries higher default risk than wealth-building/venture loans (14.70%).
- **Historical Default Repeatability**: Past credit behavior is highly predictive. Borrowers with a prior default on record ("Keçmiş Defolt Qeydi = Bəli") who fall into the Yüksək Risk tier default at 83.33%, validating the necessity of strict historical background checks.

---

## 🛡️ Strategic Recommendations for Credit Risk Executive Leadership

1. **Automated Hard Cut-Off Rule** — Implement an automated hard rejection rule in the loan origination system for any applicant combining High Risk Tier and Prior Default Record (where default rate reaches 83.33%).
2. **Underwriting Halt on Uncollateralized Grade D–G Loans** — Instantly cap unsecured lending for Grade D, E, F, and G loans. Mandate tangible asset collateral or high-credit guarantors before issuing approval. The risk heatmap dictates that Grade F and G loans are economically unviable, so approvals for these grades should be ceased or require substantial collateral.
3. **Stricter Underwriting for Renters** — Implement tighter debt-to-income caps for non-homeowners, specifically those aged 18-25, as they represent the most volatile demographic.
4. **Targeted Limits & Restructuring on Debt Consolidation** — Apply tighter Debt-To-Income (DTI) caps for applicants requesting Debt Consolidation loans, particularly if the applicant is currently renting. Given the high default rate (28.45%), these loans should require mandatory financial counseling or co-signers to mitigate exposure.
5. **Housing-Weighted Credit Scoring** — Re-weight credit scoring models to assign higher risk-weights to non-homeowners (RENT), while offering preferred interest rates to homeowners (OWN).
6. **Automated Flagging** — Integrate the High-Risk Tier parameters directly into the credit approval API to automatically flag or reject applications exceeding the defined debt-to-income threshold.

---

## 📁 Repository File Structure

```
credit-risk-analytics/
│
├── data/
│   ├── credit_risk_dataset.csv           # Raw Kaggle source dataset
│   └── cleaned_credit_risk_dataset.csv   # Processed ETL output dataset
│
├── scripts/
│   ├── 01_credit_risk_data_cleaning.ipynb # Python ETL (Pandas, Imputation, Feature Engineering)
│   └── 02_credit_risk_queries.sql         # 5 Analytical PostgreSQL risk queries
│
├── images/
│   ├── overview_dashboard.png            # Dashboard Overview screenshot
│   └── matrix_heatmap_view.png           # Matrix Heatmap View screenshot
│
├── Credit_Risk_Analysis.pbix             # Primary Power BI Desktop Application
└── README.md                             # Comprehensive Documentation
```

---

## 🚀 Reproduction & Setup Guide

**1. Clone the Repository**
```bash
git clone https://github.com/YOUR_USERNAME/credit-risk-analytics.git
cd credit-risk-analytics
```

**2. Execute Python ETL Pipeline**
- Open and run all cells in `scripts/01_credit_risk_data_cleaning.ipynb`.
- Ensure `cleaned_credit_risk_dataset.csv` is generated.

**3. Setup PostgreSQL Database**
- Create a database named `credit_risk_db`.
- Import `cleaned_credit_risk_dataset.csv` into table `cleaned_credit_risk_dataset`.
- Execute query scripts located in `scripts/02_credit_risk_queries.sql`.

**4. Launch Power BI Dashboard**
- Open `Credit_Risk_Analysis.pbix` using Power BI Desktop.
- Update data source credentials to point to your local PostgreSQL instance or CSV path if prompted.
