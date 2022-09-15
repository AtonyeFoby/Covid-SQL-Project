SELECT *
FROM PortfolioProject.dbo.CovidDeaths$
order by 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2
 
-- looking at the total_cases vs total_deaths
-- shows the likelihood of dying if you contract covid in each country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- looking at the total cases vs the population
-- shows what percentage of population got covid 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


-- looking at countries with highest infection rate 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- looking at the countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC 

-- let's break things down by continent
-- showing the continents with the highest death counts
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
order by 1,2 


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
order by 1,2 

-- looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RunningTotal_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea 
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2, 3


-- USE CTE (common table expression)
 WITH PopsVsVac (Continent, Location, Date, Population, New_Vaccinations, RunningTotal_Vaccinations)
 AS 
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RunningTotal_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea 
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2, 3
)
SELECT *, (RunningTotal_Vaccinations/Population)*100 AS PercentageVaccinated
FROM PopsVsVac

-- TEMP TABLE 
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RunningTotal_Vaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RunningTotal_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea 
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2, 3

SELECT *, (RunningTotal_Vaccinations/Population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated

-- Create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
 SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RunningTotal_Vaccinations
FROM PortfolioProject.dbo.CovidDeaths$ dea 
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
    ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL 