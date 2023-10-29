/*

Queries used for my first Covid Dashboard Tableau Project
I had to transfer the result of these queries into Excel file as tableau public doesn't support direct connection to MS SQL Server. 
Link: https://public.tableau.com/app/profile/christian.castillo3316/viz/CovidDashboardJan2020-April2021Data/Dashboard1

*/


-- 1. Global Numbers (Sheet 1)
SELECT 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths AS int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
ORDER by 1,2

-- 2.  Death Count per Continent (Sheet 2)

-- We take these out as they are not inluded in the above queries and want to stay consistent:
-- 'World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income'
SELECT 
	location, 
	SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%philippines%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.Percent Population Infected per Country (Sheet 3)
SELECT
	Location,
	Population, 
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4. Percent Population Infected (Sheet 4)
SELECT
	location, 
	Population,
	date, 
	MAX(total_cases) as HighestInfectionCount,  
	MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
GROUP BY Location, Population, date
GROUP BY PercentPopulationInfected DESC