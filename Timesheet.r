
## This script performs a simple transform of data in a wide format to a long format,
## plus some cleanup for initial Exploratory Data Analysis (EDA)
## The data is in a spreadsheet generated with LibreOffice Calc (ODS format)
## Author: Aditya T. Wresniyandaka

library(readODS)
library(dplyr)
library(tidyr)
library(ggplot2)

## Read the ODS file
tsdata <- readODS::read_ods("C:\\Users\\adity\\Documents\\MachineLearning\\Timesheet.ods")

## Rename the column headers with the abbreviated month names
colnames(tsdata) <- c("Emp Nbr", "Project ID", "Jan",
                          "Feb", "Mar", "Apr", "May",
                          "Jun", "Jul", "Aug", "Sep",
                          "Octr", "Nov", "Dec")

## Reshape the wide format into a long format and remove empty values
tsdata <- gather(tsdata, key="Month", value = "Hour", na.rm=TRUE, -c("Emp Nbr", "Project ID"))
tsdata

## Plot with a bar chart 
tsdata %>% group_by(`Project ID`, Month) %>% summarise(totalHour = sum(Hour)) %>% 
  ggplot(aes(Month, totalHour, fill=`Project ID`)) + geom_col(position = "dodge", col="black", width=2) +
  ggtitle(paste("Employee number:", tsdata$`Emp Nbr`)) +
  scale_x_discrete(limits= tsdata$Month) +
  ylab("Hours") +
  guides(fill=guide_legend(title="Project ID")) +
  scale_fill_brewer(palette="Accent")
