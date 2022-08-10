## DublinBnB
Visualise AirBnB Dublin data. Obtained from http://insideairbnb.com/

#### This was an excercise in visualisation in R. 
The script produces 30 figures, histograms, pie charts, bar graphs, consolidated graphs, and interactive maps. Few of the sample plots are in the "Plots" folder. All of these plus more can be generated from the script. If you view the plots in the RStudio Viewer, ggplot has a lower image quality. High quality version of each plot can be viewed only after saving the script.
A sample high quality plot image is attached at the bottom of this README.
The aim was not to learn/generate any insights provided by the data but to merely practice how to build basic plots and visualise common data.

#### Libraries Used
1.  pacman - load all relevant packes
2.  rio - load the CSV
3.  ggplot2 - visualise all plots
4.  dplyr - important functions to summarise and clean data
5.  mapview - to visualise the geographical data
6.  plotly - to visualise some plots as interactive html widgets

#### How to Run
1. Make sure you have R and RStudio installed on your machine or are using RStudio web version. 
2. Clone the repo there.
3. Simply load the script, and the listings.csv file, Plots folder in a relvant location. 
4. Make sure RStudio is able to find the listings.csv
5. Once that is completed, run all the lines except in the bottom two section of "Clean Up" and "random testing"
6. All the figures should come up in the Plots folder. 
7. Some of the graphs as consolidated i.e. some images may contain multiple plots. 

#### Important Notes
The data is available in the listings CSV. 
The code does not have a lot of ocmments as most of it is pretty self-explanatory. Still, feel free to reach out if there are some doubts.
The entire script is an original with inspiration from stackoverflow and geeksforgeeks chunks. The formatting is from the freecodecamp R course.


![availVreviewsN](https://user-images.githubusercontent.com/95866059/184006990-27e7bb30-1ddb-467b-976e-03cf8c7334ba.jpg)
