## EPA Air Quality Database Query 
Pieces of SQL code that answear various questions about the EPA air quality database using Big Query.

#### have the counties a unique code throughout the country?
Answer: Yes
```sql
SELECT 
    DISTINCT county_name, county_code 
FROM
    `bigquery-public-data.epa_historical_air_quality.co_daily_summary` 

ORDER BY 
    county_code    
```

#### Is the site number unique throughout the country or only within counties?
 Answer: Site number is unique only whithin counties.
```sql
SELECT site_num,
    COUNT(DISTINCT county_name) as number_of_counties

FROM 
    `bigquery-public-data.epa_historical_air_quality.co_daily_summary` 

GROUP BY site_num
ORDER BY site_num;
```
#### How many distict site is there within each county that measures CO?
Answer: As a example, Los Angeles has the highest number (27 sites)
```sql
 SELECT 
    county_name,
    COUNT(DISTINCT site_num) as dist_site_num
    
 FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary` 

GROUP BY  county_name
ORDER BY dist_site_num DESC
```

#### How many sites is there whitin each county?
Answer: County 031 has the largest number of sites (315 sites)
```sql
WITH 
co_table AS (SELECT     
                CONCAT(co.county_code,"_", co.site_num) as site_id,
            FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary` as co
            GROUP BY site_id
            )    
, hap_table AS (SELECT      
                    CONCAT(hap.county_code,"_", hap.site_num) as site_id,
                FROM `bigquery-public-data.epa_historical_air_quality.hap_daily_summary` as hap        
                GROUP BY site_id
                )   
, no2_table AS (SELECT     
                    CONCAT(no2.county_code,"_", no2.site_num) as site_id,
                FROM `bigquery-public-data.epa_historical_air_quality.no2_daily_summary` as no2
                GROUP BY site_id
                )  
, nonoxny_table AS (SELECT      
                        CONCAT(nonoxny.county_code,"_", nonoxny.site_num) as site_id,
                    FROM `bigquery-public-data.epa_historical_air_quality.nonoxnoy_daily_summary` as nonoxny                  
                    GROUP BY site_id
                    )
,ozone_table AS (SELECT      
                    CONCAT(ozone.county_code,"_", ozone.site_num) as site_id,
                FROM `bigquery-public-data.epa_historical_air_quality.o3_daily_summary` as ozone
                GROUP BY site_id
                )
,voc_table AS (SELECT     
                    CONCAT(voc.county_code,"_", voc.site_num) as site_id,
                FROM `bigquery-public-data.epa_historical_air_quality.voc_daily_summary` as voc
                GROUP BY site_id
                )
,so2_table AS (SELECT      
                    CONCAT(so2.county_code,"_", so2.site_num) as site_id,
                FROM `bigquery-public-data.epa_historical_air_quality.so2_daily_summary` as so2
                GROUP BY site_id
                )
,pm10_table AS (SELECT      
                    CONCAT(pm10.county_code,"_", pm10.site_num) as site_id,
                    FROM `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary` as pm10
                GROUP BY site_id
                )
,pm25_frm_table AS (SELECT      
                        CONCAT(pm25_frm.county_code,"_", pm25_frm.site_num) as site_id,
                    FROM `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary` as pm25_frm
                    GROUP BY site_id
                )
,pm25_nonfrm_table AS (SELECT      
                            CONCAT(pm25_nonfrm.county_code,"_", pm25_nonfrm.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary` as pm25_nonfrm
                        GROUP BY site_id
                        )
,pm25_speciation_table AS (SELECT      
                                CONCAT(pm25_speciation.county_code,"_", pm25_speciation.site_num) as site_id,
                            FROM `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary` as pm25_speciation
                            GROUP BY site_id
                            )
, final_table AS (SELECT      
                    CASE 
                    WHEN co_table.site_id IS NOT NULL THEN co_table.site_id 
                    WHEN hap_table.site_id IS NOT NULL THEN hap_table.site_id
                    WHEN nonoxny_table.site_id IS NOT NULL THEN nonoxny_table.site_id
                    WHEN ozone_table.site_id IS NOT NULL THEN ozone_table.site_id
                    WHEN voc_table.site_id IS NOT NULL THEN voc_table.site_id
                    WHEN so2_table.site_id IS NOT NULL THEN so2_table.site_id
                    WHEN pm10_table.site_id IS NOT NULL THEN pm10_table.site_id
                    WHEN pm25_frm_table.site_id IS NOT NULL THEN pm25_frm_table.site_id
                    WHEN pm25_nonfrm_table.site_id IS NOT NULL THEN pm25_nonfrm_table.site_id
                    WHEN pm25_speciation_table.site_id IS NOT NULL THEN pm25_speciation_table.site_id
                    ELSE no2_table.site_id
                    END AS site_id,
                FROM co_table
                FULL OUTER JOIN hap_table ON co_table.site_id =hap_table.site_id
                FULL OUTER JOIN no2_table ON co_table.site_id =no2_table.site_id
                FULL OUTER JOIN nonoxny_table ON co_table.site_id =nonoxny_table.site_id 
                FULL OUTER JOIN ozone_table ON co_table.site_id =ozone_table.site_id
                FULL OUTER JOIN pm10_table ON co_table.site_id =pm10_table.site_id
                FULL OUTER JOIN so2_table ON co_table.site_id =so2_table.site_id
                FULL OUTER JOIN voc_table ON co_table.site_id =voc_table.site_id
                FULL OUTER JOIN pm25_frm_table ON co_table.site_id =pm25_frm_table.site_id
                FULL OUTER JOIN pm25_nonfrm_table ON co_table.site_id =pm25_nonfrm_table.site_id
                FULL OUTER JOIN pm25_speciation_table ON co_table.site_id =pm25_speciation_table.site_id
                 )
       
