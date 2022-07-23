USE cyclist
-- all_cleaned is a duplicate of all_raw so not to lose out on the data
-- make a duplicate of the all_raw named as all_cleaned to run these queries 

select top 5 * from all_cleaned 
-- Getting a  bearing of all the columns in the table
-- Now we check for unique values for columns we can predict values for
-- rideable_type should have only 3 unique entries

select distinct(all_cleaned.rideable_type) from all_cleaned
-- There is an extra entry called "rideable_type"
-- Possibly arose from when the various CSVs were merged and the headings were added as data.
-- We perform a similar query on the member_casual problem

select distinct(all_cleaned.member_casual) from all_cleaned
-- More than expected unique values possible due to typos
-- Investigating all entries with member_casual column value as 'member_casual'

select * from all_cleaned where all_cleaned.member_casual = 'member_casual'
-- As expected, multiple entrieshave resulted from merging multiple CSVs. Deleting these rows.

delete from all_cleaned where all_cleaned.member_casual = 'member_casual'
-- Checking if the previous query was a success

select distinct(all_cleaned.member_casual) from all_cleaned
-- Distinct values have dropped to 3. To remove the typo in the extra entry.

select * from all_cleaned where all_cleaned.member_casual != 'casual' and all_cleaned.member_casual != 'member'
-- Viewing the rows with the typo

update all_cleaned set all_cleaned.member_casual = 'casual' where all_cleaned.member_casual != 'casual' and all_cleaned.member_casual != 'member'
-- With the typo corrected, We run the query again to be sure

select distinct(all_cleaned.member_casual) from all_cleaned
-- The column values are now in order
-- Checking for possible nulls in location names before proceeding

select count(all_cleaned.ride_id) from all_cleaned where all_cleaned.start_station_name is null
-- The majority of locations do not have a name. Since we have the geographical location, we can sort by those.
-- We can drop any other identification of starting and ending locations since they are majorly NULL

alter table all_cleaned drop column start_station_name, end_station_name, start_station_id, end_station_id
-- checking for any duplicate Ride IDs

select all_cleaned.ride_id, count(all_cleaned.ride_id) from all_cleaned group by ride_id having count(all_cleaned.ride_id) != 1
-- No duplicate Ride IDS
-- Finding the length of all rides by subtracting started_at from ended_at and adding it as a new column

alter table all_cleaned add duration_in_min as DATEDIFF(MINUTE, all_cleaned.started_at, all_cleaned.ended_at) PERSISTED
-- Checking if the calculations were performed correctly

select top 20 started_at, ended_at, duration_in_min from all_cleaned order by all_cleaned.duration_in_min asc
-- On seeing the results, we can observe that some values starting and ending times were mixed up causing negative durations
-- Correcting entries for columns where started_at was after ended_at

update all_cleaned set started_at = ended_at, ended_at = started_at where started_at > ended_at
-- Now we drop duration_in_min and re-calculate it
-- These steps could have been avoided if we had checked for consistenceis in starting and ending times beforehand

alter table all_cleaned drop column duration_in_min
-- Dropping earlier created column with faulty values

alter table all_cleaned add duration_in_min as DATEDIFF(MINUTE, all_cleaned.started_at, all_cleaned.ended_at) PERSISTED
-- Exchanging start and end values for wrong entries

select top 20 started_at, ended_at, duration_in_min from all_cleaned order by all_cleaned.duration_in_min asc
-- the minimum value is now 0 (trip duration was less than one minute)
-- Now we observe the maximum values for duration_in_min

select top 20 started_at, ended_at, duration_in_min from all_cleaned order by all_cleaned.duration_in_min desc
-- A day has about 24*60 = 1440 minutes. Some of these bikes were taken for repair which is why they were 'rented' for longer than a day
-- This can have a profounf effect on the analysis since we cannot map their every move but rather some

delete from all_cleaned where duration_in_min >= 1200
-- any ride longer than 20 hours hasb been removed from the analysis.

select top 5 * from all_cleaned

