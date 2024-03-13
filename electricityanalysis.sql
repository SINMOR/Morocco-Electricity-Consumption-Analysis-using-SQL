SELECT *
FROM powerconsumption
ALTER TABLE powerconsumption
ADD COLUMN newdate DATE

UPDATE powerconsumption
SET newdate = STR_TO_DATE(date,'%m/%d/%Y' )
ALTER TABLE powerconsumption
ADD COLUMN newtime TIME
UPDATE powerconsumption
SET powerconsumption.newtime = STR_TO_DATE(Time, '%h:%i:%s %p' )
# DATA ANALYSIS
-- Q1 WHAT ARE THE TOTAL POWER CONSUMPTION TRENDS ACROSS ALL ZONES OVER TIME
SELECT SUM(powerconsumption.pcz1),SUM(powerconsumption.pcz2),SUM(powerconsumption.pcz3)
FROM powerconsumption
## There is a higher total power consumption in ZONE 1 across all time compared to other zones
SELECT AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
## There is a higher average  power consumption in ZONE 1 across all time compared to other zones
SELECT MONTH(newdate) AS 'Month',SUM(powerconsumption.pcz1),SUM(powerconsumption.pcz2),SUM(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY  Month
## Across all zones there is a spike of high power consumption around the 6th month to 9th month
## There a linear drop of total power consumption from Jan to Feb .
## There is a constant total power consumption in zone 1 across the months
## Power consumption fluctuates in zone 3 across the 12 months
SELECT DAYOFMONTH(newdate) AS 'Day',AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY DAYOFMONTH(newdate)
##In Zone 1 Average  power consumption per day ranges from 30000 KW to 33000 Kw
##In Zone 2 Average  power consumption per day ranges from 19000 KW to 21000 Kw
##In Zone 3 Average  power consumption per day ranges from 17000 KW to 18500 Kw
SELECT MONTH(newdate) AS 'Month',AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY  Month
## There is a spike in the average increase in power consumption from June to August
## There is a significant drop in average power consumption from august to september
WITH MonthlyConsumption AS (
    SELECT
        MONTH(newdate) AS 'Month',
        pcz1,
        pcz2,
        pcz3
    FROM powerconsumption
)
SELECT
    MONTH(newdate),
    AVG(pcz1) AS Avg_Consumption_Zone1,
    AVG(pcz2) AS Avg_Consumption_Zone2,
    AVG(pcz3) AS Avg_Consumption_Zone3
FROM  MonthlyConsumption
GROUP BY MONTH(newdate)
ORDER BY MONTH(newdate)

SELECT DAYOFWEEK(newdate) AS 'Day',AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY DAYOFWEEK(newdate)
## There is a visible relationship between power consumption on weekdays and weekends
SELECT
    HOUR(newtime) AS hour_of_day,
    SUM(pcz1 + pcz2 + pcz3) AS total_consumption,
    RANK() OVER (ORDER BY  SUM(pcz1 + pcz2 + pcz3) DESC) as consumption_rank
FROM powerconsumption
GROUP BY 1
ORDER BY 3
##Peak demand hours is from 6pm to 11pm
##Less demand hours is morning hours and afternoon
## 6 am in the morning being the least while 8 pm being the highest
SELECT
    HOUR(newtime) AS hour_of_day,
    SUM(pcz1 + pcz2 + pcz3) AS Average_consumption,
    RANK() OVER (ORDER BY  AVG(pcz1 + pcz2 + pcz3) DESC) as consumption_rank
FROM powerconsumption
GROUP BY 1
ORDER BY 3

SELECT MONTH(newdate) ,MAX(powerconsumption.pcz1),MAX(powerconsumption.pcz2),MAX(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 1
## max power consumption occurred in the months of July and August across the zones
## This was attributed by the main Morrocco holidays which occurred from June to August

