# ⚡ Electricity Bill Minimization via Time-of-Use (TOU) Scheduling

> **An Operations Research approach to reducing household electricity costs using Linear Programming and Time-of-Use tariff optimization — implemented in R.**

---

## 📋 Table of Contents

- [Overview](#overview)
- [Problem Statement](#problem-statement)
- [Methodology](#methodology)
- [Dataset](#dataset)
- [Mathematical Formulation](#mathematical-formulation)
- [Results & Key Findings](#results--key-findings)
- [Visualizations](#visualizations)
- [Repository Structure](#repository-structure)
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [How to Run](#how-to-run)
- [Report & Presentation](#report--presentation)
- [Future Work](#future-work)
- [License](#license)

---

## 🔍 Overview

Electricity tariffs under **Time-of-Use (TOU) pricing** vary significantly throughout the day — peak hours carry higher rates, while off-peak hours offer cheaper electricity. Many household appliances (water heaters, washing machines, EV chargers, air conditioners, fans, etc.) are **flexible loads** whose operation can be shifted to cheaper time windows without compromising user comfort.

This project formulates and solves an **integer/linear programming optimization model** to determine the optimal appliance usage schedule that minimizes annual electricity costs while fully satisfying all energy demand requirements.

The entire analysis pipeline — from data ingestion and LP solving to visualization and reporting — is implemented in **R**.

---

## ❓ Problem Statement

Given:
- A dataset of **45,345 household-month records** across 6 appliance categories
- A stochastic tariff rate modeled as **C ~ N(μ, σ²)** with known mean and standard deviation
- **Peak tariff** = 1.2 × mean tariff (Rs. 10.04/kWh)
- **Off-peak tariff** = 0.8 × mean tariff (Rs. 6.70/kWh)

**Goal:** Minimize the total annual electricity bill by scheduling flexible loads to run during off-peak hours, subject to the constraint that all appliance energy demands are fully met.

---

## 🧮 Methodology

### 1. Data Analysis
- Descriptive statistics computed for all appliance usage hours and tariff rates
- Total annual energy demand aggregated per appliance across all household records

### 2. Tariff Modeling
- Tariff treated as a random variable: **C ~ N(8.3696, 0.5770²)** Rs./kWh
- Peak and off-peak tariffs derived as ±20% deviations from the mean

### 3. Linear Programming Optimization
The core optimization is solved using the `lpSolve` package in R:

- **Objective:** Minimize total cost at off-peak tariff → `min Z = c_offpeak × Σxᵢ`
- **Constraint:** Each appliance must meet or exceed its demand → `xᵢ ≥ Rᵢ ∀ i`
- **Non-negativity:** `xᵢ ≥ 0 ∀ i`

### 4. Stochastic Extension
Expected cost and savings are derived analytically under the normal tariff distribution, providing robustness estimates for the optimization results.

### 5. Visualization
Four publication-quality figures generated with `ggplot2`:
- Annual energy demand by appliance
- Cost comparison before vs. after optimization
- Savings contribution pie chart
- Monthly electricity cost trend

---

## 📊 Dataset

**File:** `electricity_bill_dataset.csv`

| Field | Description |
|---|---|
| Appliance categories | Fan, Refrigerator, Air Conditioner, Television, Monitor, Motor Pump |
| Usage hours | Monthly hours of operation per appliance per household |
| Tariff Rate | Electricity tariff in Rs./kWh |
| Electricity Bill | Monthly bill in Rs. |
| Records | 45,345 household-month observations |

### Summary Statistics (n = 45,345)

| Variable | Mean | Std Dev | Min | Median | Max |
|---|---|---|---|---|---|
| Fan (hrs) | 13.99 | 5.47 | 5.0 | 14.0 | 23.0 |
| Refrigerator (hrs) | 21.71 | 1.67 | 17.0 | 22.0 | 23.0 |
| Air Conditioner (hrs) | 1.50 | 2.50 | 0.0 | 1.0 | 23.0 |
| Television (hrs) | 12.50 | 6.77 | 0.0 | 14.0 | 23.0 |
| Monitor (hrs) | 2.86 | 3.00 | 0.0 | 2.0 | 23.0 |
| Tariff Rate (Rs./kWh) | 8.37 | 0.58 | 7.40 | 8.40 | 9.30 |
| Electricity Bill (Rs.) | 4,311.8 | 1,073.9 | 807.5 | 4,299.4 | 8,286.3 |

---

## 📐 Mathematical Formulation

### Decision Variables
Let **xᵢ** = total energy allocated to appliance *i* during off-peak hours (kWh/year), for i ∈ {Fan, Refrigerator, AC, TV, Monitor, MotorPump}.

### Objective Function

$$\min Z = c_{off} \sum_{i=1}^{n} x_i$$

where $c_{off} = 0.8 \times \bar{c} = 6.6957$ Rs./kWh

### Constraints

$$x_i \geq R_i \quad \forall i \quad \text{(Demand Satisfaction)}$$

$$x_i \geq 0 \quad \forall i \quad \text{(Non-negativity)}$$

### Annual Demand Vector (Rᵢ)

| Appliance | Annual Demand (kWh) |
|---|---|
| Fan | 6,34,408 |
| Refrigerator | 9,84,234 |
| Air Conditioner | 68,197 |
| Television | 5,66,932 |
| Monitor | 1,29,916 |
| **Total** | **23,83,687** |

---

## 📈 Results & Key Findings

### Optimization Summary

| Metric | Value |
|---|---|
| Total Annual Demand | 23,83,687 kWh |
| Baseline Cost (Peak Tariff) | **Rs. 2,39,42,041** |
| Optimized Cost (Off-Peak Tariff) | **Rs. 1,59,61,361** |
| **Total Annual Savings** | **Rs. 79,80,681** |
| **Saving Percentage** | **33.3%** |
| Cost Efficiency (Savings/Demand) | Rs. 3.35 / kWh |

### Stochastic Results (C ~ N(μ, σ²))

| Metric | Value |
|---|---|
| E[Z_before] | Rs. 2,39,42,041 |
| E[Z*] | Rs. 1,59,61,361 |
| E[Savings] | Rs. 79,80,681 |
| SD[Z_before] | Rs. 1,60,461 |
| SD[Z*] | Rs. 1,06,974 |

> **Key Insight:** Shifting all flexible household loads from peak to off-peak windows yields a **33.3% reduction** in annual electricity costs — approximately **Rs. 79.8 lakh** on an aggregate basis across the 45,345 household dataset.

---

## 📊 Visualizations

The following figures are generated by `R_Code.R` and saved in the repository:

| Figure | Description | File |
|---|---|---|
| Figure 1 | Annual Energy Demand by Appliance (horizontal bar chart) | `Figure1_annual_energy_demand.jpeg` |
| Figure 2 | Cost Comparison Before vs. After Optimization (grouped bar chart) | `Figure2_cost_comparison (2).jpeg` |
| Figure 3 | Savings Contribution as % of Total Bill (pie chart) | `Figure3_saving_contribution.jpeg` |
| Figure 4 | Monthly Electricity Cost Trend with savings ribbon | `figure4_monthly_cost_trend.png` |

---

## 🗂️ Repository Structure

```
Electricity_bill_minimization/
│
├── R_Code.R                              # Main analysis script (LP + visualizations)
├── electricity_bill_dataset.csv          # Raw household appliance usage dataset
│
├── Electricity_Bill_Minimization_Report.pdf   # Full research report (LaTeX compiled)
├── latex_report_code.tex                 # LaTeX source for the report
├── Presentation_Slides.pdf              # Project presentation slides
│
├── Figure1_annual_energy_demand.jpeg    # Plot: Annual demand by appliance
├── Figure2_cost_comparison (2).jpeg     # Plot: Cost comparison before vs after
├── Figure3_saving_contribution.jpeg     # Plot: Savings contribution pie
├── figure4_monthly_cost_trend.png       # Plot: Monthly cost trend
│
└── README.md                            # Project documentation (this file)
```

---

## 🚀 Getting Started

### Prerequisites

- **R** (version ≥ 4.0.0) — [Download R](https://cran.r-project.org/)
- **RStudio** (recommended) — [Download RStudio](https://posit.co/download/rstudio-desktop/)

### Dependencies

The script auto-installs missing packages on first run. Required packages:

```r
lpSolve   # Linear Programming solver
ggplot2   # Data visualization
dplyr     # Data manipulation
tidyr     # Data reshaping
scales    # Axis formatting helpers
```

---

## ▶️ How to Run

**1. Clone the repository**
```bash
git clone https://github.com/anii0021/Electricity_bill_minimization.git
cd Electricity_bill_minimization
```

**2. Open R or RStudio and run the script**
```r
source("R_Code.R")
```

The script will:
- Auto-install any missing R packages
- Print summary statistics, LP results, and savings analysis to the console
- Render all 4 publication-quality figures inline (or save them if configured)

**3. Expected Console Output (excerpt)**
```
Table 2: Summary Statistics (n = 45,345)
...
LP Solution (lpSolve)
  Solver status : 0   (optimal)
  Optimal x*_i :
    Fan             x* =    634408  R =    634408  Match: YES
    Refrigerator    x* =    984234  R =    984234  Match: YES
    ...

Table 4: Optimization Summary
  Total annual demand D :      2383687 kWh
  Cost before Z_before  : Rs.  23942041
  Cost after  Z*        : Rs.  15961361
  Total savings S       : Rs.   7980680
  Saving fraction       : 33.3%
```

---

## 📄 Report & Presentation

- 📘 **Full Report:** [`Electricity_Bill_Minimization_Report.pdf`](./Electricity_Bill_Minimization_Report.pdf)  
  Covers problem motivation, literature context, mathematical model derivation, LP formulation, sensitivity analysis, and stochastic extension.

- 📊 **Presentation Slides:** [`Presentation_Slides.pdf`](./Presentation_Slides.pdf)  
  Concise slide deck summarizing the methodology, results, and policy implications.

- 📝 **LaTeX Source:** [`latex_report_code.tex`](./latex_report_code.tex)  
  Full source code for the research report, compatible with standard LaTeX compilers (pdflatex / overleaf).

---

## 🔭 Future Work

- **Dynamic scheduling:** Extend the LP to a multi-period (hourly/daily) Mixed-Integer Linear Program (MILP) that respects appliance on/off constraints and user comfort windows
- **Solar integration:** Incorporate rooftop solar generation as a variable reducing grid demand during peak hours
- **Demand response signals:** Integrate real-time utility demand response pricing signals
- **Machine learning forecasting:** Predict per-household usage patterns to personalize scheduling recommendations
- **Multi-objective optimization:** Balance cost minimization against comfort disruption and carbon footprint

---

## 👤 Author

**Ani** — [@anii0021](https://github.com/anii0021)

---

## 📜 License

This project is open-source. Feel free to use, fork, and build upon it with attribution.

---

> *"The cheapest electricity is the electricity you don't use at the wrong time."*
