SELECT *
FROM portfolioproject..CovidDeath
ORDER BY 3,4

--SELECT *
--FROM CovidVaccination
--ORDER BY 3,4

--SELECT location, Date, Total_Cases, New_cases, Total_Deaths, Population
--FROM Portfolioproject..CovidDeath
--ORDER BY 1,2

-- Looking at Total cases vs Total Death
--SELECT location, Date, Total_Cases, Total_Deaths,  (cast(total_deaths as float)/cast(total_cases as float))*100 as Deathrate
--FROM portfolioproject..CovidDeath
--WHERE Location= 'Nigeria'
--ORDER BY 1,2

-- Looking at Total cases vs Population
--Shows what % of the population has coovid
--SELECT location, Date, Total_Cases, Population, (cast(total_cases as float)/cast(population as float))*100 as Caserate
--FROM portfolioproject..CovidDeath
----WHERE Location= 'Nigeria'
--ORDER BY 1,2

---- Looking at Countries with Highest infection Rate compared to population
--SELECT location, Population, MAX(total_cases) as highestInfectionCount, MAX(cast(total_cases as float)/cast(population as float))*100 as Caserate
--FROM portfolioproject..CovidDeath
--GROUP BY Location, Population
--ORDER BY Caserate desc


----Showing Countries withe highest death count par population
--SELECT location, Population, MAX(cast(total_Deaths as int)) TotalDeathCount
--FROM portfolioproject..CovidDeath
--Where continent is NULL 
--GROUP BY Location, Population
--ORDER BY Totaldeathcount desc

--SELECT * FROM portfolioproject..CovidDeath where continent is not NULL and continent ='EUROPE'
---- Showing Continent withe highest death count par population
--SELECT Continent,location, SUM(Population), MAX(cast(total_Deaths as int)) TotalDeathCount
--FROM portfolioproject..CovidDeath
--Where continent is not NULL and continent ='EUROPE'
--GROUP BY Continent,location, Population
--ORDER BY Totaldeathcount desc

-- Showing Continent wit the highest death count par population
--SELECT Continent, MAX(cast(total_Deaths as int)) TotalDeathCount
--FROM portfolioproject..CovidDeath
--Where continent is not NULL 
--GROUP BY Continent
--ORDER BY Totaldeathcount desc


--GLOBAL NUMBERS
SELECT Date, SUM(CAST(new_cases AS int)), SUM(New_deaths)
FROM PortfolioProject..CovidDeath
Where continent is not null
GROUP BY Date
ORDER BY 2

--SELECT CAST(new_cases as int)
--FROM PortfolioProject..CovidDeath
--ORDER BY 1


-- Looking at total Population vs vaccination

SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS Rollingcount
FROM Portfolioproject..coviddeath dea
Join PortfolioProject..CovidVaccination vac
ON dea.location =vac.location
and dea.date=vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2,3


--USE CTE
WITH popvsvac(continent, location, date, Population, new_vaccinations, Rollingcount)
as
(
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS Rollingcount
FROM Portfolioproject..coviddeath dea
Join PortfolioProject..CovidVaccination vac
ON dea.location =vac.location
and dea.date=vac.date
Where dea.continent is not null and vac.new_vaccinations is not null
)
select *, (Rollingcount/population) as vacrate
from popvsvac


--TEMP TABLE
DROP TABLE IF EXISTS #percentPopulationVaccinated
Create table #percentPopulationVaccinated
(continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_vaccinated numeric,
RollingCount numeric
)

Insert into #percentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS Rollingcount
FROM Portfolioproject..coviddeath dea
Join PortfolioProject..CovidVaccination vac
ON dea.location =vac.location
and dea.date=vac.date
Where dea.continent is not null and vac.new_vaccinations is not null

select *, (Rollingcount/population)*100 as vacrate
from #percentPopulationVaccinated



--Creatibg Views
Create view percentPopulationVaccination as
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS Rollingcount
FROM Portfolioproject..coviddeath dea
Join PortfolioProject..CovidVaccination vac
ON dea.location =vac.location
and dea.date=vac.date
Where dea.continent is not null and vac.new_vaccinations is not null