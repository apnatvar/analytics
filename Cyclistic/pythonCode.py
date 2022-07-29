import pyodbc
import pandas as pd
from tabulate import tabulate
import datetime
import calendar
import csv

def findDay(date): # function to find the day on any given date
    try:
        day = datetime.datetime.strptime(date, '%Y-%m-%d').weekday()
    except:
        print(date)
        exit(0)
    return (calendar.day_name[day])

def findMonth(date): # function to find the day on any given date
    try:
        month1 = datetime.datetime.strptime(date, '%Y-%m-%d').month
    except:
        print(date)
        exit(0)
    return (calendar.month_abbr[month1])

conn = pyodbc.connect(
    "Driver={SQL Server Native Client 11.0};"
    "Server=.;"
    "Database=cyclist;"
    "Trusted_Connection=yes") # connection to MSSQL Database

df = pd.read_sql('select * from all_cleaned', conn) # load the enitre dataset from SQL

df['start_weekday'] = [findDay(str(i)[:10]) for i in df['started_at']] # generate weekday from existing dataset
df['month'] = [findMonth(str(i)[:10]) for i in df['started_at']] # generate weekday from existing dataset
# this could have also been done in SQL but as we were analysing this in Python it made more sense to complete it here
# print(df['month'].unique())
# exit(0)
# dividing the dataset in two based on user membership status
dfMember = df[df['member_casual']=='member'] # for only members
dfCasual = df[df['member_casual']=='casual'] # for casual users
# 'df' is total database.

#Constructin table 1
print(dfMember.describe(),'\n', dfCasual.describe())
# Comparing data from only these outputs, we can easily observe that the average riding time for Casuals is much higher than that for members.

""" Here we analyse data by various Metrics
No of Trips Started
% of Trips Started
Time Spent Riding (min)
Average Time Spent Riding (min)
% of Time Spent Riding
Mode of Time Spent Riding (min)
Median of Time Spent Riding (min)
Classic Bikes used
% of Trips Classic Bikes were used for
Electric Bikes used
% of Trips Electric Bikes used for
Docked Bikes used
% of Trips Docked Bikes used for
"""
fromPython1 = [
    ['No of Trips Started', len(dfMember), len(dfCasual), len(df)],
    ['% of Trips Started', len(dfMember)*100/len(df), len(dfCasual)*100/len(df), len(df)*100/len(df)],
    ['Time Spent Riding (min)', dfMember['duration_in_min'].sum(), dfCasual['duration_in_min'].sum(), df['duration_in_min'].sum()],
    ['Average Time Spent Riding (min)', dfMember['duration_in_min'].sum()/len(dfMember), dfCasual['duration_in_min'].sum()/len(dfCasual), df['duration_in_min'].sum()/len(df)],
    ['% of Time Spent Riding', dfMember['duration_in_min'].sum()*100/df['duration_in_min'].sum(), dfCasual['duration_in_min'].sum()*100/df['duration_in_min'].sum(), df['duration_in_min'].sum()*100/df['duration_in_min'].sum()],
    ['Mode of Time Spent Riding (min)', dfMember['duration_in_min'].mode()[0], dfCasual['duration_in_min'].mode()[0], df['duration_in_min'].mode()[0]],
    ['Median of Time Spent Riding (min)', dfMember['duration_in_min'].median(), dfCasual['duration_in_min'].median(), df['duration_in_min'].median()],
    ['Classic Bikes used', len(dfMember[dfMember['rideable_type']=='classic_bike']), len(dfCasual[dfCasual['rideable_type']=='classic_bike']), len(df[df['rideable_type']=='classic_bike'])],
    ['% of Trips Classic Bikes were used for', len(dfMember[dfMember['rideable_type']=='classic_bike'])*100/len(dfMember), len(dfCasual[dfCasual['rideable_type']=='classic_bike'])*100/len(dfCasual), len(df[df['rideable_type']=='classic_bike'])*100/len(df)],
    ['Electric Bikes used', len(dfMember[dfMember['rideable_type']=='electric_bike']), len(dfCasual[dfCasual['rideable_type']=='electric_bike']), len(df[df['rideable_type']=='electric_bike'])],
    ['% of Trips Electric Bikes used for', len(dfMember[dfMember['rideable_type']=='electric_bike'])*100/len(dfMember), len(dfCasual[dfCasual['rideable_type']=='electric_bike'])*100/len(dfCasual), len(df[df['rideable_type']=='electric_bike'])*100/len(df)],
    ['Docked Bikes used', len(dfMember[dfMember['rideable_type']=='docked_bike']), len(dfCasual[dfCasual['rideable_type']=='docked_bike']), len(df[df['rideable_type']=='docked_bike'])],
    ['% of Trips Docked Bikes used for', len(dfMember[dfMember['rideable_type']=='docked_bike'])*100/len(dfMember), len(dfCasual[dfCasual['rideable_type']=='docked_bike'])*100/len(dfCasual), len(df[df['rideable_type']=='docked_bike'])*100/len(df)],
    ]
