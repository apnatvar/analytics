library(dplyr)
library(tidyverse)
stock_joined_data <- get(load("afterJoinNG.RData"))
colnames(stock_joined_data)
performance_calc <- as.data.frame(matrix(NA, ncol = 7, nrow = 0))
names(performance_calc) <- c("ticker", "30 Days", "90 Days", "1 Year", "3 Years", "5 Years", "10 Years")
#test_df <- stock_joined_data%>%
 # select(c("ticker", "date", "name", "adj_close"))%>%
  #filter(ticker == "AAPL")%>%
  #drop_na(adj_close)%>%
  #arrange(desc(date))
#test_df
i <- 1
for(tickeri in unique(stock_joined_data$ticker)){
  stock_by_ticker <- stock_joined_data%>%
    select(c("ticker", "date", "name", "adj_close"))%>%
    filter(ticker == tickeri)%>%
    drop_na(adj_close)%>%
    arrange(desc(date))
  thirty_day <- (stock_by_ticker$adj_close[1] - stock_by_ticker$adj_close[4])/stock_by_ticker$adj_close[4]
  ninety_day <- (stock_by_ticker$adj_close[1] - stock_by_ticker$adj_close[12])/stock_by_ticker$adj_close[12]
  one_year <- (stock_by_ticker$adj_close[1] - stock_by_ticker$adj_close[52])/stock_by_ticker$adj_close[52]
  three_year <- (1+(stock_by_ticker$adj_close[1] - stock_by_ticker$adj_close[52*3])/stock_by_ticker$adj_close[52*3])^(1/3)-1
  five_year <- (1+(stock_by_ticker$adj_close[1] - stock_by_ticker$adj_close[52*5])/stock_by_ticker$adj_close[52*5])^(1/5)-1
  ten_year <- (1+(stock_by_ticker$adj_close[1] - stock_by_ticker$adj_close[52*10])/stock_by_ticker$adj_close[52*10])^(1/10)-1
  performance_calc[i,1]<-tickeri
  performance_calc[i,2]<-thirty_day
  performance_calc[i,3]<-ninety_day
  performance_calc[i,4]<-one_year
  performance_calc[i,5]<-three_year
  performance_calc[i,6]<-five_year
  performance_calc[i,7]<-ten_year
  i <- i+1
}
view(performance_calc)
save(performance_calc, file="performa.RData")
stock_data_final<-get(load("useThis.RData"))
performa_joined <- performance_calc %>%
  left_join(stock_data_final, by = c("ticker"="ticker"))
view(performa_joined)
save(performa_joined, file="performaJoined.RData")
performa_joined$`30 Days`
performa_joined['30 Days']
label_percent()(unlist(performa_joined["30 Days"]))
