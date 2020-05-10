library(readxl)
library(dplyr)
library(ggplot2)
library(scales)
library(forecast)
library(tsbox)
library(timetk)
library(xts)
library(ggthemes)

usa_covid <- read_excel("C:\\Users\\adity\\Documents\\TableauWork\\Corona\\Worldometer USA.xlsx", sheet = "US Worldometer")

# Create a function using splinef forecast
# n is how many periods in the future
plotWithForecast <- function( chartIndicator, x, y, n) {
  options(warn = -1)
  # Create time series
  datadf <- xts(y, x)
  # Do the n period forecast
  datafcast <- splinef(datadf, h=n)
  
  # Create future dates
  dateidx <- tk_index(datafcast, timetk_idx = TRUE)
  dateidx_future <- tk_make_future_timeseries(dateidx, n_future = n)

  ## Build future data from forecast
  data_future <- cbind(y = datafcast$mean, y.lo = datafcast$lower[,2], y.hi = datafcast$upper[,2])
  dataxts_future <- xts(data_future, dateidx_future)

  # Format original xts object
  rm(dataxts_reformatted)
  rm(dataxts_final)
  dataxts_reformatted <- cbind(y = datadf, y.lo = NA, y.hi = NA)
  
  # Bind current and future
  dataxts_final <- rbind(dataxts_reformatted, dataxts_future)
  max_forecast_Val <- max(dataxts_final$y.hi, na.rm = TRUE)
  
  # Plot current and future
  # set the break intervals on the Y scale
  if (max_forecast_Val <= 10000) {
    breakInt <- 1000
  } else if (max_forecast_Val <= 500000) {
    breakInt <- 25000
  } else if (max_forecast_Val >= 500000) {
    breakInt <- 100000
  }
  
  dataplot <- tk_tbl(dataxts_final) %>%
    ggplot(aes(x = as.Date(index), y = y)) +
    geom_point() +
    geom_line() +
    labs(title = paste("COVID-19 USA", chartIndicator, "with ", toString(n), "Days Forecast with 95% CI"),x ="Date", y=chartIndicator) +
    geom_ribbon(aes(ymin = y.lo, ymax = y.hi), fill = "blue", linetype = "dashed",alpha = 0.1)
  
  dataplot + theme_igray() + 
    scale_x_date(date_labels="%b %d, %Y",date_breaks  ="1 week") +
    scale_y_continuous( labels = point, breaks=seq(0, max_forecast_Val,breakInt)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust=0.1))
}

# Let's run the forecast and see what it looks like!
plotWithForecast("Deaths", usa_covid$Date, usa_covid$Death, 20)
plotWithForecast("Confirmed Cases", usa_covid$Date, usa_covid$Confirmed, 30)
