

# Install / load packages
if (!requireNamespace("lpSolve",  quietly = TRUE)) install.packages("lpSolve")
if (!requireNamespace("ggplot2",  quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr",    quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("tidyr",    quietly = TRUE)) install.packages("tidyr")
if (!requireNamespace("scales",   quietly = TRUE)) install.packages("scales")

library(lpSolve)
library(ggplot2)
library(dplyr)
library(tidyr)
library(scales)


# SECTION 3 – DATA

# Total annual demand per appliance (kWh), summed over 45,345
# household-month records (Table 3 of the report).

appliances <- c("Fan", "Refrigerator", "AirConditioner",
                "Television", "Monitor", "MotorPump")

R <- c(
  Fan            = 634408,
  Refrigerator   = 984234,
  AirConditioner =  68197,
  Television     = 566932,
  Monitor        = 129916,
  MotorPump      =      0
)

n <- length(R)          # 6 appliances


# Summary statistics 
summary_stats <- data.frame(
  Variable  = c("Fan", "Refrigerator", "AirConditioner",
                "Television", "Monitor", "TariffRate", "ElectricityBill"),
  Mean      = c(13.99, 21.71,  1.50, 12.50,  2.86,  8.37, 4311.8),
  SD        = c( 5.47,  1.67,  2.50,  6.77,  3.00,  0.58, 1073.9),
  Min       = c( 5.0,  17.0,   0.0,   0.0,   0.0,   7.40,  807.5),
  Q1        = c( 9.0,  22.0,   0.0,   7.0,   1.0,   7.90, 3556.8),
  Median    = c(14.0,  22.0,   1.0,  14.0,   2.0,   8.40, 4299.4),
  Max       = c(23.0,  23.0,  23.0,  23.0,  23.0,   9.30, 8286.3)
)

cat("\nTable 2: Summary Statistics (n = 45,345) \n")
print(summary_stats, row.names = FALSE)



# SECTION 4.1 – TARIFF CONSTRUCTION

c_bar <- 8.3696          # sample mean tariff  (Rs./kWh)
sigma  <- 0.5770         # tariff SD           (Rs./kWh)

c_peak    <- 1.2 * c_bar   # peak tariff    = 10.0436 Rs./kWh
c_offpeak <- 0.8 * c_bar   # off-peak tariff =  6.6957 Rs./kWh

cat("\nTariff Parameters \n")
cat(sprintf("  Mean tariff c_bar      : %.4f Rs./kWh\n", c_bar))
cat(sprintf("  Peak tariff c_p        : %.4f Rs./kWh\n", c_peak))
cat(sprintf("  Off-peak tariff c_o    : %.4f Rs./kWh\n", c_offpeak))
cat(sprintf("  Tariff ratio (p/o)     : %.2f\n",          c_peak / c_offpeak))



# SECTION 4 – LINEAR PROGRAMME  (solved with lpSolve)

#
# min  Z(x) = c_o * sum(x_i)
# s.t. x_i >= R_i   for all i        (demand satisfaction)
#      x_i >= 0     for all i        (non-negativity)
#
# In lpSolve the constraints must be written as:
#   A %*% x  [dir]  rhs
# Here A = I_n (identity), dir = ">=", rhs = R.
# The non-negativity bound is handled implicitly (lpSolve default).

obj_coeff <- rep(c_offpeak, n)      # objective coefficients

A   <- diag(n)                      # constraint matrix  (I_6)
dir <- rep(">=", n)                 # all >= constraints
rhs <- R                            # right-hand side = annual demand

lp_result <- lp(
  direction      = "min",
  objective.in   = obj_coeff,
  const.mat      = A,
  const.dir      = dir,
  const.rhs      = rhs
)

x_star <- lp_result$solution
names(x_star) <- appliances

cat("\nLP Solution (lpSolve)\n")
cat(sprintf("  Solver status : %s\n", lp_result$status))    # 0 = optimal
cat("  Optimal x*_i  :\n")
for (i in seq_along(appliances)) {
  cat(sprintf("    %-15s  x* = %10.0f   R = %10.0f   Match: %s\n",
              appliances[i], x_star[i], R[i],
              ifelse(abs(x_star[i] - R[i]) < 1e-6, "YES", "NO")))
}



# SECTION 4.4 – COST ANALYSIS & SAVINGS
cost_before <- c_peak    * R          # per-appliance baseline cost
cost_after  <- c_offpeak * x_star     # per-appliance optimised cost
savings     <- cost_before - cost_after

Z_before <- sum(cost_before)
Z_star   <- sum(cost_after)
S_total  <- Z_before - Z_star

saving_frac <- S_total / Z_before
D_total     <- sum(R)
efficiency  <- S_total / D_total

cat("\nTable 3: Appliance-Level Annual Cost Breakdown \n")
results_df <- data.frame(
  Appliance = appliances,
  R_kWh     = R,
  Before_Rs = round(cost_before),
  After_Rs  = round(cost_after),
  Saving_Rs = round(savings)
)
print(results_df, row.names = FALSE)

cat("\nTable 4: Optimization Summary \n")
cat(sprintf("  Total annual demand D   : %13.0f kWh\n",   D_total))
cat(sprintf("  Cost before  Z_before   : Rs. %12.0f\n",   Z_before))
cat(sprintf("  Cost after   Z*         : Rs. %12.0f\n",   Z_star))
cat(sprintf("  Total savings S         : Rs. %12.0f\n",   S_total))
cat(sprintf("  Saving fraction         : %.1f%%\n",        saving_frac * 100))
cat(sprintf("  Efficiency ratio E=S/D  : Rs. %.2f / kWh\n", efficiency))



# SECTION 4.5 – STOCHASTIC EXTENSION  C ~ N(mu, sigma^2)

# E[Z_before] = 1.2 * mu * D,  E[Z*] = 0.8 * mu * D
# SD[Z_before] = 1.2 * sigma * D,  SD[Z*] = 0.8 * sigma * D

E_Z_before <- 1.2 * c_bar * D_total
E_Z_star   <- 0.8 * c_bar * D_total
E_S        <- E_Z_before - E_Z_star

SD_Z_before <- 1.2 * sigma * D_total
SD_Z_star   <- 0.8 * sigma * D_total

cat("\nStochastic Extension (C ~ N(mu, sigma^2))\n")
cat(sprintf("  E[Z_before]   : Rs. %12.0f\n",  E_Z_before))
cat(sprintf("  E[Z*]         : Rs. %12.0f\n",  E_Z_star))
cat(sprintf("  E[S]          : Rs. %12.0f\n",  E_S))
cat(sprintf("  SD[Z_before]  : Rs. %12.0f\n",  SD_Z_before))
cat(sprintf("  SD[Z*]        : Rs. %12.0f\n",  SD_Z_star))



# SECTION 4.6 – ILLUSTRATIVE CALCULATION: FAN

R_fan        <- R["Fan"]
Z_fan_before <- c_peak    * R_fan
Z_fan_star   <- c_offpeak * R_fan
S_fan        <- Z_fan_before - Z_fan_star

cat("\nSection 4.6: Fan Appliance (Step-by-step)\n")
cat(sprintf("  R_Fan           : %10.0f kWh\n",  R_fan))
cat(sprintf("  Z_Fan before    : Rs. %10.0f\n",   Z_fan_before))
cat(sprintf("  Z_Fan after     : Rs. %10.0f\n",   Z_fan_star))
cat(sprintf("  S_Fan           : Rs. %10.0f (%.1f%%)\n",
            S_fan, S_fan / Z_fan_before * 100))



# SECTION 4.7 / FIGURE 1 – Annual Energy Demand by Appliance
demand_df <- data.frame(
  Appliance = factor(appliances[appliances != "MotorPump"],
                     levels = rev(c("Fan","Refrigerator","AirConditioner",
                                    "Television","Monitor"))),
  Demand    = R[appliances != "MotorPump"]
)

fig1 <- ggplot(demand_df, aes(x = Demand, y = Appliance, fill = Appliance)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(formatC(Demand, format = "d", big.mark = ","), " kWh")),
            hjust = -0.05, size = 3.5) +
  scale_x_continuous(
    labels = label_number(scale = 1e-5, suffix = "L"),
    expand = expansion(mult = c(0, 0.15))
  ) +
  scale_fill_manual(values = c("Fan"            = "#1f77b4",
                               "Refrigerator"   = "#2ca02c",
                               "AirConditioner" = "#d62728",
                               "Television"     = "#9467bd",
                               "Monitor"        = "#ff7f0e")) +
  labs(title = "Figure 1: Annual Energy Demand by Appliance",
       x = "Total Annual Demand (kWh)", y = NULL) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", hjust = 0.5))

print(fig1)



# FIGURE 2 – Cost Comparison Before vs After (by appliance)

cost_df <- data.frame(
  Appliance = rep(appliances[appliances != "MotorPump"], 2),
  Period    = rep(c("Before (Peak Tariff)", "After (Off-Peak Tariff)"), each = 5),
  Cost      = c(cost_before[appliances != "MotorPump"],
                cost_after [appliances != "MotorPump"])
)
cost_df$Appliance <- factor(cost_df$Appliance,
                            levels = c("Fan","Refrigerator","AirConditioner",
                                       "Television","Monitor"))
cost_df$Period <- factor(cost_df$Period,
                         levels = c("Before (Peak Tariff)", "After (Off-Peak Tariff)"))

fig2 <- ggplot(cost_df, aes(x = Appliance, y = Cost / 1e6, fill = Period)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Before (Peak Tariff)"   = "#e74c3c",
                               "After (Off-Peak Tariff)" = "#2ecc71")) +
  scale_y_continuous(labels = label_dollar(prefix = "\u20b9", suffix = "M")) +
  labs(title = "Figure 2: Cost Comparison by Appliance — Before vs After",
       x = NULL, y = "Annual Cost (Rs. Million)", fill = NULL) +
  theme_minimal(base_size = 12) +
  theme(plot.title  = element_text(face = "bold", hjust = 0.5),
        legend.position = "top")

