--COVID data exploration with SQL
--includes Aggregate functions, windows functions, converting data types
--View creation, Joins, CTEs, Temp tables

SELECT * 
FROM Project1..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT * 
--FROM Project1..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Project1..CovidDeaths
ORDER BY 1,2

--Total cases vs Total Deaths
--chances of dying if you contract covid in a certain location

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Total cases vs population
--percentage of population that has gotten covid

SELECT location, date, population, total_cases,  (total_cases/population)*100 as PopulationPercentageInfected
FROM Project1..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as PopulationPercentageInfected
FROM Project1..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project1..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

--by continent with highest death count

--SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM Project1..CovidDeaths
--WHERE continent is null
--GROUP BY location
--ORDER BY 2 DESC

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Project1..CovidDeaths
WHERE continent is not null
GROUP BY continent		
ORDER BY 2 DESC

--Global numbers

SELECT date, SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Project1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--total total

SELECT SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totalDeaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Project1..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null

--total population vs vaccinations
--percentage of population with at least one covid vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPplVaccinated, 
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

--USE CTE to perform calc on partition in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPplVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPplVaccinated 
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPplVaccinated/population)*100
FROM PopvsVac


---TEMP TABLE
--DROP TABLE IF EXISTS #PercentPopulationVaccinated

IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
   DROP TABLE #PercentPopulationVaccinated
GO
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPplVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPplVaccinated 
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPplVaccinated/population)*100
FROM #PercentPopulationVaccinated


--creating data to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPplVaccinated 
FROM Project1..CovidDeaths dea
JOIN Project1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVaccinated