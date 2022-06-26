library(plotly)
library(dplyr)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(scales)
library(janitor)
performa <- get(load("performaJoined.RData"))
stock_joined_data <- get(load("afterJoinNG.RData"))
server <- function(input, output){
  output$chart1 <- renderPlotly({
  chart_data <- stock_joined_data %>%
    filter(name == input$company_select, date >= input$date_select)
  
  candlestick <- chart_data %>%
    plot_ly(x = ~date, type="candlestick", name = chart_data$ticker[1],
            open = ~open,
            close = ~close,
            high = ~high,
            low = ~adj_close)%>%
    layout(xaxis = list(type = 'date', tickformat="%d-%m-%y"))
  
  volume_chart <- chart_data%>%
    plot_ly(x=~date, y=~volume, type='bar', colors=c('#7F7F7F','#17BECF'),
            color=~weekly_result)
  volume_chart <- volume_chart%>%
    layout(yaxis=list(title="Volume", gridcolor="#6e6e6e"))
  
  candlestick <- subplot(candlestick, volume_chart, heights = c(0.7, 0.2), nrows=2, shareX =TRUE, titleY = TRUE)
  
  candlestick <- candlestick %>% 
    layout(title = paste0(chart_data$name[1]," - ",chart_data$gics_sector[1]), plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f',
           font = list(size = 9, color = "FFF"),
           yaxis = list(title = "Price", gridcolor="6e6e6e"),
           xaxis = list(title = "", type = 'date', tickformat="%d-%m-%y", gridcolor="6e6e6e"),
           legend = list(orientation = 'h', x = 0.5, y = 1.02,
                         xanchor = 'center', yref = 'paper',
                         bgcolor = 'transparent'))})
  
  
  output$chart2 <- renderPlotly({
    chart_data <- stock_joined_data %>%
      filter(name == input$company_select, date >= input$date_select)
    chart_data1 <- performa %>%
    filter(gics_sector == chart_data$gics_sector[2])
  sector_chart1 <- plot_ly(chart_data1, x=unlist(chart_data1['name']), y=unlist(chart_data1[input$return_select]), type = 'bar', 
                           name = chart_data1$gcis_sector[1], marker = list(color = '#17BECF'),
                           text = label_percent()(unlist(chart_data1[input$return_select])), textposition = 'auto')%>%
    layout(plot_bgcolor = "#2f2f2f", paper_bgcolor='#2f2f2f', title = input$return_select, 
           font = list(size = 9, color = "FFF"),
           yaxis = list(title="% Increase/Decrease",gridcolor="#6e6e6e"),
           xaxis = list(title = chart_data$gics_sector[1], gridcolor="#6e6e6e"))
  })
  #output$chart3 <- renderPlotly({})
}
