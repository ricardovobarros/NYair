## ASK
What topic are you exploring?
  + Air quality in the USA
  
What is the problem you are trying to solve?
  + Many political efforts have been taken over the last two decades to improve the air quality across the country. Although the Environmental Protection Agency has been collecting air quality metrics in the previous three decades, there is no tool available that allows decision-makers in the Government to see air quality time-evolution at a glance. A new law created a fund to invest in air quality improvement and create population awareness about the importance of breathing better air.  
  
What metrics will you use to measure your data to achieve your objective?
  + Air pollutants concentration over time and air quality indicators. 
  
Who are the stakeholders?
  + USA Government 
  + Environmental Protection Agency
  + General populaiton
  
Who is your audience?
  + US Senate 
  
How can your insights help your client make decisions?
  + Seeing the evolution of air quality over time allows decision-makers to decide which states should be prioritized in the *fresh air* found sharing. In addition, the analysis results will point to red flags on regions that are stagnated or have worsened regarding air quality, which can be a foundation for further investigation. 

**Business Task:(question or a problems that data helps to answer)**: Which regions of the US need more attention regarding air quality? 

## Prepare
Where is your data located?
  + Environmental Protection Agency (EPA) website
  
How is the data organized?
+ The database contains one table for each pollutant and additional environmental measures (e.g., temperature). 
+ all tables contains essential information to identify the sample (e.g., datum, city name, lat, lon)

Are there issues with bias or credibility in this data? 
+ Some source of bias could be:
    + Measuring equipament failure. 
    + Measurament location concentration (e.g., all measurements made whithin nearby locations where trafic is intense)
    + Specifics of the location (e.g., equipment near a industry that produce a specific polutante)
+ EPA garanteed that the data colletion took into consideration the above mention possisble sources of bias. The measuraments were made on dispersed locations and far from industries that produce specific pollutantes. In addition, the equipaments are callibrated frequently followinf ISO recomendations. 
    
Does your data ROCCC?
+ R (Reliable): Yes - EPA has been keepping complete, unbiased and accurate air quality metrics over five year in the US.
+ O (Original): Yes - EPA is responsible for collecting and avaluating new data.
+ C (Comprehensive): Yes - The necessary pollutantes and air quality metrics are temporally organized and the attributes of the tables are well described.
+ C (Current): Yes - The database is fed daily.
+ C (Cited): Yes.

How are you addressing licensing, privacy, security, and accessibility?
+ EPA air quality measurements are public available on their [website](https://www.epa.gov/outdoor-air-quality-data/download-daily-data) 

How did you verify the data’s integrity? 
+ See documentatiaon of EPA's data integrity **[HERE](https://www.health.state.mn.us/communities/environment/mnelap/resources.html)**


## Process 

What tools are you choosing and why?
+ R shiny - tydo design and visualization open software 
+ Big Query - Open software and faster acess to data through R
+ SQL - Facilitate to data explorarion (see sql_code)

Have you ensured your data’s integrity?
- [YES](https://www.health.state.mn.us/communities/environment/mnelap/resources.html)

What steps have you taken to ensure that your data is clean?
+ Verify and remove possible typos.
+ Verify data consistency.
+ Remove saples with missing attributes. 
+ Remove duplicate data (SO2 and NO2 daily measuremets)

Have you documented your cleaning process so you can review and share those results?
+ Yes 

## Analyse

How should you organize your data to perform analysis on it?
+ Remove NUll values and use SQL to filter (NO2, CO, SO2 and O3) of NY from 1990 to 2019 and save as csv file. 
+ CSv is saved inside the app folder

Has your data been properly formatted?
+ Yes

What surprises and trends did you discover in the data?
+ Manhattan has higher concentration of pollutants on air. 
+ All the four analised pollutants have a decreasing trend over time.
+ O3 and SO2 concentrations have an oscillaiton pattern that depends on the time of the year.
+ CO, NO2, and SO2 concentration on air have strong positive correlation.
+ O3 is strongly positive correlated with temperature

How will these insights help answer your business questions?
+ They give a clear picture of the NY air quality and can help politicians to: 
    + Know the areas of NY that are more affected with pollution. 
    + Confirm that potilics that aimed the increase of air quality in NY has been effective, since the four analised pollutants have a decreasing trend over the years.
    + See the effectiveness of data collection over the years the trend graphs of each monitor. 
    
## Share
Were you able to answer the business question?
What story does your data tell?
How do your findings relate to your original question?
Who is your audience? 
What is the best way to communicate with them?
Can data visualization help you share your findings?

_Deliverable: 
-->>>> Supporting visualizations and key findings_

## ACT

What is your final conclusion based on your analysis?
How could your team and business apply your insights?
What next steps would you or your stakeholders take based on your findings?
Is there additional data you could use to expand on your findings?

_Deliverable: 
--->>>>> Your top high-level insights based on your analysis
--->>>>>> Based on what you discover, a list of additional deliverables you think would be helpful to include for further exploration_