headers1=['Statistics', 'Member', 'Casual', 'Total']
print(tabulate(fromPython1, headers=headers1, tablefmt="fancy_grid"))

""" From the outputs we can observe that:
No of Trips Started is higher for members
% of Trips Started is higher for members
Time Spent Riding (min) is higher for casuals
Average Time Spent Riding (min) is higher for casuals
% of Time Spent Riding is higher for casuals
Mode of Time Spent Riding (min) is higher for casuals
Median of Time Spent Riding (min) is higher for casuals

This suggests that although members make more trips than casuals,
casuals spend muchh more time using the service.
Members are the majority users by count of trips.
Casuals are the majority users by time spent riding.
"""

"""
Here we analyse data for each day.
We have already established that casuals have a higher average riding time than members """
headers2=['No. of Trips on', 'Member', 'Casual', 'Total']
fromPython2 = [
    ['Monday', len(dfMember[dfMember['start_weekday']=='Monday']), len(dfCasual[dfCasual['start_weekday']=='Monday']), len(df[df['start_weekday']=='Monday']) ],
    ['Tuesday', len(dfMember[dfMember['start_weekday']=='Tuesday']), len(dfCasual[dfCasual['start_weekday']=='Tuesday']), len(df[df['start_weekday']=='Tuesday']) ],
    ['Wednesday', len(dfMember[dfMember['start_weekday']=='Wednesday']), len(dfCasual[dfCasual['start_weekday']=='Wednesday']), len(df[df['start_weekday']=='Wednesday']) ],
    ['Thursday', len(dfMember[dfMember['start_weekday']=='Thursday']), len(dfCasual[dfCasual['start_weekday']=='Thursday']), len(df[df['start_weekday']=='Thursday']) ],
    ['Friday', len(dfMember[dfMember['start_weekday']=='Friday']), len(dfCasual[dfCasual['start_weekday']=='Friday']), len(df[df['start_weekday']=='Friday']) ],
    ['Saturday', len(dfMember[dfMember['start_weekday']=='Saturday']), len(dfCasual[dfCasual['start_weekday']=='Saturday']), len(df[df['start_weekday']=='Saturday']) ],
    ['Sunday', len(dfMember[dfMember['start_weekday']=='Sunday']), len(dfCasual[dfCasual['start_weekday']=='Sunday']), len(df[df['start_weekday']=='Sunday']) ],
    ]
print(tabulate(fromPython2, headers=headers2, tablefmt="fancy_grid"))

headers3=['Duration of Trips on', 'Member', 'Casual', 'Total']
fromPython3 = [
    ['Monday', dfMember[dfMember['start_weekday']=='Monday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Monday']['duration_in_min'].sum(), df[df['start_weekday']=='Monday']['duration_in_min'].sum() ],
    ['Tuesday', dfMember[dfMember['start_weekday']=='Tuesday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Tuesday']['duration_in_min'].sum(), df[df['start_weekday']=='Tuesday']['duration_in_min'].sum() ],
    ['Wednesday', dfMember[dfMember['start_weekday']=='Wednesday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Wednesday']['duration_in_min'].sum(), df[df['start_weekday']=='Wednesday']['duration_in_min'].sum() ],
    ['Thursday', dfMember[dfMember['start_weekday']=='Thursday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Thursday']['duration_in_min'].sum(), df[df['start_weekday']=='Thursday']['duration_in_min'].sum() ],
    ['Friday', dfMember[dfMember['start_weekday']=='Friday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Friday']['duration_in_min'].sum(), df[df['start_weekday']=='Friday']['duration_in_min'].sum() ],
    ['Saturday', dfMember[dfMember['start_weekday']=='Saturday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Saturday']['duration_in_min'].sum(), df[df['start_weekday']=='Saturday']['duration_in_min'].sum() ],
    ['Sunday', dfMember[dfMember['start_weekday']=='Sunday']['duration_in_min'].sum(), dfCasual[dfCasual['start_weekday']=='Sunday']['duration_in_min'].sum(), df[df['start_weekday']=='Sunday']['duration_in_min'].sum() ],
    ]
print(tabulate(fromPython3, headers=headers3, tablefmt="fancy_grid"))