SELECT 
    county_code,
    COUNT(site_num) AS sites_total
FROM (SELECT
        LEFT(final_table.site_id,3) AS county_code,
        RIGHT(final_table.site_id,4) AS site_num
        FROM final_table 
        )    
   
GROUP BY county_code
ORDER BY sites_total DESC
LIMIT 500 
```
#### Is there any typos in the state names?
Answer: NO
```sql

SELECT DISTINCT state_name
FROM (SELECT state_name FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.hap_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.no2_daily_summary`
        UNION DISTINCT 
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.o3_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.voc_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.so2_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary`
        UNION DISTINCT
        SELECT state_name FROM  `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary`
        )
ORDER BY state_name
 ```

#### How many sites are there in each state?
Answer: Florida, for example, has 564 measurement sites.
```sql
SELECT DISTINCT state_name, SUM(n_sites) as n_sites
FROM (SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.hap_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.no2_daily_summary` GROUP BY state_name
        UNION DISTINCT 
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.o3_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name ,COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.voc_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name ,COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.so2_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary` GROUP BY state_name
        UNION DISTINCT 
        SELECT state_name ,COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary` GROUP BY state_name
        )
GROUP BY state_name
ORDER BY state_name
 
 ```
 
#### How many sites are there in total?
Answer: 16878 sites of measurement
```sql
SELECT  SUM(n_sites) as n_sites
FROM (SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.hap_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.no2_daily_summary` GROUP BY state_name
        UNION DISTINCT 
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.o3_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name ,COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.voc_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name ,COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.so2_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary` GROUP BY state_name
        UNION DISTINCT
        SELECT state_name, COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary` GROUP BY state_name
        UNION DISTINCT 
        SELECT state_name ,COUNT(DISTINCT CONCAT(county_code,site_num)) n_sites FROM  `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary` GROUP BY state_name
        )
 
```

####  Since the start of data collection, how many daily measurements did each site do for Carbon Monoxide (CO) across the country?

```sql
SELECT    
    co_id.site_id,
    COUNT(co_id.site_id) as n_measuremants
    
 FROM (SELECT     
            CONCAT(co.county_code,"_", co.site_num) as site_id,
        FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary` as co) as co_id

GROUP BY co_id.site_id
ORDER BY n_measuremants DESC
```
####  Since the start of data collection, how many daily measuraments did each site do for all pollutatns across the country??
Answer: the largest amount of data collection was 980.902 , wich were made by the site 1039 in the County 201.
```sql
WITH 
co_table AS (SELECT    
                co_id.site_id,
                COUNT(co_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(co.county_code,"_", co.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary` as co) as co_id

                        GROUP BY co_id.site_id
                        )    
