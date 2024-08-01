
library(readr)
library(lubridate)
dat<- read.csv("Annarborweather.csv")
dat$DATE <- as.Date(dat$DATE,format="%m/%d/%y")
#FIX MISSING VALUES BY CREATING NEW DATA SET
# CORE VALUES=PRCP, SNOW,SNWD,TMAX,TMIN
library(dplyr)
#Create new data frame
core_weather<- dat%>%
  select("DATE","PRCP","SNOW","SNWD","TMAX","TMIN") %>%
  as.data.frame()
colnames(core_weather) <- c("date","precip", "snow", "snow_depth", "temp_max", "temp_min")
#fill in missing values
core_weather$precip[is.na(core_weather$precip)]<-0
core_weather$snow[is.na(core_weather$snow)]<-0
core_weather$snow_depth[is.na(core_weather$snow_depth)]<-0
aggregated_weather<-aggregate(. ~ date, data = core_weather, FUN = mean, na.rm = TRUE)
str(aggregated_weather)

#Create new data frame with just Month,year and avg snow 
# Extract month and year from the date
aggregated_weather$month <- format(aggregated_weather$date, "%m")
aggregated_weather$year <- format(aggregated_weather$date, "%Y")
monthly_totals <- aggregate(snow ~ month + year, data = aggregated_weather, FUN = sum)
str(monthly_totals)
library(forecast)
library(ggplot2)
# Combine 'month' and 'year' columns into a single Date object
monthly_totals$date <- as.Date(paste(monthly_totals$year, monthly_totals$month, "01", sep = "-"))
 ##VISUALIZATION 
# Create a line plot of average temperatures for each month with lines connected
ggplot(data = monthly_totals, aes(x = as.factor(month), y = snow, group = year, color = year)) +
  geom_line() +
  geom_point() +
  labs(x = "Month", y = "Total Snow Fall (mm)", title = "Total Snowfall for Each Month") +
  scale_color_discrete(name = "Year") +
  scale_x_discrete(labels = month.abb) +  # Use month abbreviations for x-axis labels
  theme_minimal() +
  theme(legend.position = "top")
# Convert into a time series object
snow_ts <- ts(monthly_totals$snow, start = c(2013, 1), frequency = 12)

# Print the time series object
print(snow_ts)

start(snow_ts)
end(snow_ts)

#find out if there are any missing values 
sum(is.na(snow_ts))

summary(snow_ts)

plot(snow_ts,ylab="Snowfall (mm)")
  

#compose data into trend,seasonal and random
tsdata <- ts(snow_ts, frequency = 12) 
ddata <- decompose(tsdata, "multiplicative")
plot(ddata)

##this plot shows trendline of snowfall 
plot(snow_ts, ylab="Snowfall (mm)")
abline(reg = lm(snow_ts~time(snow_ts)))

boxplot(snow_ts~cycle(snow_ts), xlab="Month", ylab = "snowfall (mm)", main = "monthly snowfall from 2013-2023")

#create ARIMA model for predictions
mymodel <- auto.arima(snow_ts)

mymodel ##Parameters (1,0,0) adequately fit the data

plot.ts(mymodel$residuals, main="Residuals Plot",xlab="Time",ylab="Residual")

myforecast<- forecast(mymodel, level = c(95), h=10*12)
plot(myforecast, main = "Snowfall Forecast for the Next 10 Years", xlab="Year", ylab="Snowfall (mm)")
abline(reg = lm(snow_ts~time(snow_ts)))
#check accuracy
Box.test(mymodel$resid, lag=5, type="Ljung-Box")
Box.test(mymodel$resid, lag=10, type="Ljung-Box")
Box.test(mymodel$resid, lag=15, type="Ljung-Box")
# Extract actual values from your time series object (snow_ts)
actual_values <- snow_ts

# Extract predicted values from the forecast object
predicted_values <- myforecast$mean

# Calculate Mean Absolute Error (MAE)
mae <- mean(abs(actual_values - predicted_values))
mse <- mean((actual_values - predicted_values)^2)
# Trim longer vector to match the length of the shorter vector
if(length(actual_values) > length(predicted_values)) {
  actual_values <- actual_values[1:length(predicted_values)]
} else if(length(predicted_values) > length(actual_values)) {
  predicted_values <- predicted_values[1:length(actual_values)]
}

# Convert month and year variables to numeric
monthly_totals$month <- as.numeric(monthly_totals$month)
monthly_totals$year <- as.numeric(monthly_totals$year)

# Split data into training and testing sets (80% training, 20% testing)
set.seed(123) # for reproducibility
train_indices <- sample(1:nrow(monthly_totals), 0.8 * nrow(monthly_totals))
train_data <- monthly_totals[train_indices, ]
test_data <- monthly_totals[-train_indices, ]

# Fit regression model
reg_model <- lm(snow ~ month + year, data = train_data)

# Make predictions on test data
predictions <- predict(reg_model, newdata = test_data)

# Calculate error rate (Root Mean Squared Error, RMSE)
error <- sqrt(mean((test_data$snow - predictions)^2))
cat("Root Mean Squared Error (RMSE):", error, "\n")
