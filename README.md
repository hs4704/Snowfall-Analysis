# ❄ Snowfall Forecasting in Ann Arbor, Michigan

Time series analysis of seasonal snowfall patterns using ARIMA modeling to aid resource planning and evaluate climate trends.

---
## 📌 Overview

This project analyzes seasonal snowfall trends in **Ann Arbor, Michigan** using a time series forecasting model. By modeling and forecasting future snowfall patterns, local governments can:

- Better allocate snow-removal resources
- Minimize weather-related accidents
- Save costs through efficient planning
- Analyze climate change effects on seasonal snowfall

---


## 📁 Dataset Overview

- **Source:** National Centers for Environmental Information (NOAA)
- **Duration:** January 2013 – December 2023
- **Attributes Used:**
  - `Date`
  - `Snowfall (mm)`
- **Original Rows:** ~88,770 observations

The raw data also included precipitation, snow depth, and temperature readings. However, for this project, only `Snowfall` and `Date` were used.

---
## 🧹 Data Preprocessing

Key steps included:

1. **Column Selection:** Kept only `Date` and `Snowfall`
2. **Missing Values:** Replaced null snowfall values with `0` (assumed no snowfall)
3. **Duplicate Dates:** Removed or aggregated duplicates
4. **Monthly Aggregation:** Aggregated daily snowfall totals to monthly totals to:
   - Reduce noise
   - Improve trend visibility
5. **Time-Series Conversion:** Transformed the dataset into time series format for ARIMA modeling

### 📊 Sample Visualizations

<p float="left">
  <img src="https://github.com/user-attachments/assets/52a0449a-4ff3-4c61-8ba6-eb186b525660" width="420" />
  <img src="https://github.com/user-attachments/assets/0bdfaa45-862c-4a5a-94bc-0426a4a6cbb2" width="400" />
</p>

---

## 🤖 Model Selection: ARIMA

For accurate forecasting, the **ARIMA** (AutoRegressive Integrated Moving Average) model was chosen due to:

- Its strength in modeling seasonal trends
- Proven accuracy in weather-related forecasting

The model was implemented in **R** using the `auto.arima()` function from the **forecast** package, which automatically optimizes parameters based on trends and seasonality.

### ⚖️ Model Comparison

| Model               | MAE (Mean Absolute Error) |
|--------------------|---------------------------|
| ARIMA              | 1.593                     |
| Linear Regression  | 16.53                     |

> ✅ **ARIMA outperformed Linear Regression** significantly in predictive accuracy.

---

## 📈 Results & Forecast

The ARIMA model was validated using:

- **Ljung-Box Test** (p-value = 0.087) → residuals are uncorrelated  
- **Residual Analysis** → model fits well

The final 10-year snowfall forecast shows a **declining trend**, indicating potentially reduced snowfall in future winters.

![Forecast Plot](https://github.com/user-attachments/assets/9542fce1-b8a8-4392-8ffc-d7d0a26f4e7e)

---

## ✅ Conclusion

- ❄️ **Snowfall is projected to decrease** in Ann Arbor over the next decade.
- 📊 The **ARIMA model** proved to be highly effective for short-to-medium range weather forecasts.
- 🏛️ City planners can **optimize snow removal resources** and **adjust infrastructure projects** based on forecasted snowfall peaks.

---

## ⚠️ Limitations & Future Work

- ARIMA assumes **linear relationships**, which may oversimplify real-world weather phenomena.
- Long-term forecasts become less reliable.
- Further studies could incorporate:
  - Temperature & precipitation trends
  - Climate change correlations
  - Advanced machine learning models (e.g., LSTM, Prophet)

---

## 🧰 Tools & Technologies

- **Language:** R
- **Libraries:** forecast, ggplot2
- **Model:** ARIMA (`auto.arima()`)

---