print(fig2)



# FIGURE 3a – Savings Contribution Pie Chart

pie_df <- data.frame(
  Category = c("Optimized Cost\nRs. 1.60 Cr (66.7%)",
               "Savings\nRs. 0.80 Cr (33.3%)"),
  Value    = c(Z_star, S_total)
)

fig3a <- ggplot(pie_df, aes(x = "", y = Value, fill = Category)) +
  geom_col(width = 1) +
  coord_polar(theta = "y") +
  scale_fill_manual(values = c("#3498db", "#f39c12")) +
  labs(title = "Figure 3: Savings Contribution to Total Bill", fill = NULL) +
  theme_void(base_size = 12) +
  theme(plot.title      = element_text(face = "bold", hjust = 0.5),
        legend.position = "right")

print(fig3a)



# FIGURE 4 – Monthly Electricity Cost Trend

# Simulate monthly demand proportional to overall annual totals
# (the dataset spans 12 months; we distribute uniformly as a proxy).
set.seed(42)
months <- month.abb   # Jan … Dec

# Monthly share: in reality this would come from the raw dataset.
# We approximate with equal 1/12 shares per the report's uniform monthly figure.
monthly_share <- rep(1/12, 12)

monthly_before <- Z_before * monthly_share
monthly_after  <- Z_star   * monthly_share
monthly_saving <- monthly_before - monthly_after

