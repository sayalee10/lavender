# Load relevant packages
library(readr)
library(lubridate)
library(tidyr)
library(dplyr)
library(rJava)
library(openxlsx)
library(RSelenium)
library(rvest)
library(stringr)

# Set working directory
dir.create("C:/flightscrape1", showWarnings = FALSE)
setwd("C:/flightscrape1")

dir.create("D:/flightscrape1", showWarnings = FALSE)
setwd("D:/flightscrape1")


# INPUT
FCO_HEL_MRS <- read_csv("Data collection code/FCO-HEL-MRS.csv")

nbr_cities1 <- nrow(FCO_HEL_MRS)

# Set time period for scraping
start_date <- Sys.Date() + 1
end_date <- start_date + 15

# Initialize dataframe
df1 <- data.frame(airline = character(),
                  price = numeric(),
                  Origin = character(),
                  Destination = character(),
                  DepartureDate = as.Date(character()),
                  DepartureTime = character(),
                  ConnectionNumber = character(),
                  TravelTime = character(),
                  ScrapeDate = as.Date(character()))

# Stop pending tasks to free the port for RSelenium
system("taskkill /F /IM java.exe")

# Loop over all city combinations in list
for (i in 1:nbr_cities1) {
  # Start RSelenium
  driver <- rsDriver(browser = "firefox", chromever = NULL)
  remDr <- driver[["client"]]
  
  for (j in 1:nbr_cities1) {
    # If origin and destination are not the same, then scrape prices
    if (j != i) {
      origin <- FCO_HEL_MRS$city[i]
      destination <- FCO_HEL_MRS$city[j]
      print(paste(origin, destination, sep = " "))
      
      departure <- start_date
      
      # Loop over all dates in interval
      while (departure <= end_date) {
        print(departure)
        
        url <- paste0("https://www.kayak.nl/flights/",
                      origin, "-",
                      destination, "/",
                      departure, "?sort=bestflight_a")
        
        remDr$navigate(url)
        Sys.sleep(3)
        
        page <- remDr$getPageSource()
        text_xml <- read_html(page[[1]])
        
        prices <- text_xml %>%
          html_nodes('div.f8F1-price-text') %>%
          html_text() %>%
          strsplit("\n") %>%
          unlist(use.names = FALSE) %>%
          as.data.frame()
        
        if (nrow(prices) == 0) {
          prices <- as.data.frame(NA)
        }
        
        colnames(prices) <- "price"
        
        DepartureTime <- text_xml %>%
          html_nodes('div.vmXl.vmXl-mod-variant-large') %>%
          html_text() %>%
          strsplit("\n") %>%
          unlist(use.names = FALSE) %>%
          as.data.frame()
        
        ConnectionNumber <- text_xml %>%
          html_nodes('span.JWEO-stops-text') %>%
          html_text() %>%
          strsplit("\n") %>%
          unlist(use.names = FALSE) %>%
          as.data.frame()
        
        TravelTime <- text_xml %>%
          html_nodes('div.xdW8.xdW8-mod-full-airport') %>%
          html_text() %>%
          strsplit("\n") %>%
          unlist(use.names = FALSE) %>%
          as.data.frame()
        
        airline <- text_xml %>%
          html_nodes('div.J0g6-operator-text') %>%
          html_text() %>%
          strsplit("\n") %>%
          unlist(use.names = FALSE) %>%
          as.data.frame()
        
        airline$airline <- str_squish(airline$.)
        airline <- filter(airline, airline != "")
        
        df_update1 <- data.frame(prices) %>%
          mutate(airline = airline$airline,
                 Origin = origin,
                 Destination = destination,
                 DepartureDate = departure,
                 DepartureTime = DepartureTime$.,
                 ConnectionNumber = ConnectionNumber$.,
                 TravelTime = TravelTime$.,
                 ScrapeDate = Sys.Date())
        
        df1 <- rbind(df1, df_update1)
        rm(df_update1)
        
        departure <- departure + 1
      }
    }
  }
  
  remDr$close()
  driver$server$stop()
}

# Write data to excel
write.xlsx(df1, "prim_data_6_June_15_days_FCO_HEL_MRS.xlsx")

