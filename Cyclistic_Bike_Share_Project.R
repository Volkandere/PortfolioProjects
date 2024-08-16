library('tidyverse')
library('conflicted')
library('scales')
library('patchwork')
 
# To use the filter() function from dplyr, not from the stats package
conflict_prefer("filter", "dplyr")

# Import the datasets
cyclistic_2023_01 <- read_csv('cyclistic_2023_01.csv')
cyclistic_2023_02 <- read_csv('cyclistic_2023_02.csv')
cyclistic_2023_03 <- read_csv('cyclistic_2023_03.csv')
cyclistic_2023_04 <- read_csv('cyclistic_2023_04.csv')
cyclistic_2023_05 <- read_csv('cyclistic_2023_05.csv')
cyclistic_2023_06 <- read_csv('cyclistic_2023_06.csv')
cyclistic_2024_01 <- read_csv('cyclistic_2024_01.csv')
cyclistic_2024_02 <- read_csv('cyclistic_2024_02.csv')
cyclistic_2024_03 <- read_csv('cyclistic_2024_03.csv')
cyclistic_2024_04 <- read_csv('cyclistic_2024_04.csv')
cyclistic_2024_05 <- read_csv('cyclistic_2024_05.csv')
cyclistic_2024_06 <- read_csv('cyclistic_2024_06.csv')

# Checking the columns and datatype to bind_rows()
glimpse(cyclistic_2023_01)
glimpse(cyclistic_2024_06)

# Adding data to a one big data
all_rides <- bind_rows(cyclistic_2023_01,
                       cyclistic_2023_02,
                       cyclistic_2023_03,
                       cyclistic_2023_04,
                       cyclistic_2023_05,
                       cyclistic_2023_06,
                       cyclistic_2024_01,
                       cyclistic_2024_02,
                       cyclistic_2024_03,
                       cyclistic_2024_04,
                       cyclistic_2024_05,
                       cyclistic_2024_06
                       )

# Removing unnecessary columns
all_rides <- select(all_rides, -c(start_lat, start_lng, end_lat, end_lng))

# Checking the data if there is any cleaning to be done
head(all_rides)
colnames(all_rides)
glimpse(all_rides)
nrow(all_rides)
dim(all_rides)
summary(all_rides)

# Checking null values
colSums(is.na(all_rides))

# Checking for duplicates
all_rides %>% 
distinct(ride_id) %>% 
nrow() #4795211 data. But our total was 4795422. So there are 211 duplicate values

# Shows the duplicate values
view(all_rides %>%
  group_by(ride_id) %>%  
  filter(n() > 1))

# TO DO
# 1- Remove the duplicates
# 2- We will need to add some columns such as date, month, day, and year to provide aggregation.
# 3- Since we look at the data we want to add a column for ride_length to calculate the duration of ride in the all_rides .
# 4- After calculating ride_lengths we see that some values are negative. This leads to false information. Company could 
# take the bikes for quality control reasons. So removing those rows would be a good decision.

# 1 Duplicates removes
all_rides <- all_rides %>%
distinct(ride_id, .keep_all = TRUE)

# 2 Adding columns date, year, month, day, day_of_week
all_rides_2 <- all_rides %>%  mutate(date = as.Date(started_at))
all_rides_2 <- all_rides_2 %>% mutate(year = format(as.Date(date), "%Y"))
all_rides_2 <- all_rides_2 %>% mutate(month = format(as.Date(date), "%m"))
all_rides_2 <- all_rides_2 %>% mutate(day = format(as.Date(date), "%d"))
all_rides_2 <- all_rides_2 %>% mutate(day_of_week = format(as.Date(date), "%A"))

# 3 Calculating the trip duration in seconds
all_rides_2 <- all_rides_2 %>% 
mutate(ride_length = difftime(ended_at, started_at))

str(all_rides_2$ride_length)
is.difftime(all_rides_2$ride_length)

all_rides_2$ride_length <- as.numeric(all_rides_2$ride_length)
is.numeric(all_rides_2$ride_length)

# 4 Removing the bad data. 206 data to be removed. What type of bikes causes bad data?
bad_data <- all_rides_2 %>% 
filter(ride_length < 0)

bad_data %>% group_by(rideable_type) %>% 
summarise(count_rideable = n())

