SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deats
-- Likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%akista%'
ORDER BY 1,2


-- Total cases vs population
-- Percentage of population affected by COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS AffectedPopulation
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Countries with highest infection rates compared to population

SELECT location, population, MAX(total_cases) AS TotalCases, MAX((total_cases/population))*100 AS AffectedPopulation
FROM CovidDeaths
GROUP BY location, population
ORDER BY AffectedPopulation DESC


-- Countries with highest death count compared to population

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC


-- Continets with highest death count

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeaths DESC


-- Continets with highest death count As well

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Cases & Total Deaths
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Join the tables of deaths and vaccines
SELECT *
FROM CovidDeaths de
JOIN CovidVaccinations va
	ON de.location = va.location
	AND de.date = va.date
ORDER BY 3,4


-- Total Population vs Vaccination

SELECT de.continent, de.location, de.date, population, va.new_vaccinations, SUM(CONVERT(int, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPeopleVaccinated
FROM CovidDeaths de
JOIN CovidVaccinations va
	ON de.location = va.location
	AND de.date = va.date
WHERE de.continent IS NOT NULL
ORDER BY 2,3


-- Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(SELECT de.continent, de.location, de.date, population, va.new_vaccinations, SUM(CONVERT(int, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPeopleVaccinated
FROM CovidDeaths de
JOIN CovidVaccinations va
	ON de.location = va.location
	AND de.date = va.date
WHERE de.continent IS NOT NULL)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM PopvsVac


-- Create View

CREATE VIEW PercentagePopulationVaccinated
AS
SELECT de.continent, de.location, de.date, population, va.new_vaccinations, SUM(CONVERT(int, va.new_vaccinations)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS RollingPeopleVaccinated
FROM CovidDeaths de
JOIN CovidVaccinations va
	ON de.location = va.location
	AND de.date = va.date
WHERE de.continent IS NOT NULL

SELECT *
FROM PercentagePopulationVaccinated