, hap_table AS (SELECT 
                hap_id.site_id,
                COUNT(hap_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(hap.county_code,"_", hap.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.hap_daily_summary` as hap) as hap_id

                GROUP BY hap_id.site_id
                ORDER BY n_mea DESC)   
, no2_table AS (SELECT 
                no2_id.site_id,
                COUNT(no2_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(no2.county_code,"_", no2.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.hap_daily_summary` as no2
                        ) as no2_id

                        GROUP BY no2_id.site_id
                )  
, nonoxny_table AS (SELECT 
                nonoxny_id.site_id,
                COUNT(nonoxny_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(nonoxny.county_code,"_", nonoxny.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.nonoxnoy_daily_summary` as nonoxny
                        ) as nonoxny_id

                        GROUP BY nonoxny_id.site_id
                )
,ozone_table AS (SELECT 
                ozone_id.site_id,
                COUNT(ozone_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(ozone.county_code,"_", ozone.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.o3_daily_summary` as ozone
                        ) as ozone_id

                GROUP BY ozone_id.site_id
                )
,voc_table AS (SELECT 
                voc_id.site_id,
                COUNT(voc_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(voc.county_code,"_", voc.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.voc_daily_summary` as voc
                        ) as voc_id

                GROUP BY voc_id.site_id
                )
,so2_table AS (SELECT 
                so2_id.site_id,
                COUNT(so2_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(so2.county_code,"_", so2.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.so2_daily_summary` as so2
                        ) as so2_id

                GROUP BY so2_id.site_id
                )
,pm10_table AS (SELECT 
                pm10_id.site_id,
                COUNT(pm10_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(pm10.county_code,"_", pm10.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary` as pm10
                        ) as pm10_id

                GROUP BY pm10_id.site_id
                )
,pm25_frm_table AS (SELECT 
                pm25_frm_id.site_id,
                COUNT(pm25_frm_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(pm25_frm.county_code,"_", pm25_frm.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary` as pm25_frm
                        ) as pm25_frm_id

                GROUP BY pm25_frm_id.site_id
                )
,pm25_nonfrm_table AS (SELECT 
                pm25_nonfrm_id.site_id,
                COUNT(pm25_nonfrm_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(pm25_nonfrm.county_code,"_", pm25_nonfrm.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary` as pm25_nonfrm
                        ) as pm25_nonfrm_id

                GROUP BY pm25_nonfrm_id.site_id
                )
,pm25_speciation_table AS (SELECT 
                pm25_speciation_id.site_id,
                COUNT(pm25_speciation_id.site_id) as n_mea
    
                FROM (SELECT     
                        CONCAT(pm25_speciation.county_code,"_", pm25_speciation.site_num) as site_id,
                        FROM `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary` as pm25_speciation
                        ) as pm25_speciation_id

                GROUP BY pm25_speciation_id.site_id
                )
SELECT      
    CASE 
    WHEN co_table.site_id IS NOT NULL THEN co_table.site_id 
    WHEN hap_table.site_id IS NOT NULL THEN hap_table.site_id
    WHEN nonoxny_table.site_id IS NOT NULL THEN nonoxny_table.site_id
    WHEN ozone_table.site_id IS NOT NULL THEN ozone_table.site_id
    WHEN voc_table.site_id IS NOT NULL THEN voc_table.site_id
    WHEN so2_table.site_id IS NOT NULL THEN so2_table.site_id
    WHEN pm10_table.site_id IS NOT NULL THEN pm10_table.site_id
    WHEN pm25_frm_table.site_id IS NOT NULL THEN pm25_frm_table.site_id
    WHEN pm25_nonfrm_table.site_id IS NOT NULL THEN pm25_nonfrm_table.site_id
    WHEN pm25_speciation_table.site_id IS NOT NULL THEN pm25_speciation_table.site_id
    ELSE no2_table.site_id
    END AS site_id,
    (CASE WHEN co_table.n_mea IS NULL THEN 0 ELSE co_table.n_mea END
    +
    CASE WHEN hap_table.n_mea IS NULL THEN 0 ELSE hap_table.n_mea END
    +
    CASE WHEN no2_table.n_mea IS NULL THEN 0 ELSE no2_table.n_mea END
    +
    CASE WHEN nonoxny_table.n_mea IS NULL THEN 0 ELSE nonoxny_table.n_mea END
    +
    CASE WHEN ozone_table.n_mea IS NULL THEN 0 ELSE ozone_table.n_mea END
    +
    CASE WHEN voc_table.n_mea IS NULL THEN 0 ELSE voc_table.n_mea END
    +
    CASE WHEN pm25_frm_table.n_mea IS NULL THEN 0 ELSE pm25_frm_table.n_mea END
    +
    CASE WHEN pm25_nonfrm_table.n_mea IS NULL THEN 0 ELSE pm25_nonfrm_table.n_mea END
    +
    CASE WHEN pm25_speciation_table.n_mea IS NULL THEN 0 ELSE pm25_speciation_table.n_mea END
    +
    CASE WHEN pm10_table.n_mea IS NULL THEN 0 ELSE pm10_table.n_mea END
    +
    CASE WHEN so2_table.n_mea IS NULL THEN 0 ELSE so2_table.n_mea END 
    ) AS mea_total,
    
FROM co_table
FULL OUTER JOIN hap_table ON co_table.site_id =hap_table.site_id
FULL OUTER JOIN no2_table ON co_table.site_id =no2_table.site_id
FULL OUTER JOIN nonoxny_table ON co_table.site_id =nonoxny_table.site_id 
FULL OUTER JOIN ozone_table ON co_table.site_id =ozone_table.site_id
FULL OUTER JOIN pm10_table ON co_table.site_id =pm10_table.site_id
FULL OUTER JOIN so2_table ON co_table.site_id =so2_table.site_id
FULL OUTER JOIN voc_table ON co_table.site_id =voc_table.site_id
FULL OUTER JOIN pm25_frm_table ON co_table.site_id =pm25_frm_table.site_id
FULL OUTER JOIN pm25_nonfrm_table ON co_table.site_id =pm25_nonfrm_table.site_id
FULL OUTER JOIN pm25_speciation_table ON co_table.site_id =pm25_speciation_table.site_id

ORDER BY mea_total DESC
```

#### How many parameters are measured and in which time perid have they been collected? 
Answer: There are 259 different parameters and the oldest record is from 1990-01-01.
```sql
SELECT 
    DISTINCT parameter_name, 
    CONCAT(CAST(MIN(date_local) as STRING), "_TO_",CAST(MAX(date_local) as STRING)) as intervall
FROM (SELECT parameter_name, date_local FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.hap_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.no2_daily_summary`
        UNION DISTINCT 
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.o3_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.voc_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.so2_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, date_local FROM  `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary`
        )
GROUP BY parameter_name
ORDER BY intervall
LIMIT 300
 
```

#### What are the 10 cities accross the countra that have on average the highest concentration of CO over the last given years?
 Answer: New Your has on average the highest concentration of CO within the time slot 2000-2022
 ```sql
DECLARE Start_Year INT64 DEFAULT 2000; -- Change the start year

SELECT 
    DISTINCT site_id,
    city_name,
    units_of_measure,
    AVG(arithmetic_mean) as mean
FROM (SELECT
          city_name,
          CONCAT(county_code,site_num) as site_id,
          arithmetic_mean,
          units_of_measure,
          EXTRACT(YEAR FROM date_local) as year
      FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary`
     )
WHERE year >= Start_Year
GROUP BY units_of_measure, site_id, city_name
ORDER BY mean DESC
LIMIT 10
 ```
 
#### What are the mean and standard deviation of pollutants concentration in the sites across the country whithin a given time period? 

```sql
DECLARE Start_Year INT64 DEFAULT 1990; -- Change the start year
DECLARE Last_Year INT64 DEFAULT 2012; -- Change the start year

SELECT 
    DISTINCT site_id,
    parameter_name,
    units_of_measure,
    AVG(arithmetic_mean) as mean,
    STDDEV(arithmetic_mean) as std

FROM (SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.hap_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.no2_daily_summary`
        UNION DISTINCT 
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.o3_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.voc_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.so2_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.pm10_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.pm25_frm_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.pm25_nonfrm_daily_summary`
        UNION DISTINCT
        SELECT parameter_name, CONCAT(county_code,site_num) as site_id, arithmetic_mean, units_of_measure, EXTRACT(YEAR FROM date_local) as year FROM  `bigquery-public-data.epa_historical_air_quality.pm25_speciation_daily_summary`
        )
WHERE year BETWEEN Start_Year AND Last_Year
GROUP BY site_id, units_of_measure, parameter_name
LIMIT 50
```
#### Final Query 
```sql
SELECT *  
FROM (SELECT
        CONCAT(state_code,'_',site_num) as site_id,
        city_name,
        arithmetic_mean as co_ppm,
        date_local,
        longitude,
        latitude
        FROM  `bigquery-public-data.epa_historical_air_quality.co_daily_summary`
    ) 
WHERE 
    site_id is NOT NULL AND
    co_ppm is NOT NULL AND
    date_local is NOT NULL AND 
    longitude is NOT NULL AND 
    latitude is NOT NULL 

```

#### Final Query for New York 
``` sql
WITH
    global_table AS (
    SELECT * FROM `bigquery-public-data.epa_historical_air_quality.co_daily_summary`
    UNION DISTINCT
    SELECT * FROM  `bigquery-public-data.epa_historical_air_quality.no2_daily_summary`
    UNION DISTINCT 
    SELECT * FROM  `bigquery-public-data.epa_historical_air_quality.o3_daily_summary`
    UNION DISTINCT
    SELECT * FROM  `bigquery-public-data.epa_historical_air_quality.so2_daily_summary`
    UNION DISTINCT
    SELECT * FROM  `bigquery-public-data.epa_historical_air_quality.temperature_daily_summary`
    ) 
SELECT   site_num,
         parameter_name,
         concentration,
         date_local,
         longitude,
         latitude
FROM (SELECT
        site_num,
        city_name,
        parameter_name,
        arithmetic_mean as concentration,
        date_local,
        longitude,
        latitude
        FROM global_table)  
WHERE 
    site_num is NOT NULL AND
    concentration is NOT NULL AND
    date_local is NOT NULL AND 
    longitude is NOT NULL AND 
    latitude is NOT NULL AND 
    city_name = "New York" 

ORDER BY date_local


```
 