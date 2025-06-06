/*

Queries to explore the COVIS 19 data and to be used for Tableau Poject

*/

-- Observing the data

SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations$
--WHERE continent IS NOT NULL
--ORDER BY 3,4


-- Selecting the Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID on Chile

SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location = 'Chile'
AND continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with COVID

SELECT location, date, total_cases, (total_deaths/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Chile'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
-- WHERE location = 'Chile'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Chile'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Breaking it down by Continent --

-- Showing Continents with the Highest Death count per Population

SELECT continent, SUM(CAST(new_deaths AS BIGINT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Chile'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location = 'Chile'
WHERE continent is not null 
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations (Using the JOIN operator for both tables.)
-- Showing Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using a CTE to perform Calculations on the previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentPeopleVaccinated
FROM PopvsVac


-- Using a Temp Table to perform Calculation on the previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated1 AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



--------------------------
-- SOME OTHER QUERIES --

----Double checking the data comparing directly with the "World" location

--SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_Cases)*100 AS DeathPercentage
--FROM PortfolioProject..CovidDeaths$
--WHERE location = 'World'
--ORDER BY 1,2

----Death count by continent 

--SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
----WHERE location = 'Chile'
--WHERE continent IS NULL
--AND location NOT IN ('World', 'European Union (27)', 'International', 'High-income countries', 'Upper-middle-income countries', 'Lower-middle-income countries', 'Low-income countries')
--GROUP BY location
--ORDER BY TotalDeathCount DESC



---- Showing Countries with Highest Death Count per Population (taking into account the data type)

--SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
--FROM PortfolioProject..CovidDeaths$
--WHERE continent IS NOT NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC


---- Looking at countries with Highest Infection Rate compared to Population

--SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
--FROM PortfolioProject..CovidDeaths$
---- WHERE location = 'Chile'
--GROUP BY location, population, date
--ORDER BY PercentPopulationInfected DESC

---- 

--SELECT dea.continent, dea.location, dea.date, dea.population
----, MAX(CONVERT(BIGINT,vac.new_vaccinations))
--, MAX(vac.new_vaccinations)
--AS RollingPeopleVaccinated
--FROM PortfolioProject..CovidDeaths$ dea
--JOIN PortfolioProject..CovidVaccinations$ vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--GROUP BY dea.continent, dea.location, dea.date, dea.population
--ORDER BY 2,3

