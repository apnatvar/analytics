library(dplyr)
library(plotly)
library(tidyverse)
library(scales)
stock_joined_data <- get(load("afterJoinNG.RData"))
colnames(stock_joined_data)
search_for <- "AAPL"
chart_data <- stock_joined_data %>%
  filter(ticker == search_for, date >= "2020-01-01")
colnames(chart_data)

candlestick <- chart_data %>%
  plot_ly(x = ~date, type="candlestick", name = chart_data$ticker[1],
          open = ~open,
          close = ~close,
          high = ~high,
          low = ~adj_close)%>%
  layout(xaxis = list(type = 'date', tickformat="%d-%m-%y"))

#candlestick <- candlestick %>%
 # add_lines(x = ~date, y=~open, name = "Open Price", line=list(color = 'black', width = 0.2), inherit = F)
#colnames(chart_data)
volume_chart <- chart_data%>%
  plot_ly(x=~date, y=~volume, type='bar', colors=c('#7F7F7F','#17BECF'),
          color=~weekly_result)
volume_chart <- volume_chart%>%
  layout(yaxis=list(title="Volume", gridcolor="6e6e6e"))
#volume_chart
candlestick <- subplot(candlestick, volume_chart, heights = c(0.7, 0.2), nrows=2, shareX =TRUE, titleY = TRUE)
rs <- list(visible = TRUE, x = 0.5, y = -0.55,
           xanchor = 'center', yref = 'paper', 
           plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f',
           font = list(size = 7, color = "FFF"),
           buttons = list(
             list(count=1,
                  label='RESET',
                  step='all'),
             list(count=1,
                  label='1 YR',
                  step='year',
                  stepmode='backward'),
             list(count=3,
                  label='3 MO',
                  step='month',
                  stepmode='backward'),
             list(count=1,
                  label='1 MO',
                  step='month',
                  stepmode='backward')
           ))
candlestick <- candlestick %>% 
  layout(title = paste0(chart_data$name[1]," - ",chart_data$gics_sector[1]), plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f',
         font = list(size = 9, color = "FFF"),
         yaxis = list(title = "Price", gridcolor="6e6e6e"),
         xaxis = list(title = "Date", rangeselector = rs, type = 'date', tickformat="%d-%m-%y", gridcolor="6e6e6e"),
         legend = list(orientation = 'h', x = 0.5, y = 1.02,
                                    xanchor = 'center', yref = 'paper',
                                    bgcolor = 'transparent'))
candlestick

performa <- get(load("performaJoined.RData"))
performa_data <- performa %>%
  filter(ticker == search_for)
colnames(performa_data)
performa_chart <- plot_ly(chart_data, x=~date, y=~adj_close, type = 'scatter', mode = 'lines+markers', name = chart_data$ticker[1])
performa_chart <- performa_chart%>%
  layout(title = paste0(chart_data$name[1]," - ",chart_data$gics_sector[1]), plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f',
        font = list(size = 9, color = "FFF"),
        yaxis = list(title = "Close Price", gridcolor="6e6e6e"),
        xaxis = list(title = "Date", type = 'date', tickformat="%d-%m-%y", gridcolor="6e6e6e"))
performa_data_transform <- performa_data %>%
  gather("series", "value", `30_days`, `90_days`, `1_year`, `3_years`, `5_year`, `10_year` )
view(performa_data_transform)
test <- plot_ly(performa_data_transform, x=~series, y=~value*100, type="bar", 
                text = label_percent()(performa_data_transform$value), textposition = 'auto')%>%
  layout(plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f',
         font = list(size = 9, color = "FFF"),
         yaxis = list(title = "Close Price", gridcolor="6e6e6e"),
         xaxis = list(title = "Date", type = 'date', tickformat="%d-%m-%y", gridcolor="6e6e6e"))

chart_data1 <- performa %>%
  filter(gics_sector == chart_data$gics_sector[1])
sector_chart1 <- plot_ly(chart_data1, x=~name, y=~`30_days`*100, type = 'bar', 
                         name = chart_data1$gcis_sector[1], 
                         text = label_percent()(chart_data1$`30_days`), textposition = 'auto'
                         )%>%
  layout(plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f',title = "30 Day Return",
         font = list(size = 9, color = "FFF"),
         yaxis = list(title="",gridcolor="6e6e6e"),
         xaxis = list(title = chart_data$gics_sector[1], gridcolor="6e6e6e"))
sector_chart1
performa_chart
bruh <- stock_joined_data[ticker="MMM"]
bruh

