# S&P 500 Weekly Price Dashbaord

### Libraries Used
 1. Shiny
 2. ShinyDashboard
 3. Tidyverse
 4. Janitor
 5. Scales
 6. RSConnect
 7. DPLYR

### The Code
The Code is written entirely in R. The data is retrieved from Yahoo Finance for all companies indexed in the S&P 500. This list was retrieved from WikiPedia. Each csv is recieved and added to a bigger database containing data for multiple companies. I tried to ensure that the maximum data is retreived, so to lessen the load I summarised it for only weekly data. One can easily change the URL based on what data they want and how to visualise it. You can also directly import a csv into server.R if it has been processed in a similar format and build visualisations from there.

### How to run:
1. Access it at this link: https://apnatva.shinyapps.io/shiny/
2. Run in RStudio:
    1. load scrapeData.R into the memory and Run.
    2. load calculations.R inot memory and Run.
    3. use plotData to test the plots before putting them into the dashboard.
    4. Run server.R and ui.R into memory. Run each of them.
    5. Now go to console and type shinyApp(ui, server) and it should open up the dashboard in RStudio.

#### This is partly inspired by Matt C137 on Youtube.
This is the link to their first video in a 6 part series. The major difference arrises in plotting the data, Matt did it in ggplot2 whereas I used Plotly.