# Bad data removed
all_rides_2 <- all_rides_2 %>% 
filter(!(ride_length < 0))

# We cleaned the data. Now it's time to find some useful information about this data and visualization

# Calculates how much of the rides are casual or member
member_casual_count <- all_rides_2 %>% 
group_by(member_casual) %>%
summarise(person_count = n())

total_casual_rides <- member_casual_count %>% filter(member_casual == "casual") %>% pull(person_count)
total_member_rides <- member_casual_count %>% filter(member_casual == "member") %>% pull(person_count)

member_casual_count %>% 
ggplot(aes(x = member_casual, y = person_count, fill = member_casual)) + 
geom_bar(stat = "identity") + labs(Title = "Total Rides", subtitle = "Total of Casual and Member Riders", x = "Riders", y = "Ride Count", fill = "") +
scale_y_continuous(labels = comma) + annotate("text", x = 1, y = 1800000, label = total_casual_rides, size = 4) +
annotate("text", x = 2, y = 3300000, label = total_member_rides, size = 4)

# Now we compare how much casual and member count changed between 2023 and 2024
casual_2023 <- all_rides_2 %>% filter(year == 2023 & member_casual == "casual") %>% nrow() 
member_2023 <- all_rides_2 %>% filter(year == 2023 & member_casual == "member") %>% nrow() 

casual_2024 <- all_rides_2 %>% filter(year == 2024 & member_casual == "casual") %>% nrow() 
member_2024 <- all_rides_2 %>% filter(year == 2024 & member_casual == "member") %>% nrow() 

casual_vs_member_count_2023 <- all_rides_2 %>% filter(year == 2023) %>% 
group_by(member_casual) %>% 
summarise(rider_count = n()) %>% 
ggplot(aes(x = member_casual, y = rider_count, fill = member_casual)) + geom_bar(stat = "identity") +
labs(title= "Casual vs Member Count 2023", x = "Rider Type", y = "Rider Count", fill = "") +
scale_y_continuous(labels = comma) + theme_minimal() +
annotate("text", x = 1, y = 880000, label = casual_2023, size = 4) + 
annotate("text", x = 2, y = 1615000, label = member_2023, size = 4)

casual_vs_member_count_2024 <- all_rides_2 %>% filter(year == 2024) %>% 
group_by(member_casual) %>% 
summarise(rider_count = n()) %>% 
ggplot(aes(x = member_casual, y = rider_count, fill = member_casual)) + geom_bar(stat = "identity") +
labs(title= "Casual vs Member Count 2024", x = "Rider Type", y = "Rider Count", fill = "") +
scale_y_continuous(labels = comma) + theme_minimal() +
annotate("text", x = 1, y = 870000, label = casual_2024, size = 4) + 
annotate("text", x = 2, y = 1635000, label = member_2024, size = 4)

combined_plot <- casual_vs_member_count_2023 + casual_vs_member_count_2024
combined_plot

