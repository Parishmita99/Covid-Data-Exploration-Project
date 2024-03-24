USE PortfolioProject

SELECT 
* FROM CovidDeaths
ORDER BY 3,4

SELECT 
* FROM CovidVaccinations
ORDER BY 3,4

-- Selection from CovidDeaths table

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
where continent is not null
ORDER BY 1,2

-- Percentage of Total Deaths to the Total Cases

SELECT Location,date,
total_cases,total_deaths,
((CAST(total_deaths AS float))/(CAST(total_cases AS float)))*100 AS DeathPercentage
FROM CovidDeaths
where continent is not null
ORDER BY 1,2

--Shows the likelihood of dieing in United States in case of getting infected

SELECT Location,date,
total_cases,total_deaths,
((CAST(total_deaths AS float))/(CAST(total_cases AS float)))*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location like '%states' AND continent is not null
ORDER BY 1,2


-- Total cases vs Population
--Shows what percentage of Population got covid

SELECT Location,date,
total_cases,population,
((CAST(total_cases AS float))/(CAST(population AS float)))*100 AS DeathPerArea
FROM CovidDeaths
WHERE Location like '%states' and continent is not null
ORDER BY 1,2

-- Countries with highest infection rate compared to the population


SELECT Location,population,
MAX(total_cases) AS MaximumTotalCases,
((CAST(MAX(total_cases) AS float))/(CAST(population AS float)))*100 AS InfectedPercentage
FROM CovidDeaths
where continent is not null
GROUP BY location,population
ORDER BY InfectedPercentage DESC

-- Showing Countries with Highest Death Count per population

SELECT Location,
MAX(total_deaths) AS MaximumTotalDeaths
FROM CovidDeaths
where continent is not null
GROUP BY location
ORDER BY MaximumTotalDeaths DESC


--LET's break it down by continents

SELECT continent,MAX(total_deaths) AS MAXDeathContinentWise
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER by MAXDeathContinentWise DESC


SELECT location,MAX(total_deaths) AS MAXDeathContinentWise
FROM CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER by MAXDeathContinentWise DESC

-- GLOBAL NUMBERS

SELECT date,SUM(new_cases) AS TotalCases,SUM(cast(new_deaths as int)) AS TotalDeath,
SUM(cast(new_deaths as float))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is NULL AND new_cases!=0
GROUP BY date
ORDER by 1 

-- Looking at total population vs Vaccination

SELECT Dea.location,Dea.continent,Dea.date,Dea.population,Vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by Dea.Location)
FROM CovidDeaths AS Dea
JOIN CovidVaccinations AS Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date
WHERE Dea.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
