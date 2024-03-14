SELECT *
FROM powerconsumption;
ALTER TABLE powerconsumption
ADD COLUMN newdate DATE;

UPDATE powerconsumption
SET newdate = STR_TO_DATE(date,'%m/%d/%Y' );
ALTER TABLE powerconsumption
ADD COLUMN newtime TIME;
UPDATE powerconsumption
SET powerconsumption.newtime = STR_TO_DATE(Time, '%h:%i:%s %p' );
# DATA ANALYSIS
-- Q1 WHAT ARE THE TOTAL POWER CONSUMPTION TRENDS ACROSS ALL ZONES OVER TIME(consumption analysis)
SELECT SUM(powerconsumption.pcz1),SUM(powerconsumption.pcz2),SUM(powerconsumption.pcz3)
FROM powerconsumption;
## There is a higher total power consumption in ZONE 1 across all time compared to other zones
SELECT AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption;
## There is a higher average  power consumption in ZONE 1 across all time compared to other zones
SELECT MONTH(newdate) AS 'Month',SUM(powerconsumption.pcz1),SUM(powerconsumption.pcz2),SUM(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY  Month;
## Across all zones there is a spike of high power consumption around the 6th month to 9th month
## There a linear drop of total power consumption from Jan to Feb .
## There is a constant total power consumption in zone 1 across the months
## Power consumption fluctuates in zone 3 across the 12 months
SELECT DAYOFMONTH(newdate) AS 'Day',AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY DAYOFMONTH(newdate);
##In Zone 1 Average  power consumption per day ranges from 30000 KW to 33000 Kw
##In Zone 2 Average  power consumption per day ranges from 19000 KW to 21000 Kw
##In Zone 3 Average  power consumption per day ranges from 17000 KW to 18500 Kw
SELECT MONTH(newdate) AS 'Month',AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY  Month;
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
ORDER BY MONTH(newdate);

SELECT DAYOFWEEK(newdate) AS 'Day',AVG(powerconsumption.pcz1),AVG(powerconsumption.pcz2),AVG(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY DAYOFWEEK(newdate);
## There is a visible relationship between power consumption on weekdays and weekends
SELECT
    HOUR(newtime) AS hour_of_day,
    SUM(pcz1 + pcz2 + pcz3) AS total_consumption,
    RANK() OVER (ORDER BY  SUM(pcz1 + pcz2 + pcz3) DESC) as consumption_rank
FROM powerconsumption
GROUP BY 1
ORDER BY 3;
##Peak demand hours is from 6pm to 11pm
##Less demand hours is morning hours and afternoon
## 6 am in the morning being the least while 8 pm being the highest
SELECT
    HOUR(newtime) AS hour_of_day,
    SUM(pcz1 + pcz2 + pcz3) AS Average_consumption,
    RANK() OVER (ORDER BY  AVG(pcz1 + pcz2 + pcz3) DESC) as consumption_rank
FROM powerconsumption
GROUP BY 1
ORDER BY 3;

SELECT MONTH(newdate) ,MAX(powerconsumption.pcz1),MAX(powerconsumption.pcz2),MAX(powerconsumption.pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 1;
## max power consumption occurred in the months of July and August across the zones
## This was attributed by the main Morocco holidays which occurred from June to August
## sj
-- Q2 How does the environmental factors affect power consumption
SELECT month(newdate), AVG(powerconsumption.humidity),AVG(pcz1 + pcz2 + pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 2;
## Low humid months experienced high power consumption that may  to August(summer)
## November and December and March  had high avg humidity but low average power consumption
## APRIL had the highest average humidity but low power consumption
SELECT
    CASE
        WHEN MONTH(newdate ) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(newdate ) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(newdate ) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(newdate ) IN (9, 10, 11) THEN 'Autumn'
        ELSE 'Unknown'
    END AS Season,
    AVG(pcz1) AS Avg_Consumption_Zone1,
    AVG(pcz2) AS Avg_Consumption_Zone2,
    AVG(pcz3) AS Avg_Consumption_Zone3
FROM
    powerconsumption

GROUP BY
    Season
ORDER BY
    FIELD(Season, 'Winter', 'Spring', 'Summer', 'Autumn');
## During the summer there was a high average power consumption
## Both Autumn and Summer have hot temperature hence high power consumption
## In winter there is a low power consumption across the zones
SELECT  MONTH(newdate),AVG(temperature),AVG(pcz1),AVG(pcz2),AVG(pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 2 DESC;
## There is an upward increase in average power consumption as temperatures rise
## When temperature reaches   an average of 20 degree celcius and above there is an increase in average power cosumption
SELECT  MONTH(newdate),AVG(temperature),SUM(pcz1),SUM(pcz2),SUM(pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 2 DESC;
SELECT
    MONTH(newdate) AS Month,
    AVG(temperature) AS Avg_Temperature,
    AVG(pcz1) AS Avg_Consumption_Zone1,
    AVG(pcz2) AS Avg_Consumption_Zone2,
    AVG(pcz3) AS Avg_Consumption_Zone3,
    CORR(temperature, pcz1) AS Correlation_Zone1,
    CORR(temperature, pcz2) AS Correlation_Zone2,
    CORR(Temperature, pcz3) AS Correlation_Zone3
FROM
    powerconsumption
GROUP BY
    MONTH(newdate)
ORDER BY
    Month;

SELECT  MONTH(newdate),AVG(windspeed),SUM(pcz1),SUM(pcz2),SUM(pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 2 DESC;
## High speed leads to higher power consumption
SELECT  MONTH(newdate),AVG(diffuseflows),SUM(pcz1),SUM(pcz2),SUM(pcz3)
FROM powerconsumption
GROUP BY 1
ORDER BY 2 DESC;

## May experienced the highest diffuse flows
## There is no significant relationship between diffuse flows and power consumption
-- Advanced: Identify anomalies in power consumption data using z-score


WITH ConsumptionZScores AS (
    SELECT
        newdate,
        AVG(pcz1) as avg1,
        STDDEV_POP(pcz1) as stdv1,
        AVG(pcz2) as avg2,
        STDDEV_POP(pcz2) as stdv2,
        AVG(pcz3) as avg3,
        STDDEV_POP(pcz3) as stdv3
    FROM
        powerconsumption
    GROUP BY
        newdate
)

SELECT
    pc.newdate,
    pc.pcz1,
    (pc.pcz1 - cz.avg1) / cz.stdv1 AS ZScore_Zone1,
    pc.pcz2,
    (pc.pcz2 - cz.avg2) / cz.stdv2 AS ZScore_Zone2,
    pc.pcz3,
    (pc.pcz3 - cz.avg3) / cz.stdv3 AS ZScore_Zone3
FROM
    powerconsumption pc
JOIN
    ConsumptionZScores cz ON pc.newdate = cz.newdate

# WHERE ABS((pc.pcz1 - cz.avg1) / cz.stdv1) > 3 OR ABS((pc.pcz2 - cz.avg2) / cz.stdv2) > 3 OR ABS((pc.pcz3 - cz.avg3) / cz.stdv3) > 3;