# Bike Usage Each Day Casual vs Member
all_rides_2 %>%
mutate(ride_length = as.numeric(ride_length, units = "secs"),
day_of_week = factor(day_of_week, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
group_by(day_of_week, member_casual) %>%
summarise(mean_ride_length = mean(ride_length), .groups = "drop") %>%
ggplot(aes(x = day_of_week, y = mean_ride_length, fill = member_casual)) +
geom_bar(stat = "identity", position = "dodge") +
facet_wrap(~member_casual) +
theme(axis.text.x = element_text(angle = 45)) +
labs(title = "Bike Usage Each Day", subtitle = "Casual vs Member",
x = "Days", y = "Avg Trip Duration (secs)", fill = "") +
scale_x_discrete(labels = c("Monday" = "Mon", "Tuesday" = "Tues", "Wednesday" = "Wed", 
"Thursday" = "Th", "Friday" = "Fri", "Saturday" = "Sat", "Sunday" = "Sun"))

# Rideable Type Usage Among Casuals vs Members
all_rides_2 %>% 
ggplot(aes(x = rideable_type, fill = rideable_type)) + geom_bar() + facet_wrap(~member_casual) + theme(axis.text.x = element_text(angle = 20)) +
labs(title = "Rideable Type Usage", subtitle = "Casual vs Member", x = "Rideable Type", fill = "Rideable Type") + 
scale_x_discrete(labels = c("classic_bike" = "Classic", "docked_bike" = "Docked", "electric_bike" = "Electric")) + 
scale_fill_discrete(labels = c("classic_bike" = "Classic", "docked_bike" = "Docked", "electric_bike" = "Electric"))

# Finding the popular stations
casual_station <- all_rides_2 %>% drop_na(start_station_name) %>%
filter(member_casual == "casual") %>% 
group_by(start_station_name) %>%
summarise(each_station_ride_count = n()) %>% 
arrange(-each_station_ride_count) %>% 
slice_head(n=5)

member_station <- all_rides_2 %>% drop_na(start_station_name) %>%
filter(member_casual == "member") %>% 
group_by(start_station_name) %>%
summarise(each_station_ride_count = n()) %>% 
arrange(-each_station_ride_count) %>% 
slice_head(n=5)

casual_station
member_station

casual_station <- casual_station %>% mutate(member_casual = "casual")
member_station <- member_station %>% mutate(member_casual = "member")

member_casual_station <- bind_rows(casual_station, member_station)

member_casual_station %>% arrange(each_station_ride_count) %>% 
ggplot(aes(x = start_station_name, y = each_station_ride_count, fill= start_station_name))+
geom_bar(stat = "identity")+ facet_wrap(~member_casual) + theme_minimal() + theme(axis.text.x = element_blank()) +
labs(title = "Top 5 Popular Stations", subtitle = "Casual vs Member", x = "Stations",y = "Ride Count", fill = "Station Name")

# Comparing the first half of the 2023 with first half of the 2024
total_rides_2023_01_06 <- all_rides_2 %>% filter(year == 2023) %>% nrow()#total rides of 2023 first six months
total_rides_2024_01_06 <- all_rides_2 %>% filter(year == 2024) %>% nrow()#total rides of 2024 first six months

plot_2023 <- all_rides_2 %>%
filter(year == 2023) %>% 
arrange(started_at) %>% 
group_by(month) %>% 
summarise(year = "2023", monthly_ride = n())

plot_2024 <- all_rides_2 %>% 
filter(year == 2024) %>% 
arrange(started_at) %>% 
group_by(month) %>% 
summarise(year = "2024", monthly_ride = n())

plot_2023 <- plot_2023 %>% ggplot(aes(x = month, y = monthly_ride, group = 1)) + geom_line() + geom_point(color = "red")+
labs(title= "Monthly Rides 2023", x = "Month", y = "Ride Count") +
scale_x_discrete(labels = c("01" = "Jan","02" = "Feb","03" = "Mar","04" = "Apr","05" = "May","06" = "June")) +
scale_y_continuous(labels = comma) + theme_minimal() +
annotate("text", x = 3, y = 600000, label = "Total Rides =", size = 4, color = "Red") + 
annotate("text", x = 3, y = 565000, label = total_rides_2023_01_06, size = 4, color = "Red")

plot_2024 <- plot_2024 %>% ggplot(aes(x = month, y = monthly_ride, group = 1)) + geom_line() + geom_point(color = "purple")+
labs(title= "Monthly Rides 2024", x = "Month", y = "Ride Count") +
scale_x_discrete(labels = c("01" = "Jan","02" = "Feb","03" = "Mar","04" = "Apr","05" = "May","06" = "June")) +
scale_y_continuous(labels = comma) + theme_minimal() +
annotate("text", x = 3, y = 600000, label = "Total Rides =", size = 4, color = "Purple") + 
annotate("text", x = 3, y = 565000, label = total_rides_2024_01_06, size = 4, color = "Purple")
# Combined this plots with patchwork package
combined_2023_2024 <- plot_2023 + plot_2024
combined_2023_2024

# Scatterplot for the people who took the bike more than 1 day
all_rides_2 %>%
filter(ride_length >86400) %>% 
ggplot(aes(x = ride_id, y = ride_length/3600/24, color = ride_length /3600/24)) + geom_jitter() + theme(axis.text.x = element_blank()) +
labs(title= "Trip Duration Distribution", subtitle = "Trip Duration is Longer Than 1 Day", x = "Each Ride Throughout the Year", y = "Days") +
scale_color_viridis_c()
