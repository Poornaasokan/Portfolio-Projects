select * from CovidDeaths
Where continent is not null 
order by 3, 4

--Select * 
--from CovidVaccinations
--Where continent is not null 
--order by 1,2

Select location,date,total_cases,new_cases,total_deaths,population 
from CovidDeaths 
Where continent is not null 
order by 1,2

--Total Cases Vs Total Death

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from CovidDeaths
Where location = 'Australia' and
continent is not null 
Order by 1,2

--Total Cases Vs Population
--Pergentage of ppoluation got covid
Select Location, date,  population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as PertcentageOfCovid
from CovidDeaths
Where location = 'Australia'
and  continent is not null 
Order by 1,2


--Country with highest infection Rate Compared to population

Select Location, population, MAX(total_cases) as HighestInfectedCount, MAX((total_cases/ population))* 100 as PertcentageOfInfected
from CovidDeaths
Where continent is not null 
Group by Location, population
Order by PertcentageOfInfected desc


--Countries with highest Death counts Per Poulations
Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null 
Group by Location
Order by TotalDeathCount desc

--Countries with highest Death counts 

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null 
Group by continent
Order by TotalDeathCount desc


--Global Numbers

Select sum(new_cases) as TotalCases, 
sum(Cast(new_deaths as int)) as TotalDeath, 
sum(Cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from CovidDeaths 
Where continent is not null
Order by 1,2

Select * from 
[Portfolio Project].dbo.CovidVaccinations

Select * from 
[Portfolio Project].dbo.CovidDeaths as dea
JOIN 
[Portfolio Project].dbo.CovidVaccinations as vac
ON
dea.location = vac.location 
and
dea.date=vac.date 

--Total Polulation Vs Vaccination
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
from 
[Portfolio Project].dbo.CovidDeaths as dea
JOIN 
[Portfolio Project].dbo.CovidVaccinations as vac
ON
dea.location = vac.location 
and
dea.date=vac.date 
Where dea.continent is not null
Order by 1,2,3


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER
(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from 
[Portfolio Project].dbo.CovidDeaths as dea
JOIN 
[Portfolio Project].dbo.CovidVaccinations as vac
ON
dea.location = vac.location 
and
dea.date=vac.date 
Where dea.continent is not null
Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from 
[Portfolio Project].dbo.CovidDeaths as dea
JOIN 
[Portfolio Project].dbo.CovidVaccinations as vac
ON
dea.location = vac.location 
and
dea.date=vac.date 
Where dea.continent is not null

)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from 
[Portfolio Project].dbo.CovidDeaths as dea
JOIN 
[Portfolio Project].dbo.CovidVaccinations as vac
ON
dea.location = vac.location 
and
dea.date=vac.date 
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for  visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from 
[Portfolio Project].dbo.CovidDeaths as dea
JOIN 
[Portfolio Project].dbo.CovidVaccinations as vac
ON
dea.location = vac.location 
and
dea.date=vac.date 
Where dea.continent is not null