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

> *"The cheapest electricity is the electricity you don't use at the wrong time."*
