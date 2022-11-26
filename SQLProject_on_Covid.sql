SELECT *
FROM COVIDDEATHS
ORDER BY 3, 4;

SELECT *
FROM COVIDVACINATION
ORDER BY 3, 4;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM COVIDDEATHS
ORDER BY 1, 2;


--Looking at totAl cases vs Total death

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercent
FROM COVIDDEATHS
WHERE location LIKE '%States'
AND continent IS NOT NULL
ORDER BY 1, 2;




--TOTAL CASE VS Population
--shows percentage of population got covid


SELECT location,date,population,total_cases,(total_cases/population)*100 AS Percent_Population_infected
FROM COVIDDEATHS
WHERE location LIKE '%States%'
ORDER BY 1, 2;


SELECT location,date,population,total_cases,
FROM COVIDDEATHS
WHERE location LIKE '%States%'
ORDER BY 1, 2;



--Looking at countries with highest infection rate compard with population


SELECT location,population,MAX(total_cases) AS Highest_Infection_Count,
MAX((total_cases/population))*100 AS  Percent_Population_infected
FROM COVIDDEATHS
--WHERE location LIKE '%States%'
GROUP BY location,population
ORDER BY Percent_Population_infected DESC;


--How Many People Died. Show Countries with the Highest death count Population

SELECT location,MAX(CAST(total_deaths AS INT)) AS Totaldeath_Count
FROM COVIDDEATHS
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Totaldeath_Count DESC;


--Highest Death Count By Continent

SELECT location,MAX(CAST(total_deaths AS INT)) AS Totaldeath_Count
FROM COVIDDEATHS
--WHERE location LIKE '%States%'
WHERE continent IS NULL
GROUP BY location
ORDER BY Totaldeath_Count DESC;

SELECT continent,MAX(CAST(total_deaths AS INT)) AS Totaldeath_Count
FROM COVIDDEATHS
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Totaldeath_Count DESC;



--GLOBAL NUMBER

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Death,
(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage 
FROM COVIDDEATHS
--WHERE location LIKE '%States'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2;



--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location)
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vac,
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--Use CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccination, Rolling_People_Vac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vac
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vac/Population)*100
FROM PopvsVac;




--Temt Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vac numeric
)


INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vac
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *, (Rolling_People_Vac/Population)*100
FROM #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA LATER FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER
(PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS Rolling_People_Vac
FROM PortfolioProject..COVIDDEATHS dea
JOIN PortfolioProject..COVIDVACINATION vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated