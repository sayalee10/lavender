# lavender
Airline data scapping for ticket pricing
# Airline Price Data Collection Using R

## Project Overview
This project demonstrates the collection and processing of airline ticket pricing data from online flight-search websites using R.

The objective was to collect flight information across different routes and departure dates to support airline pricing analysis and revenue management research.

## Technical Stack
- R
- RSelenium
- rvest
- dplyr
- readr
- lubridate
- Web scraping and data extraction

## Data Collected
The scraping workflow was designed to collect:
- Airline
- Origin and destination
- Departure date
- Ticket price
- Number of connections
- Journey duration
- Scraping date

## Methodology
1. Initialise browser automation using RSelenium.
2. Navigate through flight-search results.
3. Extract relevant flight information.
4. Parse and clean prices, dates and journey durations.
5. Combine extracted observations into a structured dataset.
6. Export the processed data for statistical analysis.

## Applications
The collected data can support:
- Airline revenue management research
- Flight price variation analysis
- Direct versus connecting flight comparisons
- Pricing behaviour across departure dates

## Reproducibility and Usage
The scripts are provided for educational and research purposes. Website access, scraping permissions and terms of service should be reviewed before execution.

The original research dataset is not included unless its redistribution is permitted.
