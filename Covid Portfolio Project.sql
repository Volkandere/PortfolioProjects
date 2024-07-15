SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Changing the data type of the column
--ALTER TABLE PortfolioProject..CovidDeaths
--ALTER COLUMN total_cases int;

--ALTER TABLE PortfolioProject..CovidVaccinations
--ALTER COLUMN new_vaccinations bigint;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the death percentage if you get caught to covid for every countries

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Turkey%'
ORDER BY 1,2

--Looking at Total Cases vs Population 
--Show what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Turkey%'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPercentage desc


-- *MAX(cast(total_deaths as int)) data type change*


--Countries with highest death count per population 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null -- excludes the continents and world 
GROUP BY location
ORDER BY TotalDeathCount desc

-- For the continents

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null and location not like '%income%'
GROUP BY location
ORDER BY TotalDeathCount desc	

SELECT * 
FROM PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths,
SUM (cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total population vs vaccinations

--You can't use a column that you just created, so we are using CTEs or Temps to solve the issue
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsThroughTime,
(TotalVaccinationsThroughTime/dea.population)*100 as VaccinatedPercentage
FROM PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinationsThroughTime)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsThroughTime
FROM PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (TotalVaccinationsThroughTime / population)*100 
FROM PopvsVac
ORDER BY 2,3

-- Using Temp Table

DROP TABLE IF EXISTS #PopulationVaccinated
CREATE TABLE #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinationsThroughTime numeric
)

INSERT INTO	#PopulationVaccinated	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsThroughTime
FROM PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (TotalVaccinationsThroughTime / population)*100 
FROM #PopulationVaccinated
ORDER BY 2,3

--Create view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsThroughTime
FROM PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated




	
