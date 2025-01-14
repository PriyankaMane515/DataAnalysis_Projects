
--Determine time when users were most active
--Calculating avg intensity for every hour, High intensity or high mets implies more people are physically active during that time
with avg_inst AS(
Select DISTINCT
(cast(ActivityHour as time)) AS Activity_Time,
AVG(TotalIntensity) Over (partition by datepart(hour, ActivityHour)) as Avg_Intensity,
AVG(METs/10.0) OVER (PARTITION BY datepart(hour, ActivityHour)) AS avg_METs
FROM
Hourly_Activity ht
JOIN minuteMETsNarrow as mt 
on ht.Id = mt.Id AND ht.ActivityHour = mt.ActivityMinute)
SELECT Activity_Time,
ROUND(Avg_Intensity,2) as AV_Intensity,
cast(avg_METs as numeric(36,2)) as AV_MET
from avg_inst
order BY
AV_Intensity Desc

---- Count of Type of Users based on Number of Steps:
WITH total_users AS (
SELECT Id, ROUND(AVG(TotalSteps), 0) AS Avg_Total_Steps,
	CASE
		WHEN ROUND(AVG(TotalSteps), 0) < 5000 THEN 'Inactive User'
        WHEN ROUND(AVG(TotalSteps), 0) BETWEEN 5000 AND 7499 THEN 'Low Active User'
        WHEN ROUND(AVG(TotalSteps), 0) BETWEEN 7500 AND 9999 THEN 'Average Active User'
        WHEN ROUND(AVG(TotalSteps), 0) BETWEEN 10000 AND 12499 THEN 'Active User'
        WHEN ROUND(AVG(TotalSteps), 0) > 12500 THEN 'Very Active User'
	END AS User_Type
FROM dailyActivity_Cleaned
GROUP BY Id )
SELECT User_type,COUNT(Id) as User_Count FROM total_users
GROUP by User_type
ORDER by User_Count DESC


--AVG steps taken by weekdays
SELECT ActivityDay AS WeekDays, 
ROUND(AVG(TotalSteps),2) as avg_steps
from dailyActivity_Cleaned
GROUP BY activityday ORDER BY 
CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 

--avg/total steps taken by hour
SELECT 
DATEPART(HOUR,ActivityHour) AS Activty_Hour, 
ROUND(SUM(steptotal),2) as Total_steps_per_hour
from Hourly_Activity
GROUP BY DATEPART(HOUR,ActivityHour) ORDER BY 1

--Total steps and distance by ID
SELECT
Id,
SUM(TotalSteps) as Steps,
SUM(TotalDistance) as Distance,
ROUND(SUM(TotalSteps)/SUM(TotalDistance),2) as StepsPerDistance
from 
dailyActivity_Cleaned
GROUP BY Id
ORDER by 1



--Avg travel distance per day
SELECT
ActivityDay as WeekDays,
ROUND(avg(TotalDistance),2) as avg_Travel_distance
from dailyActivity_Cleaned
GROUP by ActivityDay ORDER by 
CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 

-- AVG calories per day
SELECT
ActivityDay as Weekdays,
round(AVG(Calories),2) as Calories_perDay
from 
dailyActivity_Cleaned
GROUP by ActivityDay
ORDER by 
CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 

--AVG calories per hour
SELECT 
DATEPART(HOUR,ActivityHour) AS Activty_Hour, 
ROUND(AVG(calories),2) as avg_calories_PerHour
from 
Hourly_Activity
GROUP by DATEPART(HOUR,ActivityHour)
ORDER by 1

--Physical Activity: avg intensity by hour
SELECT
DATEPART(HOUR,ActivityHour) AS Activty_Hour, 
ROUND(AVG(TotalIntensity),2) as IntensityPerHour
from Hourly_Activity
GROUP by DATEPART(HOUR,ActivityHour)
ORDER by 2 DESC

--AVG intensity by day
SELECT
Activityday as Weekdays,
ROUND(AVG(TotalIntensity),2) as IntensityPerDay
from Hourly_Activity
GROUP by Activityday
ORDER BY
CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 

--calculate avg minutes of each activity
SELECT
cast(ROUND((AVG(VeryActiveMinutes)),2) as numeric(36,2)) as avg_VeryActiveMinutes,
cast(round(AVG(FairlyActiveMinutes),2) as numeric(36,2)) as avg_FairlyActiveMinutes,
cast(ROUND(AVG(LightlyActiveMinutes),2) as numeric(36,2))  as avg_LightlyActiveMinutes,
cast(ROUND(AVG(SedentaryMinutes),2) as numeric(36,2)) as avg_SedentaryMinutes
from dailyActivity_Cleaned

--calculate avg minutes of each activity by Day
SELECT
activityday as weekdays,
cast(ROUND((AVG(VeryActiveMinutes)/60.0),2) as numeric(36,2)) as avg_VeryActiveMinutes,
cast(round(AVG(FairlyActiveMinutes)/60.0,2) as numeric(36,2)) as avg_FairlyActiveMinutes,
cast(ROUND(AVG(LightlyActiveMinutes)/60.0,2) as numeric(36,2))  as avg_LightlyActiveMinutes,
cast(ROUND(AVG(SedentaryMinutes)/60.0,2) as numeric(36,2)) as avg_SedentaryMinutes
from dailyActivity_Cleaned
GROUP by activityday
order by 
CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 

--Calculate daily avg heart rate
SELECT
ActivityDay as weekdays,
AVG([Value]) as AVg_HeartRatePerDay
From 
heartrate_seconds
WHERE ActivityDay = 'Monday'
GROUP BY ActivityDay
ORDER by 2 DESC

--Calculating avg heart rate per hour
SELECT
DATEPART(HOUR,[Time]) as ActivityHour,
AVG([Value]) as Avg_heartRatePerHour
from heartrate_seconds
GROUP by DATEPART(HOUR,[Time])
ORDER by 2 DESC

--calculating avg sleeping hours per day
SELECT
ActivityDay as Weekdays,
CAST(ROUND(AVG(TotalMinutesAsleep)/60.0,2) as numeric(36,2)) as avg_min_asleep,
CAST(ROUND(AVG(TotalTimeInBed)/60.0,2) as numeric(36,2)) as avg_time_inBed
from sleep_Day
GROUP by ActivityDay
order by 
CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 


-- 4. Total Steps and Distance by Id:
SELECT DISTINCT Id,
SUM(TotalSteps) as Total_Steps,
ROUND(SUM(TotalDistance),2)  as Total_Distance,
ROUND(SUM(TotalSteps)/SUM(TotalDistance),2) as Steps_per_Distance
from dailyActivity_Cleaned
GROUP by Id
ORDER by Id

---- 6. Correlation of Steps & Active Minutes (Walking or doing other tasks?):
SELECT
TotalSteps,
SUM(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes) as total_mins_tracking,
SUM(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) as Active_mins,
SUM(SedentaryMinutes) as Inactive_min
from dailyActivity_Cleaned
GROUP by TotalSteps ORDER by 1 DESC

-- Active and Inactive minutes by days of week
SELECT activityday as weekdays,
SUM(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes+SedentaryMinutes) as total_mins_tracking,
SUM(VeryActiveMinutes+FairlyActiveMinutes+LightlyActiveMinutes) as Active_mins,
SUM(SedentaryMinutes) as Inactive_min
from dailyActivity_Cleaned
GROUP by activityday
order by CAse activityday
WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
end 



--Proportion of Calories Per Distance by Day
SELECT
ActivityDay as Weekdays,
ROUND(SUM(Calories),2)  as calories_perDay,
ROUND(SUM(TotalDistance),2) as DistancePerDay,
ROUND(SUM(Calories) / SUM(TotalDistance),2) as CaloryPerDistance
from 
dailyActivity_Cleaned
GROUP by ActivityDay
ORDER BY
  CASE ActivityDay
      WHEN 'Sunday' THEN 1
      WHEN 'Monday' THEN 2
      WHEN 'Tuesday' THEN 3
      WHEN 'Wednesday' THEN 4
      WHEN 'Thursday' THEN 5
      WHEN 'Friday' THEN 6 
      WHEN 'Saturday' THEN 7
  END