"""
Here we analyse data for each month"""
headers4=['Duration of Trips on', 'Member', 'Casual', 'Total']
fromPython4 = [
    ['Jan', dfMember[dfMember['month']=='Jan']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Jan']['duration_in_min'].sum(), df[df['month']=='Jan']['duration_in_min'].sum() ],
    ['Feb', dfMember[dfMember['month']=='Feb']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Feb']['duration_in_min'].sum(), df[df['month']=='Feb']['duration_in_min'].sum() ],
    ['Mar', dfMember[dfMember['month']=='Mar']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Mar']['duration_in_min'].sum(), df[df['month']=='Mar']['duration_in_min'].sum() ],
    ['Apr', dfMember[dfMember['month']=='Apr']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Apr']['duration_in_min'].sum(), df[df['month']=='Apr']['duration_in_min'].sum() ],
    ['May', dfMember[dfMember['month']=='May']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='May']['duration_in_min'].sum(), df[df['month']=='May']['duration_in_min'].sum() ],
    ['Jun', dfMember[dfMember['month']=='Jun']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Jun']['duration_in_min'].sum(), df[df['month']=='Jun']['duration_in_min'].sum() ],
    ['Jul', dfMember[dfMember['month']=='Jul']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Jul']['duration_in_min'].sum(), df[df['month']=='Jul']['duration_in_min'].sum() ],
    ['Aug', dfMember[dfMember['month']=='Aug']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Aug']['duration_in_min'].sum(), df[df['month']=='Aug']['duration_in_min'].sum() ],
    ['Sep', dfMember[dfMember['month']=='Sep']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Sep']['duration_in_min'].sum(), df[df['month']=='Sep']['duration_in_min'].sum() ],
    ['Oct', dfMember[dfMember['month']=='Oct']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Oct']['duration_in_min'].sum(), df[df['month']=='Oct']['duration_in_min'].sum() ],
    ['Nov', dfMember[dfMember['month']=='Nov']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Nov']['duration_in_min'].sum(), df[df['month']=='Nov']['duration_in_min'].sum() ],
    ['Dec', dfMember[dfMember['month']=='Dec']['duration_in_min'].sum(), dfCasual[dfCasual['month']=='Dec']['duration_in_min'].sum(), df[df['month']=='Dec']['duration_in_min'].sum() ],
    ]
print(tabulate(fromPython4, headers=headers4, tablefmt="fancy_grid"))

headers5=['Number of Trips on', 'Member', 'Casual', 'Total']
fromPython5 = [
    ['Jan',len(dfMember[dfMember['month']=='Jan']),len(dfCasual[dfCasual['month']=='Jan']),len(df[df['month']=='Jan'])],
    ['Feb',len(dfMember[dfMember['month']=='Feb']),len(dfCasual[dfCasual['month']=='Feb']),len(df[df['month']=='Feb'])],
    ['Mar',len(dfMember[dfMember['month']=='Mar']),len(dfCasual[dfCasual['month']=='Mar']),len(df[df['month']=='Mar'])],
    ['Apr',len(dfMember[dfMember['month']=='Apr']),len(dfCasual[dfCasual['month']=='Apr']),len(df[df['month']=='Apr'])],
    ['May',len(dfMember[dfMember['month']=='May']),len(dfCasual[dfCasual['month']=='May']),len(df[df['month']=='May'])],
    ['Jun',len(dfMember[dfMember['month']=='Jun']),len(dfCasual[dfCasual['month']=='Jun']),len(df[df['month']=='Jun'])],
    ['Jul',len(dfMember[dfMember['month']=='Jul']),len(dfCasual[dfCasual['month']=='Jul']),len(df[df['month']=='Jul'])],
    ['Aug',len(dfMember[dfMember['month']=='Aug']),len(dfCasual[dfCasual['month']=='Aug']),len(df[df['month']=='Aug'])],
    ['Sep',len(dfMember[dfMember['month']=='Sep']),len(dfCasual[dfCasual['month']=='Sep']),len(df[df['month']=='Sep'])],
    ['Oct',len(dfMember[dfMember['month']=='Oct']),len(dfCasual[dfCasual['month']=='Oct']),len(df[df['month']=='Oct'])],
    ['Nov',len(dfMember[dfMember['month']=='Nov']),len(dfCasual[dfCasual['month']=='Nov']),len(df[df['month']=='Nov'])],
    ['Dec',len(dfMember[dfMember['month']=='Dec']),len(dfCasual[dfCasual['month']=='Dec']),len(df[df['month']=='Dec'])],
    ]
print(tabulate(fromPython5, headers=headers5, tablefmt="fancy_grid"))

# writing all tables to a CSV File
f = open('fromPython1.csv','w')
w = csv.writer(f)
w.writerow(headers1)
w.writerows(fromPython1)
w.writerow(headers2)
w.writerows(fromPython2)
w.writerow(headers3)
w.writerows(fromPython3)
w.writerow(headers4)
w.writerows(fromPython4)
w.writerow(headers5)
w.writerows(fromPython5)
f.close()
