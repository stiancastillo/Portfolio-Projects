--SELECT TOP 100 * FROM CovidDeaths
--ORDER BY 3,4

--SELECT TOP 100 * FROM CovidVaccinations
--ORDER BY 3,4

SELECT TOP 100 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM CovidDeaths
ORDER BY 1,2

--===================================================COVID DEATHS DB===================================================

-- (1) Looking at Total Cases vs Total Deaths
--Note: I had to convert the data from total cases and total deaths into float because it is initially nvarchar, which is invalid for divide operator.
--Shows the likelihood of dying if you contract covid in your country
SELECT TOP 500 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%philippines%'
ORDER BY 1,2

-- (2) Looking at the total cases vs the population
--Shows what percentage of population contracted COVID
SELECT TOP 500 
	Location, 
	date, 
	total_cases, 
	population, 
	(CONVERT(float, total_cases) / NULLIF(population, 0))*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%philippines%'
ORDER BY 1,2

-- (3) Looking at Countries with highest infection rate compared to population
SELECT 
	location, 
	population, 
	MAX(Convert(int, total_cases)) as HighestInfectionCount, 
	MAX((CONVERT(float, total_cases) / NULLIF(population, 0)))*100 AS InfectedRate
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY InfectedRate DESC


-- (4) Showing Countries with Highest Death Count per Population
SELECT 
	location, 
	population, 
	MAX(Convert(int, total_deaths)) as HighestDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null --null values has the actual continent data in the location field
GROUP BY Location, Population
ORDER BY HighestDeathCount DESC

-- (4) Showing Continent with Highest Death Count per Population
SELECT 
	continent, 
	MAX(Convert(int, total_deaths)) as HighestDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null --null values has the actual continent data in the location field
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- (5) Global numbers
--By date
SELECT
	date, 
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths as int)) AS total_deaths,
	SUM(CAST(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--===================================================COVID VACCINATIONS DB===================================================--

SELECT TOP 500
* FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date

-- (6) Looking at total population vs vaccinations
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount --For rolling counts of new vaccinations per loc and date
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- (7) Using CTE

WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, CummulativeVaccinationCount) --no. of columns in cte should be the same as the  no. in the query
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount --For rolling counts of new vaccinations per loc and date

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (CummulativeVaccinationCount/Population)*100
FROM PopvsVac


-- (8) Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated -- For the purpose of doing alterations in the code, this is optional.
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
CummulativeVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount --For rolling counts of new vaccinations per loc and date

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (CummulativeVaccinationCount/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccinationCount --For rolling counts of new vaccinations per loc and date

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated