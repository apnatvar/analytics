setwd("C:/Users/apnat/Desktop/Summer/R/Shiny")
library(rvest)
library(dplyr)
library(janitor)
library(tidyverse)
library(readr)
stock_data_url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
stock_data <- read_html(stock_data_url)%>%
  html_node("table")%>%
  html_table()
#glimpse(stock_data)
stock_data <- clean_names(stock_data)
#colnames(stock_data)
stock_data_clean <- stock_data %>%
 select(symbol, security, gics_sector, gics_sub_industry, headquarters_location)
#colnames(stock_data_clean)
#glimpse(stock_data_clean)
stock_data_final <- stock_data %>% rename(ticker = symbol, name = security)
save(stock_data_clean, file = "clean.RData")
save(stock_data, file = "raw.RData")
stock_data<-get(load("raw.RData"))
save(stock_data_final, file="useThis.RData")
stock_data_final<-get(load("useThis.RData"))

yahoo_data <- as.data.frame(matrix(NA, nrow=0, ncol=8))
names(yahoo_data) <- c("ticker", "date", "open", "high", "low", "close", "adj_close", "volume")

stock_data_final <- get(load("useThis.RData"))
colnames(stock_data_final)
for(symbol in stock_data_final$ticker){
  #print(symbol)
  stock_yahoo_url <- paste0("https://query1.finance.yahoo.com/v7/finance/download/", symbol, "?period1=345427200&period2=1655769600&interval=1wk&events=history&includeAdjustedClose=true")
  #print(stock_yahoo_url)
  temp_yahoo_data <- try(read.csv(stock_yahoo_url))
  if(mode(temp_yahoo_data)=="list"){
    temp_yahoo_data$ticker <- symbol
    yahoo_data <- rbind(yahoo_data, temp_yahoo_data)
  }
}
#colnames(stock_data_clean)
view(yahoo_data)
save(yahoo_data, file="fromYahoo.RData")
yahoo_data = get(load("fromYahoo.RData"))
colnames(yahoo_data)
yahoo_data <- yahoo_data %>%
  mutate(open = as.numeric(Open),
         high = as.numeric(High),
         low = as.numeric(Low),
         close = as.numeric(Close),
         adj_close = as.numeric(Adj.Close),
         volume = as.numeric(Volume))%>% 
  mutate(weekly_result = ifelse(close > open, "Volume on Gain", "Volume on Drop"))%>%
  within(rm(Open, High, Close, Low, Adj.Close, Volume))%>%
  rename(date=Date)
  
colnames(yahoo_data)

save(yahoo_data, file="fromYahooClean.RData")
yahoo_data_transform <- yahoo_data %>%
  gather("series", "value", -date, -ticker, -weekly_result)
#glimpse(yahoo_data_transform)
yahoo_data_transform <- yahoo_data_transform %>%
  left_join(stock_data_final%>%
              select(ticker, name, gics_sector), by=c("ticker" = "ticker"))
yahoo_data <- yahoo_data %>%
  left_join(stock_data_final%>%
              select(ticker, name, gics_sector), by=c("ticker" = "ticker"))
glimpse(yahoo_data_transform)
save(yahoo_data_transform, file="afterJoin.RData")
save(yahoo_data, file="afterJoinNG.RData")
