#install.packages("readr")
#install.packages("lubridate")

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
aggregated_weather$date <- as.POSIXct(aggregated_weather$date, format = "%Y-%m-%d %H:%M:%S")
##Check for data not received 
colSums(aggregated_weather== 9999, na.rm = TRUE)
#PLOT temperature over time
plot(aggregated_weather$date, 
     aggregated_weather$temp_max,
     type = "l", xlab = "Date", ylab = "Temperature", 
     col = "blue", 
     ylim = range(c(aggregated_weather$temp_max, aggregated_weather$temp_min)))
lines(aggregated_weather$date, aggregated_weather$temp_min, col = "red")
legend("topleft", legend = c("Max Temp", "Min Temp"), col = c("blue", "red"), lty = 1)
##see if any years are left out
aggregated_weather$year <- format(aggregated_weather$date, "%Y")
table(aggregated_weather$year) #no year is left out
#PLOT precipitation 
plot(aggregated_weather$date,aggregated_weather$precip, type="l")
#Plot how much it rained each year 
rainfall_by_year <- aggregate(precip ~ year, data = aggregated_weather, FUN = sum, na.rm = TRUE)
barplot(rainfall_by_year$precip, names.arg = rainfall_by_year$year, xlab = "Year", ylab = "Total Rainfall (mm)", main = "Total Rainfall by Year", col = "skyblue")
rainfall_by_year <- aggregate(precip ~ year, data = aggregated_weather, FUN = sum, na.rm = TRUE)
print(rainfall_by_year)
library(ggplot2)
#plot snow by year
snow_by_year <- aggregate(snow ~ year, data = aggregated_weather, FUN = sum, na.rm = TRUE)
snow_by_year<- snow_by_year[order(snow_by_year$year),]
ggplot(snow_by_year, aes(year,snow))+
  geom_bar(stat="identity",fill="blue")+
  labs(x = "Year", y = "Total Snowfall (mm)", title = "Total Snowfall by Year") +
  theme_minimal()


# Extract the year and month components from the dates
aggregated_weather$year <- format(aggregated_weather$date, "%Y")
aggregated_weather$month <- format(aggregated_weather$date, "%m")

# Calculate the average temperature for each month and year
average_temp <- aggregate(cbind(temp_max, temp_min) ~ year + month, data = aggregated_weather, FUN = mean)

# Create a line plot of average temperatures for each month with lines connected
ggplot(data = average_temp, aes(x = as.factor(month), y = temp_max, group = year, color = year)) +
  geom_line() +
  geom_point() +
  labs(x = "Month", y = "Average Temperature (°F)", title = "Average Temperature for Each Month") +
  scale_color_discrete(name = "Year") +
  scale_x_discrete(labels = month.abb) +  # Use month abbreviations for x-axis labels
  theme_minimal() +
  theme(legend.position = "top")
library(dplyr)
library(lubridate)
#install.packages("tsibble")
library(tsibble)
library(forecast)
str(aggregated_weather)
# Convert "date" to proper Date format
aggregated_weather$date <- as.Date(aggregated_weather$date, format = "%m/%d/%y")
# Extract month and year from the date
aggregated_weather$month <- format(aggregated_weather$date, "%m")
aggregated_weather$year <- format(aggregated_weather$date, "%Y")

# Creating a monthly time series of average max temperatures
monthly_avg <- aggregated_weather %>%
  mutate(month = floor_date(date, "month")) %>%
  group_by(month) %>%
  summarise(temp_max_avg = mean(temp_max))
# Convert to tsibble for easier handling with forecast package
monthly_avg_ts <- as_tsibble(monthly_avg, index = month)

#Assuming the data starts from January 2013 and is continuous
monthly_ts <- ts(monthly_avg$temp_max_avg, start = c(2013, 1), frequency = 12)

#BUILD MODEL
# Fit an ARIMA model
model_arima <- auto.arima(monthly_ts)

# Check the model summary
summary(model_arima)

#FORECASTING
# Forecast the next 12 months
forecast_arima <- forecast(model_arima, h = 12)

# Plot the forecast
plot(forecast_arima)


##predicitng Snowfall
plot(aggregated_weather$date, aggregated_weather$snow, type = "l", xlab = "Date", ylab = "Snowfall")
cor(aggregated_weather[,-1]) 

##create month and year col
aggregated_weather$date <- as.Date(aggregated_weather$date)
aggregated_weather$year <- format(aggregated_weather$date, "%Y")
aggregated_weather$month <- format(aggregated_weather$date, "%m")

set.seed(123)  # for reproducibility
train_indices <- sample(1:nrow(aggregated_weather), 0.8 * nrow(aggregated_weather))  # 80% for training
train_data <- aggregated_weather[train_indices, ]
test_data <- aggregated_weather[-train_indices, ]

#create regression model 
model <- lm(snow ~ precip + snow_depth + temp_max + temp_min + month + year, data = train_data)
summary(model)

#Use test set to see how well the model is
predictions <- data.frame(predict(model, newdata = test_data))
actuals <- test_data$snow
mean_squared_error <- mean((predictions - actuals)^2)
print(mean_squared_error)

##plot to access model accuracy 
ggplot(data = test_data, aes(x = actuals, y = predictions, color = factor(month))) +
  geom_point(alpha = 0.6) +  # alpha for transparency
  scale_color_brewer(palette = "Paired") +  # Using a pre-defined color palette
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray") +
  labs(x = "Actual Snowfall", y = "Predicted Snowfall", title = "Predicted vs Actual Snowfall",
       color = "Month") +
  theme_minimal()
str(aggregated_weather)
monthly_totals <- aggregate(snow ~ month + year, data = aggregated_weather, FUN = sum)

ggregated_weather$month <- factor(aggregated_weather$month, levels = c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"), ordered = TRUE)

ggplot(monthly_totals, aes(x = month, y = snow, color = year, group = year)) +
  geom_point() +
  geom_line() +
  labs(x = "Month", y = "Total Snowfall", title = "Total Snowfall by Month (Colored by Year)") +
  scale_color_discrete(name = "Year") +
  theme_minimal()
#Create data frame out of predicted values
predicted_monthly <- test_data %>%
  group_by(month) %>%
  summarize(snow = sum(predictions))

# Add a new column for the year 2024
predicted_monthly$year <- "2024"

# Combine the predicted_monthly dataframe with the existing monthly_totals dataframe
combined_data <- rbind(monthly_totals, predicted_monthly)

# Plot the data
ggplot(combined_data, aes(x = month, y = snow, color = year, group = year, linetype = factor(year))) +
  geom_point()
