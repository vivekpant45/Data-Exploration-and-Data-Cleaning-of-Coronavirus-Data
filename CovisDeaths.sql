select *
from PortfolioProject.dbo.CovidDeaths
order by 3,4



--select *
--from PortfolioProject.dbo.CovidVaccination
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract virus
select Location,date,total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPecentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%' and continent is not null
order by 1,2



-- Total Cases vs Population
-- Percentage of Population Infected
select Location, date, total_cases, (cast(total_cases as float)/cast(population as float))*100 AS PercentageInfected
from PortfolioProject.dbo.CovidDeaths
where location like '%states%' and continent is not null
order by 1,2


--Countries with highest infection rate compared to population
select Location, population, Max(total_cases) as MaximumCases, Max((cast(total_cases as float)/cast(population as float))*100) AS HighestInfectionCount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location, population
order by HighestInfectionCount desc


--Countries with highest death count per population
select Location, Max(cast(total_deaths as int)) as MaximumDeaths
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by MaximumDeaths desc



--Showing continents with highest death count per population
--Break things down by continent
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc



--Global Numbers
select date, sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int))/sum(nullif(new_cases,0)))*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where new_cases is NOT NULL
Group by date
order by 1,2


--Looking Total Population Vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as TotalVaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- from cte
with PopvsVac(continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as TotalVaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (TotalVaccinations/Population)*100
from PopvsVac



--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
TotalVaccinations numeric
)



Insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as TotalVaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


select *, (TotalVaccinations/Population)*100
from #percentPopulationVaccinated




-- Creating view to store for later data visualisation
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.Date) as TotalVaccinations
from PortfolioProject.dbo.CovidDeaths as dea
join PortfolioProject.dbo.CovidVaccination as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
