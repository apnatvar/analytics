if (!require("pacman")) install.packages("pacman")
pacman::p_load(pacman, psych, rio, tidyverse, mapview, sf, plotly, gridExtra, grid) 

# IMPORT AND CLEAN DATA ##############################################
listing <- import("listings.csv")
listing <- listing %>% subset(select = -c(license, neighbourhood_group, host_name, name))
head(listing)

# DATA MANIPULATION AND VISUALISATION ########################################

############################### room type ################################
plt <- ggplot(listing) + geom_bar(aes(y=room_type, fill=room_type), stat='count') + #coord_polar(theta = "y", direction=1)
  theme_minimal() +
  theme(legend.position = "none", plot.caption.position = "plot", plot.caption = element_text(hjust = 0.5)) +
  #geom_area(fill = rgb(0, 0.5, 1, alpha = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  #scale_fill_manual(values=c("#999999", "#E69F00", "#56B4E9", "#786AAA")) +
  labs(x="Count", y="Room Type", title="AirBnB Dublin Rooms", subtitle="by Room Type", 
       caption="Majority of the available rooms are Entire Homes or Private Rooms.", tag="Fig. 1")
plt
ggsave("room_type.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### room type ################################



############################### availability ################################
x1 <- c("x < 100", "100 < x < 200", "200 < x < 300", "300 < x")
x2 <- c(nrow(listing[listing$availability_365<=100,]), 
        nrow(listing[listing$availability_365>100 & listing$availability_365<=200,]), 
        nrow(listing[listing$availability_365>200 & listing$availability_365<=300,]), 
        nrow(listing[listing$availability_365>300,]))
df <- data.frame(type=x1, count=x2)
plt <- ggplot(df) + geom_bar(aes(x=count, y=reorder(type, +count), fill=type), stat='identity') +
  theme_minimal() +
  theme(legend.position = "none", plot.caption.position = "plot", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Number of Locations", y="Availabilty (Days)", title="AirBnB Dublin Rooms", subtitle="by Availabilty", 
       caption="Majority of rooms were available for less than a hundred days", tag="Fig. 2")
plt
ggsave("by_availability.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)

fig <- plot_ly(
  x = df$count, 
  y = reorder(df$type, +df$count),
  type = 'bar',
  marker = list(
    color = factor(df$type, labels=c("#553555", "#755B69", "#96C5B0", "#ADF1D2"))
  )
) %>%
  layout(title="AirBnB Dublin Rooms", titlefont = list(size=20, color='#707070'),
         xaxis=list(title="Number of Locations", showgrid = T, color='#707070', tickangle=0, gridcolor='#d0d0d0'), 
         yaxis=list(title="Availabilty (Days)", color='#707070', gridcolor='#d0d0d0'),
         plot_bgcolor="#ffffff", paper_bgcolor="#ffffff", margin=10)
fig
htmlwidgets::saveWidget(as_widget(fig), "by_availability.html")
fig.write_image('by_availability.png', scale=5)
############################### availability ################################



############################### availability v room ################################
plt <- ggplot(listing) + geom_point(aes(x=room_type, y=availability_365, fill=neighbourhood), size=2, shape=23) +
  theme_minimal() +
  theme(plot.caption.position = "plot", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Room Type", y="Availabilty (Days)", title="AirBnB Dublin Rooms", subtitle="Availabilty vs Room Types", fill='Neighbourhood',
       tag="Fig. 3")
plt
ggsave("roomVSavailability.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### availability v room ################################



############################### availability v neighbourhood ################################
plt <- ggplot(listing) + geom_point(aes(x=neighbourhood, y=availability_365, fill=room_type), size=2, shape=23) +
  theme_minimal() +
  theme(plot.caption.position = "plot", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Location", y="Availabilty (Days)", title="AirBnB Dublin Rooms", subtitle="Availabilty vs Location", fill='Room Type',
       tag="Fig. 4")
plt
ggsave("neighbourhoodVSavailability.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### availability v neighbourhood ################################



############################### availability v price  - room ################################
plt1 <- ggplot(listing[listing$room_type=='Entire home/apt' & listing$price<1100000,]) + geom_point(aes(x=price, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Entire Home/Apartment", y="Availabilty (Days)", tag="Fig. 5",
       caption="1 observation greater than 1100000 was removed for a better range in the plot")
plt2 <- ggplot(listing[listing$room_type=='Private room' & listing$price<2000,]) + geom_point(aes(x=price, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Private Rooms", y="Availabilty (Days)", tag="Fig. 6",
       caption="3 observations with Prices greater than 2000 were removed for a better range in the plot")
plt3 <- ggplot(listing[listing$room_type=='Hotel room',]) + geom_point(aes(x=price, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none",) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Hotels", y="Availabilty (Days)", tag="Fig. 7")
plt4 <- ggplot(listing[listing$room_type=='Shared room',]) + geom_point(aes(x=price, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(plot.caption.position = "plot") +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Shared Rooms", y="Availabilty (Days)", tag="Fig. 8", fill="Neighbourhood")
cls <- grid.arrange(plt1, plt2, plt3, plt4, nrow=4, top = textGrob("Availability vs Price", gp=gpar(fontsize=20,font=3)),
                    bottom = textGrob("by Room Type", gp=gpar(fontsize=20,font=3)))
ggsave("availVPrice.jpg", plot = cls, width = 10, height = 10, units = "in", dpi = 300)
############################### availability v price - room ################################



############################### single v multiple house owner ################################  
single_owner_perc <- length(unique(listing[listing$calculated_host_listings_count==1,]$host_id))/nrow(listing)*100
multiple_owner_perc <- 100 - single_owner_perc
single_owner_perc
length(unique(listing[listing$calculated_host_listings_count==1,]$host_id))
nrow(listing)
multiple_owner_perc
df <- data.frame(metric = c("Single Home Owners", "Multiple Home Owners"), 
                 value = c(length(unique(listing[listing$calculated_host_listings_count==1,]$host_id)), 
                           nrow(listing) - length(unique(listing[listing$calculated_host_listings_count==1,]$host_id))))
plt <- ggplot(df, aes(x="", y=value, fill=metric)) + geom_col(color="#000000") + 
  geom_label(aes(label = metric), position = position_stack(vjust = 0.5), color = "#000000", show.legend = F) +
  geom_text(aes(label = value), position = position_stack(vjust = 0.4), color = "#000000") +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, size = 20)) +
  coord_polar(theta="y") + scale_fill_manual(values = c("#00a6ed", "#ffb400")) +
  theme(#axis.text = element_blank(),
    axis.ticks = element_blank(),
    #axis.title = element_rect(fill = "#000000"),
    #panel.grid = element_blank(),
    panel.background = element_rect(fill = "#f0f0f0"),
    plot.background = element_rect(fill = "#f0f0f0"),) +
  #legend.background = element_rect(fill = "#000000"))
  labs(fill="", y="", x="", title = "Single v Multiple Home Owners", caption = "Fig. 9")
plt
ggsave("sVmHouseOwners.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### single v multiple house owner ################################ 



############################### availability v price - neighbourhood ################################
plt1 <- ggplot(listing[listing$neighbourhood=='Dublin City' & listing$price<4000,]) + geom_point(aes(x=price, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Dublin City", y="Availabilty (Days)", tag="Fig. 10",
       caption="3 observatiosn with Price greater than 1100000 were removed for a better range in the plot")
plt2 <- ggplot(listing[listing$neighbourhood=='South Dublin' & listing$price<510,]) + geom_point(aes(x=price, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="South Dublin", y="Availabilty (Days)", tag="Fig. 11",
       caption="3 observations with Prices greater than 510 were removed for a better range in the plot")
plt3 <- ggplot(listing[listing$neighbourhood=='Fingal' & listing$price<1250,]) + geom_point(aes(x=price, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Fingal", y="Availabilty (Days)", tag="Fig. 12",
       caption="3 observations with prices greater than 1250 were removed for a better range in the plot")
plt4 <- ggplot(listing[listing$neighbourhood=='Dn Laoghaire-Rathdown' & listing$price<750,]) + geom_point(aes(x=price, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(plot.caption.position = "plot", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Dn Laoghaire-Rathdown", y="Availabilty (Days)", tag="Fig. 13", fill="Room Type",
       caption="3 observations with Prices greater than 750 were removed for a better range in the plot")
cls <- grid.arrange(plt1, plt2, plt3, plt4, nrow=4, top = textGrob("Availability vs Price", gp=gpar(fontsize=20,font=3)),
                    bottom = textGrob("by Neighbourhood", gp=gpar(fontsize=20,font=3)))
ggsave("availVNeighbourhod.jpg", plot = cls, width = 10, height = 10, units = "in", dpi = 300)
############################### availability v price - neighbourhood ################################



############################### availability v reviews  - nieghbourhood ################################
plt1 <- ggplot(listing[listing$neighbourhood=='Dublin City' & listing$price<1100000,]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Dublin City", y="Availabilty (Days)", tag="Fig. 14",
       caption="1 observation greater than 1100000 was removed for a better range in the plot")
plt2 <- ggplot(listing[listing$neighbourhood=='South Dublin' & listing$price<2000,]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="South Dublin", y="Availabilty (Days)", tag="Fig. 15",
       caption="3 observations with Prices greater than 2000 were removed for a better range in the plot")
plt3 <- ggplot(listing[listing$neighbourhood=='Fingal',]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none",) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Fingal", y="Availabilty (Days)", tag="Fig. 16")
plt4 <- ggplot(listing[listing$neighbourhood=='Dn Laoghaire-Rathdown',]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=room_type), size=2, shape=21) +
  theme_minimal() +
  theme(plot.caption.position = "plot") +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Dn Laoghaire-Rathdown", y="Availabilty (Days)", tag="Fig. 17", fill="Room Type")
cls <- grid.arrange(plt1, plt2, plt3, plt4, nrow=4, top = textGrob("Availability vs Reviews", gp=gpar(fontsize=20,font=3)),
                    bottom = textGrob("by Neighbourhood", gp=gpar(fontsize=20,font=3)))
ggsave("availVneighbourhoodR.jpg", plot = cls, width = 10, height = 10, units = "in", dpi = 300)
############################### availability v reviews - neighbourhood ################################



############################### availability v reviews  - room ################################
plt1 <- ggplot(listing[listing$room_type=='Entire home/apt' & listing$price<1100000,]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Entire Home/Apartment", y="Availabilty (Days)", tag="Fig. 18",
       caption="1 observation greater than 1100000 was removed for a better range in the plot")
plt2 <- ggplot(listing[listing$room_type=='Private room' & listing$price<2000,]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Private Rooms", y="Availabilty (Days)", tag="Fig. 19",
       caption="3 observations with Prices greater than 2000 were removed for a better range in the plot")
plt3 <- ggplot(listing[listing$room_type=='Hotel room',]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(legend.position = "none",) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Hotels", y="Availabilty (Days)", tag="Fig. 20")
plt4 <- ggplot(listing[listing$room_type=='Shared room',]) + geom_point(aes(x=number_of_reviews, y=availability_365, fill=neighbourhood), size=2, shape=21) +
  theme_minimal() +
  theme(plot.caption.position = "plot") +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Shared Rooms", y="Availabilty (Days)", tag="Fig. 21", fill="Neighbourhood")
cls <- grid.arrange(plt1, plt2, plt3, plt4, nrow=4, top = textGrob("Availability vs Reviews", gp=gpar(fontsize=20,font=3)),
                    bottom = textGrob("by Room Type", gp=gpar(fontsize=20,font=3)))
ggsave("availVreviewsR.jpg", plot = cls, width = 10, height = 10, units = "in", dpi = 300)
############################### availability v reviews - room ################################



############################### price summary ################################
price_summary <- listing %>%
  group_by(neighbourhood, room_type) %>%
  summarise(avg_price = mean(price), median_price = median(price),number_of_listings = n())
price_summary

plt <- ggplot(price_summary, aes(x=neighbourhood, y=avg_price, fill=room_type)) +
  geom_bar(stat="identity", position = "dodge") +
  theme_minimal() +
  theme(plot.caption.position = "plot", panel.grid.major = element_line(color="#e0e0e0")) +
  scale_fill_brewer(palette="Dark2") +
  labs(title="AirBnB Average Room Price", subtitle="By Neighbourhood", x="", y="Price in Euro", tag="Fig. 22", fill="Room Type")
plt
ggsave("Plots/avg_price_summary.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)

plt <- ggplot(price_summary, aes(x=neighbourhood, y=median_price, fill=room_type)) +
  geom_bar(stat="identity", position = "dodge") +
  theme_minimal() +
  theme(plot.caption.position = "plot", panel.grid.major = element_line(color="#e0e0e0")) +
  scale_fill_brewer(palette="Dark2") +
  labs(title="AirBnB Median Room Price", subtitle="By Neighbourhood", x="", y="Price in Euro", tag="Fig. 23", fill="Room Type")
plt
ggsave("Plots/median_price_summary.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### price summary ################################



############################### neighbourhood pie ################################
neighbourhood_count <- data.frame(table(listing$neighbourhood))
neighbourhood_percentage <- as.integer(neighbourhood_count$Freq*10000/nrow(listing))/100
plt <- ggplot(neighbourhood_count, aes(x="", y=Freq, fill=Var1)) + geom_col(color="#000000") + 
  geom_text(aes(label = neighbourhood_percentage), position = position_stack(vjust = 0.5), color = "#000000") +
  theme(plot.title = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, size = 20),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_polar(theta="y") + scale_fill_manual(values = c("#008b29", "#78e3fd", "#0c6291", "#d81e5b")) +
  theme(axis.ticks = element_blank(),
        panel.background = element_rect(fill = "#f0f0f0"),
        plot.background = element_rect(fill = "#f0f0f0"),) +
  labs(fill="Neighbourhoods", y="", x="", title = "Number of Listings", subtitle="By Neighbourhood", caption = "Fig. 24")
plt
ggsave("Plots/neighbourhoodPie.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### neighbourhood pie ################################



############################### room type pie ################################
room_type_count <- data.frame(table(listing$room_type))
room_type_percentage <- as.integer(room_type_count$Freq*10000/nrow(listing))/100
plt <- ggplot(room_type_count, aes(x="", y=Freq, fill=Var1)) + geom_col(color="#000000") + 
  geom_text(aes(label = room_type_percentage), position = position_stack(vjust = 0.5), color = "#000000") +
  theme(plot.title = element_text(hjust = 0.5), plot.caption = element_text(hjust = 0.5, size = 20),
        plot.subtitle = element_text(hjust = 0.5)) +
  coord_polar(theta="y") + scale_fill_manual(values = c("#008b29", "#78e3fd", "#0c6291", "#d81e5b")) +
  theme(axis.ticks = element_blank(),
        panel.background = element_rect(fill = "#f0f0f0"),
        plot.background = element_rect(fill = "#f0f0f0"),) +
  labs(fill="Room Types", y="", x="", title = "Number of Listings", subtitle="By Room Type", caption = "Fig. 25")
plt
ggsave("Plots/roomTypePie.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### room type pie ################################



############################### room price hist ################################
k <- c("Entire home/apt", "Hotel room", "Private room", "Shared room")
fig_num <- 26
for (i in k){
  plt <- ggplot(listing[listing$room_type==i & listing$price<2100,]) +
    geom_histogram(aes(x=price, color=neighbourhood), binwidth=1, alpha=0.5, fill="white") +
    geom_vline(aes(xintercept=mean(price)), color="#345197", linetype="dashed") +
    #geom_density(alpha=.2, fill="#ffffff") +
    theme_minimal() +
    scale_fill_brewer(palette="Dark2") +
    theme(plot.caption = element_text(hjust=0.5)) +
    labs(title="Room Price", subtitle=i, x="Price in Euro", y="Count", tag=paste("Fig. ",fig_num),
         caption="Rooms with prices more than 2100 Euro a night were removed as they are outliers.")
  ggsave(paste0("Plots/priceHist",fig_num-25,".jpg"), plot = plt, width = 10, height = 10, units = "in", dpi = 300)
  fig_num <- fig_num + 1
}
############################### room price hist ################################



############################### availability hist ################################
plt <- ggplot(listing[listing$price<2100 & listing$availability_365>10,]) +
  geom_histogram(aes(x=availability_365, color=neighbourhood), binwidth=1, alpha=0.5, fill="white") +
  theme_minimal() +
  scale_fill_brewer(palette="Dark2") +
  theme(plot.caption = element_text(hjust=0.5)) +
  labs(title="Room Price", subtitle=i, x="Price in Euro", y="Count", tag=paste("Fig. 30"),
       caption="Rooms with prices more than 2100 Euro a night were removed as they are outliers.
       Room with availability less than 10 days were also removed for a better histogram")
plt
ggsave("Plots/availHist.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)
############################### availability hist ################################



############################### map - availability ################################
mapview(listing[listing$availability_365<=100,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapview(listing[listing$availability_365>100 & listing$availability_365<=200,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapview(listing[listing$availability_365>200 & listing$availability_365<=300,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapview(listing[listing$availability_365>300,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
############################### map - availability ################################



############################### map - room type ################################
mapview(listing[listing$room_type=='Entire home/apt',], xcol="longitude", ycol = "latitude", zcol="neighbourhood", crs=4269, grid=FALSE)
mapview(listing[listing$room_type=='Hotel room',], xcol="longitude", ycol = "latitude", zcol="neighbourhood", crs=4269, grid=FALSE)
mapview(listing[listing$room_type=='Private room',], xcol="longitude", ycol = "latitude", zcol="neighbourhood", crs=4269, grid=FALSE)
mapview(listing[listing$room_type=='Shared room',], xcol="longitude", ycol = "latitude", zcol="neighbourhood", crs=4269, grid=FALSE)
############################### map - room type ################################



############################### map - owners ################################
mapview(listing[listing$calculated_host_listings_count==1,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapview(listing[listing$calculated_host_listings_count>1,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
############################### map - owners ################################



############################### map - neighbourhood ################################
mapview(listing[listing$neighbourhood=='Dublin City',], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapview(listing[listing$neighbourhood=='South Dublin',], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapview(listing[listing$neighbourhood=='Fingal',], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
fig <- mapview(listing[listing$neighbourhood=='Dn Laoghaire-Rathdown',], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)
mapshot(fig, url = paste0(getwd(), "/map.html")) # save any map with this command
############################### map - neighbourhood ################################




############################### correlations tests ################################
cor.test(listing$price, listing$availability_365, method = "kendall")
cor.test(listing$price, listing$availability_365, method = "pearson")
cor.test(listing$price, listing$availability_365, method = "spearman")
cor.test(listing$room_type, listing$availability_365, method = "pearson") # error, redone later
cor.test(listing$price, listing$room_type, method = "pearson") # error, redone later
cor.test(listing$number_of_reviews, listing$availability_365, method = "pearson") 

listCopy <- listing
k <- c("Entire home/apt", "Hotel room", "Private room", "Shared room")
j <- c("Dn Laoghaire-Rathdown", "Dublin City", "Fingal", "South Dublin")
for (i in c(1:4)){
  listCopy$room_type[listCopy$room_type==k[i]] <- i # encoding a string column as a number
  listCopy$neighbourhood[listCopy$neighbourhood==j[i]] <- i
  #print(k[i])
  #print(mode(i))
}
head(listCopy)
cor.test(as.numeric(listCopy$room_type), listCopy$price, method = "pearson")
cor.test(as.numeric(listCopy$room_type), listCopy$availability_365, method = "pearson")
############################### correlations tests ################################


############################### random testing ################################

# average price by neighbourhood, room_type
# correlation tests - (room_type, availability), (price, availability), (room_type, price), (number_of_reviews, availability), 
# plot between (host_id, price), 
plt <- ggplot(listing[listing$room_type=='Hotel room',]) + geom_point(aes(x=price, y=availability_365), size=2) +
  theme_minimal() +
  theme(plot.caption.position = "plot", plot.caption = element_text(hjust = 0.5)) +
  scale_fill_brewer(palette="Dark2") +
  labs(x="Price", y="Availabilty (Days)", title="Availabilty vs Price", subtitle="Hotel Rooms", #fill='Room Type',
       tag="Fig. 4")
plt
ggsave("121neighbourhoodVSavailability.jpg", plot = plt, width = 10, height = 10, units = "in", dpi = 300)

mapview(listing[listing$price>100000,], xcol="longitude", ycol = "latitude", zcol="room_type", crs=4269, grid=FALSE)

par(mfrow = c(4, 1))


par(mfrow = c(1, 1))



# CLEAN UP #################################################

# Clear environment
rm(list = ls()) 

# Clear packages
p_unload(all)  # Remove all add-ons

# Clear plots
dev.off()  # But only if there IS a plot

# Clear console
cat("\014")  # ctrl+L

# Clear mind :)
