## Monte Carlo simulation for a trip to a restaurant

library(ggplot2)
set.seed(1234)
B <- 10000
## Monte Carlo simulation for a trip to a restaurant
leaveOffice <- 17.5       #(17.5 means planning to leave office at 5:30 PM)
leaveDeviation <- 10/60   #(10 mins give or take from the time leaving the office)
carTrip <- 30/60          #(30 mins drive duration)
cartripDeviation <- 10/60 #(10 mins give or take for the drive duration)
parking <- 5/60             #(5 mins to park the car)
reservationTime <- 18.25  #(reservation at 6:15 PM)

convertToTime <- function(x) {
  thehour <- floor(x)
  theminute <- round((x-floor(x))*60)
  timestring <- paste(thehour, ":", theminute, sep="")
  return(timestring)
}

arrivals <- NULL

arrivals <- replicate(B, {
  leaveTime <- runif(1,leaveOffice-leaveDeviation,leaveOffice+leaveDeviation)
  driveDuration <- runif(1,carTrip-cartripDeviation,carTrip+cartripDeviation)
  total <- (leaveTime+driveDuration+parking)
  rbind(data.frame(leaveTime,driveDuration,parking,total))
})

arrivalsdf <- as.data.frame(t(matrix(arrivals, ncol=B)))
colnames(arrivalsdf) <-  c("leaveTime", "driveDuration", "parking", "total")

percentOnTime <- length(which((unlist(arrivalsdf$total)) <= reservationTime))/length(unlist(arrivalsdf$total)) * 100

totaltime <- unlist(arrivalsdf$total)
ggplot() + aes(totaltime) + geom_histogram(color='white', binwidth =.1) +
  geom_vline(xintercept = 18.25, color="brown", size=1.2 ) +
  labs(title = paste("Planning to leave at ", convertToTime(leaveOffice), " - chances of arriving on time or early: ", percentOnTime, "%", sep=""))


