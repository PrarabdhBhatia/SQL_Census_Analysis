SELECT * FROM CENSUSPROJECT.dbo.Data1
SELECT * FROM CENSUSPROJECT.dbo.Data2

--Number of rows in the datasets

SELECT COUNT(*) FROM CENSUSPROJECT.dbo.Data1
SELECT COUNT(*) FROM CENSUSPROJECT.dbo.Data2

--Retrieving data of only Jharkhand and Bihar 

SELECT * FROM CENSUSPROJECT.dbo.Data1
WHERE State IN ('Jharkhand', 'Bihar')

--Calculating population of India

SELECT SUM(Population) AS PopulationOfIndia FROM CENSUSPROJECT..Data2

--Average Growth Percentage of India 

SELECT AVG(Growth)*100 AvgGrowthPercentage FROM CENSUSPROJECT.dbo.Data1

--Average growth by state 

SELECT State, AVG(Growth)*100 AvgGrowthPercentage FROM CENSUSPROJECT.dbo.Data1 GROUP BY State

--Average sex ratio by State in descending order

SELECT State, ROUND(AVG(Sex_Ratio),0) AvgSexRatio FROM CENSUSPROJECT.dbo.Data1 
GROUP BY State ORDER BY AvgSexRatio desc

--Average literacy rate by state in descending order

SELECT State, ROUND(AVG(Literacy),2) AvgLitRate FROM CENSUSPROJECT.dbo.Data1 
GROUP BY State ORDER BY AvgLitRate desc

--States with literacy rate more than 80%

SELECT State, ROUND(AVG(Literacy),2) AvgLitRate FROM CENSUSPROJECT.dbo.Data1 
GROUP BY State HAVING ROUND(AVG(Literacy),2)>80 ORDER BY AvgLitRate desc

-- Top 3 states with highest growth percentage

SELECT TOP 3 State, AVG(Growth)*100 AvgGrowthPercentage FROM CENSUSPROJECT.dbo.Data1 GROUP BY State ORDER BY AvgGrowthPercentage desc

--States with lowest sex ratio 

SELECT TOP 3 State, AVG(Sex_Ratio) AvgSexRatio FROM CENSUSPROJECT.dbo.Data1 GROUP BY State ORDER BY AvgSexRatio asc

--Top and bottom 3 states in literacy rate

DROP TABLE IF EXISTS #TopStates
CREATE TABLE #TopStates
( State nvarchar(255),
 
TopStates float)

INSERT INTO #TopStates
 SELECT TOP 3 State, ROUND(AVG(Literacy),2) AvgLitRate FROM CENSUSPROJECT.dbo.Data1 
 GROUP BY State  ORDER BY AvgLitRate desc
 
SELECT * FROM #TopStates

DROP TABLE IF EXISTS #BottomStates
CREATE TABLE #BottomStates
( State nvarchar(255),
 
BottomStates float)

INSERT INTO #BottomStates
 SELECT TOP 3 State, ROUND(AVG(Literacy),2) AvgLitRate FROM CENSUSPROJECT.dbo.Data1 
 GROUP BY State  ORDER BY AvgLitRate asc
 
SELECT * FROM #BottomStates

-- State wise population density 

SELECT State, SUM(Population) Total_Population, SUM(Area_km2) Total_Area, ROUND(SUM(Population)/(SUM(Area_km2)),0) Population_Density 
FROM CENSUSPROJECT..Data2 
GROUP BY State

--Combined table using UNION operator 

SELECT * FROM 
(SELECT * FROM #TopStates) a

UNION

SELECT * FROM
(SELECT * FROM #BottomStates) b;

--Joining both tables 

SELECT a.district , a.state, a.sex_ratio/1000, b.population FROM CENSUSPROJECT..Data1 a
INNER JOIN CENSUSPROJECT..Data2 b ON a.district=b.district

-- sex_ratio= (No. of females/ No. of Males)
-- Population= (No. of females) + (No. of Males)
-- Population- (No. of Males)= (No. of females) 
-- Population- (No. of Males)= sex_ratio*(No. of Males)
-- Population= (No. of Males)*(sex_ratio + 1)
-- (No. of Males)= Population/(sex_ratio + 1)
-- (No. of females) = Population- Population/(sex_ratio + 1)
-- (No. of females) = (Population*sex_ratio)/(sex_ratio + 1)

--Number of Males and Females district wise

SELECT district, state, ROUND(population/(sex_ratio+1),0) Males,ROUND((Population*sex_ratio)/(sex_ratio + 1),0) Females
FROM
(SELECT a.district , a.state, a.sex_ratio/1000 sex_ratio, b.population FROM CENSUSPROJECT..Data1 a
INNER JOIN CENSUSPROJECT..Data2 b ON a.district=b.district) c

--Number of Males and Females state wise

SELECT d.State, SUM(d.Males) Total_Males, SUM(d.Females) Total_Females FROM
(SELECT district, state, ROUND(population/(sex_ratio+1),0) Males,ROUND((Population*sex_ratio)/(sex_ratio + 1),0) Females
FROM
(SELECT a.district , a.state, a.sex_ratio/1000 sex_ratio, b.population FROM CENSUSPROJECT..Data1 a
INNER JOIN CENSUSPROJECT..Data2 b ON a.district=b.district) c) d
GROUP BY d.State

-- Population in previous Census [District wise]

--previous_population + Growth(previous_population)= Population
--previous_population = Population/(1+Growth)

SELECT d.District, d.State, ROUND(Population/(1+Growth),0) Previous_population, d.Growth*100 Growth_rate, Population Current_population
FROM
(SELECT a.District , a.State, a.Growth, b.Population FROM CENSUSPROJECT..Data1 a
INNER JOIN CENSUSPROJECT..Data2 b ON a.district=b.district) d

-- Population in previous Census [State wise]

SELECT e.State, SUM(e.Previous_population) Previous_population, SUM(e.Current_population) Current_population 
FROM
(SELECT d.District, d.State, ROUND(Population/(1+Growth),0) Previous_population, d.Growth*100 Growth_rate, Population Current_population
FROM
(SELECT a.District , a.State, a.Growth, b.Population FROM CENSUSPROJECT..Data1 a
INNER JOIN CENSUSPROJECT..Data2 b ON a.district=b.district) d) e
GROUP BY e.state

-- Total Population of India in previous census

SELECT SUM(m.Previous_population) Previous_total_pop, SUM(m.Current_population) Current_total_pop
FROM
(SELECT e.State, SUM(e.Previous_population) Previous_population, SUM(e.Current_population) Current_population 
FROM
(SELECT d.District, d.State, ROUND(Population/(1+Growth),0) Previous_population, d.Growth*100 Growth_rate, Population Current_population
FROM
(SELECT a.District , a.State, a.Growth, b.Population FROM CENSUSPROJECT..Data1 a
INNER JOIN CENSUSPROJECT..Data2 b ON a.district=b.district) d) e
GROUP BY e.state) m

-- Top 3 districts in each state with hhighest literacy rate 

SELECT a.* FROM
(SELECT District, State, Literacy, rank() over(PARTITION BY State ORDER BY Literacy desc) RNK FROM CENSUSPROJECT..Data1) a
WHERE a.RNK IN (1,2,3)

