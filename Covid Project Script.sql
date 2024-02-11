select * from PortfolioProject.dbo.CovidVaccinations
where location is not null
order by 3,4

select * from PortfolioProject.dbo.CovidDeaths$
order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

---
---looking at total cases vs total death
--shows likelihood of dying if you contract  covid in ur country
select location,date,total_cases, total_deaths,population,(total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location like  '%states%'
and continent is not null
order by 1,2

---looking at total cases vs population
--shows what percentage of poulation got covid
select location,date,total_cases, total_deaths,population,(total_cases/population)*100 AS PercentPoplulationInfected
from PortfolioProject.dbo.CovidDeaths
where location like  '%states%'
order by 1,2



--looking at countries with highest infection rate compared to population

select location,Population,MAX(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 AS PercentPoplulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like  '%states%'
group by location,Population
order by PercentPoplulationInfected DESC




--showing countries with highes Death Count Per Population

select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject.dbo.CovidDeaths
--where location like  '%states%'
where continent is not null
group by location
order by TotalDeathCount DESC



--lets break things down by continent
--showing continents with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject.dbo.CovidDeaths
--where location like  '%states%'
where continent is not null
group by continent
order by TotalDeathCount DESC

--Global Numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as ttoal_deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like  '%states%'
where continent is not null
order by 1,2


--looking at total populations vs Vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100

from PortfolioProject.dbo.CovidDeaths as dea
join  PortfolioProject.dbo.CovidVaccinations as vac
	on dea.location = vac.location
		and
		dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE
with PopVsVac(Continent,Location,Date,Population,New_Vaccinations ,RollingPeopleVaccinated)
as 
(
--looking at total populations vs Vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100

from PortfolioProject.dbo.CovidDeaths  dea
join  PortfolioProject.dbo.CovidVaccinations  vac
	on dea.location = vac.location
	and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/Population)*100 from PopVsVac

--Temp Table
Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
--looking at total populations vs Vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100

from PortfolioProject.dbo.CovidDeaths  dea
join  PortfolioProject.dbo.CovidVaccinations  vac
	on dea.location = vac.location
	and
	dea.date = vac.date
-- where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

--creating view to store data for later visualizations
Create View  PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by  dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100

from PortfolioProject.dbo.CovidDeaths  dea
join  PortfolioProject.dbo.CovidVaccinations  vac
	on dea.location = vac.location
	and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated
