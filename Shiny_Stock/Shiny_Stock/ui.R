library(plotly)
library(shiny)
library(shinydashboard)
ui <- dashboardPage(
  dashboardHeader(title = "S&P 500 Weekly Data"),
  dashboardSidebar(
    selectInput("company_select", "Name",performa$name),
    selectInput("return_select", "Return Period", c("30 Days", "90 Days", "1 Year", "3 Years", "5 Years", "10 Years")),
    dateInput("date_select", "Date", value = "2022-01-01", format = "yyyy-mm-dd",
      startview = "year",
      weekstart = 0,
      language = "en",
      autoclose = TRUE)),
  dashboardBody(
    fluidRow(
      column(
        width = 12,
        box(width = "100%",
            height = "100%",
          plotlyOutput("chart1"))
      )
    ),
    fluidRow(
      column(
        width = 12,
        box(width = "100%",
            height = "100%",
            plotlyOutput("chart2"))
      )
    )
  )
)
