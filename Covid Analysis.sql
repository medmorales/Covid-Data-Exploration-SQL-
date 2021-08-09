-- view all columns 
SELECT *
FROM covid.coviddeathss;

-- Slecting columns that we will be using
SELECT date, location, population, total_cases, new_cases, total_deaths
FROM covid.coviddeathss
ORDER BY 2,3;

-- total_cases vs total_deaths
-- calculating death percentage, to see likelihood of dying if contracting the covid virus
SELECT date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid.coviddeathss
WHERE location like '%States'
order by 2,1;
-- We now have a new column labeled 'death_percentage' which shows the percentage of people that are dying if they test postive for the covid vaccine. If we take a closer look at the death 
-- percentage here in the U.S. We can see that at the beginning of the pandemic, over 6% of people with covid were dying. Since then, possibly due to hospitals getting better at treating 
-- covid patients and the vaccine, the death percentage has been gradually decreasing and is now under 1.75%. 

-- total_cases vs population
-- running percentage of population that has had a positive test
SELECT date, location, total_cases, population, (total_cases/population)*100 AS case_percentage
FROM covid.coviddeathss
WHERE location like '%States'
order by 2,4;
-- Here, we are calculating the positive test rate for each country around the world. This is a running percentage that shows the percentage of people that have had covid. In the United States, 
-- we can see that over 10% of the population has had the corona virus. From the percentages, we can see a more rapid increase in covid cases during and after the holiday season. 

-- Which countries have the highest/lowest infection rates relative to thier population size?
SELECT location, date, population, MAX(total_cases) AS highest_case_count, MAX((total_cases/population))*100 AS percent_infected
FROM covid.coviddeathss
GROUP BY location, population, date
ORDER BY percent_infected Desc;
-- ORDER BY case_percentage;
-- The results from this query show that Andorra, an independent principality between France and Spain has the highest case percentage at over 19% of the population having had the covid virus 
-- far.  When looking in Ascending order, we can see that many of the countries/territories with the lowest case percentages are islands located West of Australia in the Pacific Ocean. this is 
-- most likely due them being in more isolated and remote areas. 

-- Countries with highest death counts relative to their population
SELECT location, MAX(total_deaths) AS highest_deaths, population, MAX((total_deaths/population))*100 AS death_percentage
FROM covid.coviddeathss
GROUP BY location, population
ORDER BY death_percentage Desc;
-- ORDER BY death_percentage Desc;
-- When comparing the number of deaths and the population of each country, we can see that Peru by far has the highest number of deaths due to covid relative to their popualtion size. 
-- Almost 0.6% of the population in Peru has died from the coronavirus vaccine and is possibly due to Peru's healthcare system lacking sufficient funding and only having 1,600 
-- intensive care unit beds. 

-- Countries with highest death counts
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM covid.coviddeathss
WHERE continent <> ''
GROUP BY location
ORDER BY total_deaths Desc;
-- Taking a look at the total death counts in each country, we can see that the United States leads in total deaths due to the corona virus, followed, by Brazil, India, and Mexico. 


-- BY CONTINENT
SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM covid.coviddeathss
WHERE continent = '' and location not in ('World','International','European Union')
GROUP BY location
ORDER BY total_deaths Desc;
-- When looking the total number of deaths due to covid by continet, Europe leads with over 1 millions deaths. This is probably due to European cities being more densily populated 
-- than other areas around the world


-- Global Daily death percentage
SELECT date, SUM(new_cases) AS new_cases, SUM(new_deaths) AS new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid.coviddeathss
WHERE continent <> ''
GROUP BY date
ORDER BY date;
-- Here we create a daily death percentage by dividing the number of new deaths by the number of new cases world wide. The daily death percentage from new cases is currently under 2%.


SELECT * 
FROM covid.coviddeathss d
JOIN covid.covidvaccinations v
	ON d.location = v.location AND d.date = v.date;
-- Here we suse the default inner join to cobine the covid death and vaccination datasets. 

-- total population vs vaccinations 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) 
	OVER (PARTITION BY d.location ORDER BY d.location, d.date)
FROM covid.coviddeath d
	JOIN covid.covidvaccinations v
		ON d.location = v.location 
        AND d.date = v.date
WHERE d.continent <> ''
ORDER BY 2,3;

-- CTE 
WITH RECURSIVE popvsvac
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) 
	OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rolling_vaccinations
FROM covid.coviddeath d
	JOIN covid.covidvaccinations v
		ON d.location = v.location 
        AND d.date = v.date
WHERE d.continent <> ''
-- ORDER BY 2,3
)

-- FOR TABLEAU
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS death_percentage
FROM covid.coviddeathss
WHERE continent <> ''
-- GROUP BY date
ORDER BY 1,2;