-- The queries below construct 2 extra tables that can be used to visualise the starting points on a map using the latitude and longitude 
-- Using latitudes and longitudes upto 4 decimal places allows you to lessen the data points while still being accurate upto 11 metres
alter table all_cleaned alter column start_lng decimal(6,4)
alter table all_cleaned alter column start_lat decimal(6,4) 
alter table all_cleaned alter column end_lng decimal(6,4) 
alter table all_cleaned alter column end_lat decimal(6,4)

-- Consolidating current table into two containing summarised infor regarding starting trips and ending trips
-- These tables will be used to visualise data in Tableau
-- For Start Trips
select count(all_cleaned.ride_id) as no_of_trips_started, all_cleaned.start_lat, all_cleaned.start_lng, 
cast(SUM(all_cleaned.duration_in_min) as float) / 60 as total_dur_hr_start, 
count(case when all_cleaned.member_casual='casual' then 1 end) as casual_trips_start,
cast(sum(case when all_cleaned.member_casual = 'casual' then all_cleaned.duration_in_min else 0 end) as float) / 60 as casual_dur_hr_start,  
count(case when all_cleaned.member_casual='member' then 1 end) as member_trips_start,
cast(sum(case when all_cleaned.member_casual = 'member' then all_cleaned.duration_in_min else 0 end) as float) / 60 as member_dur_hr_start  
into all_start_consolidated from all_cleaned group by all_cleaned.start_lat, all_cleaned.start_lng

-- For End Trips
select count(all_cleaned.ride_id) as no_of_trips_ended, all_cleaned.end_lat, all_cleaned.end_lng, 
cast(SUM(all_cleaned.duration_in_min) as float) / 60 as total_dur_hr_end, 
count(case when all_cleaned.member_casual='casual' then 1 end) as casual_trips_end,
cast(sum(case when all_cleaned.member_casual = 'casual' then all_cleaned.duration_in_min else 0 end) as float) / 60 as casual_dur_hr_end, 
count(case when all_cleaned.member_casual='member' then 1 end) as member_trips_end,
cast(sum(case when all_cleaned.member_casual = 'member' then all_cleaned.duration_in_min else 0 end) as float) / 60 as member_dur_hr_end  
into all_end_consolidated from all_cleaned group by all_cleaned.end_lat, all_cleaned.end_lng

-- The two required tables are ready. Now we add a majority_user column to make it easier for differentiating when we visualise it.
alter table all_start_consolidated add majority_user nvarchar(6)
alter table all_end_consolidated add majority_user nvarchar(6)
update all_start_consolidated set majority_user = case when member_dur_hr_start > casual_dur_hr_start then 'member' when member_dur_hr_start < casual_dur_hr_start then 'casual' else 'equal' end
update all_end_consolidated set majority_user = case when member_dur_hr_end > casual_dur_hr_end then 'member' when member_dur_hr_end < casual_dur_hr_end then 'casual' else 'equal' end

select * from all_end_consolidated -- copy to CSV
select * from all_start_consolidated -- copy to CSV

alter table all_cleaned drop column start_lat, end_lat, start_lng, end_lng
-- Deleting the data we will not feed for further analysis
-- The Python code can be run to analyse this all_cleaned table. 

-- bike usage by members / casuals categorised by type of type.
select all_cleaned.rideable_type, 
count(case when all_cleaned.member_casual = 'member' then 1 end) as number_of_rides_member, 
sum(case when all_cleaned.member_casual = 'member' then all_cleaned.duration_in_min end) as riding_time_min_member, 
avg(case when all_cleaned.member_casual = 'member' then cast(all_cleaned.duration_in_min as float) end) as average_ride_time_min_member,
count(case when all_cleaned.member_casual = 'casual' then 1 end) as number_of_rides_casual, 
sum(case when all_cleaned.member_casual = 'casual' then all_cleaned.duration_in_min end) as riding_time_min_casual, 
avg(case when all_cleaned.member_casual = 'casual' then cast(all_cleaned.duration_in_min as float) end) as average_ride_time_min_casual
from all_cleaned group by rideable_type
-- The result from this query was used to build the fromSQL excel data
select all_cleaned.member_casual, count(all_cleaned.ride_id) as number_of_rides, sum(all_cleaned.duration_in_min) as riding_time_avg, avg(all_cleaned.duration_in_min) as riding_time_avg_min from all_cleaned group by member_casual
-- The result from this query was used to build the fromSQL excel data
