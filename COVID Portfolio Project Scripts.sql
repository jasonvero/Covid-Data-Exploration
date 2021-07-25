/*
Project 1: Data exploration of Covid deaths

*/

SELECT *
FROM Portfolio_Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


SELECT *
FROM Portfolio_Project.dbo.CovidVaccinations
ORDER BY 3, 4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project.dbo.CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths/total_cases, 4) * 100 AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2



-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, ROUND(total_cases/population, 4) * 100 AS PercentPopulationInfected
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1, 2


-- Looking at countries that have the highest infection rates in comparsion to the population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND(total_cases/population, 4)) * 100 AS PercentPopulationInfected
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing the countries with the Highest Death Count per Population
-- Convert total_deaths to an integer so it's read as a numeric
-- Remove where continent is NOT NULL so that location will only return countries
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking things down by Continent
-- Remove where continent IS NULL so that location will contain the continents
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC


-- Showing continents with highest death count
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC


/* 
Global Numbers
*/
	-- Daily cases, deaths and death percentage 
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100) AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- Total cases, deaths and death percentage
SELECT SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100) AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM Portfolio_Project.dbo.CovidDeaths AS dea
JOIN Portfolio_Project.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

	-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM Portfolio_Project.dbo.CovidDeaths AS dea
JOIN Portfolio_Project.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / population) * 100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac

 -- USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM Portfolio_Project.dbo.CovidDeaths AS dea
JOIN Portfolio_Project.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated / population) * 100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

	-- 1) PercentPopulationVacinnated
CREATE VIEW PercentPopulationVacinnated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
FROM Portfolio_Project.dbo.CovidDeaths AS dea
JOIN Portfolio_Project.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVacinnated

	-- 2) Daily cases, deaths and death percentage 
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalNewDeaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100) AS DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2


/*
External practice queries outside of video tutorial
*/


-- Grouping ROUNDED field
SELECT new_deaths_per_million, ROUND(new_deaths_per_million, 1) AS RoundedDeathsPerMillion, COUNT(new_deaths_per_million) AS CountOfDeathsPerMillion
FROM Portfolio_Project.dbo.CovidDeaths
GROUP BY new_deaths_per_million


-- INNER Joining between CovidDeath and CovidVaccinations data set
SELECT *
FROM Portfolio_Project.dbo.CovidDeaths AS dea
JOIN Portfolio_Project.dbo.CovidVaccinations AS vac
	ON dea.iso_code = vac.iso_code
WHERE dea.date = vac.date


--- ISNULL Function

SELECT new_cases_smoothed, ISNULL(new_cases_smoothed, '666')
FROM Portfolio_Project.dbo.CovidDeaths
where new_cases_smoothed = '666'

-- Temp Table Only United states dataset

DROP TABLE IF EXISTS #temp_CovidDeathsSubset
CREATE TABLE #temp_CovidDeathsSubset(
iso_code varchar(50),
continent varchar(50),
location varchar(100),
date datetime,
population float,
total_cases float,
new_cases float,
total_deaths float,
new_deaths float
)

INSERT INTO #temp_CovidDeathsSubset
SELECT iso_code, continent, location, date, population, total_cases, new_cases, total_deaths, new_deaths
FROM Portfolio_Project.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

SELECT * 
FROM #temp_CovidDeathsSubset