monthly_df <- data.frame(
  Month  = factor(months, levels = months),
  Before = monthly_before / 1e6,
  After  = monthly_after  / 1e6,
  Saving = monthly_saving / 1e6
)

monthly_long <- pivot_longer(monthly_df, cols = c(Before, After),
                             names_to = "Period", values_to = "Cost")
monthly_long$Period <- ifelse(monthly_long$Period == "Before",
                              "Before Optimization (Peak Tariff)",
                              "After Optimization (Off-Peak Tariff)")
monthly_long$Period <- factor(monthly_long$Period,
                              levels = c("Before Optimization (Peak Tariff)",
                                         "After Optimization (Off-Peak Tariff)"))

fig4 <- ggplot() +
  geom_ribbon(data = monthly_df,
              aes(x = as.numeric(Month),
                  ymin = After, ymax = Before),
              fill = "#ffeaa7", alpha = 0.7) +
  geom_line(data = monthly_long,
            aes(x = as.numeric(Month), y = Cost, colour = Period), size = 1) +
  geom_point(data = monthly_long,
             aes(x = as.numeric(Month), y = Cost, colour = Period), size = 2) +
  scale_x_continuous(breaks = 1:12, labels = months) +
  scale_colour_manual(values = c("Before Optimization (Peak Tariff)"  = "#e74c3c",
                                 "After Optimization (Off-Peak Tariff)" = "#2ecc71")) +
  labs(title  = "Figure 4: Monthly Electricity Cost Trend",
       x = "Month", y = "Monthly Cost (Rs. Million)",
       colour = NULL) +
  theme_minimal(base_size = 12) +
  theme(plot.title      = element_text(face = "bold", hjust = 0.5),
        legend.position = "top",
        axis.text.x     = element_text(angle = 45, hjust = 1))

print(fig4)




cat("\n Done \n")

