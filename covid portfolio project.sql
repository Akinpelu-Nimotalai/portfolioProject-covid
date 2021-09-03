--/*
--covid 19 Data Exploration
--*/

8elect *
from [portfolio project]..covidDeaths
where continent is not null
order by 3,4


--select *
--from [portfolio project]..covidvacinations
--order by 3,4

--total cases vs total death

 select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..covidDeaths
order by 1,2

--To get total cases vs total death

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from [portfolio project]..covidDeaths
where location like '%nigeria%'
order by 1,2 

--looking at total cases vs population

 select location, date, population, total_cases, (total_cases/population)*100 as percentPopulationInfected
from [portfolio project]..covidDeaths
where location like '%nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to population

  select location, population,MAX(total_cases), max((total_cases/population))*100 as percentPopulationInfected
from [portfolio project]..covidDeaths
group by location, population
order by percentPopulationInfected desc


--shwowing countries with highest death count per population

select location,MAX(cast (total_deaths as int)) as TotalDeathCount
from [portfolio project]..covidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--by continent

select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from [portfolio project]..covidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

 select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int )) as total_deaths, sum(cast (new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from [portfolio project]..covidDeaths
where continent is null
order by 1,2

select *
from [portfolio project]..covidvacinations

--joining the table coviddeath with covidvacination

select *
from [portfolio project]..covidDeaths dea
join [portfolio project]..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date

--to get total population vs vaccination

--USE CTE

with PopvsVac (continent, location, date, population, new_vaccination, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio project]..covidDeaths dea
join [portfolio project]..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsVac

--TEMP TABLE create table #percentpopulationvaccinated

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(225),
location  nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio project]..covidDeaths dea
join [portfolio project]..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #percentpopulationvaccinated

--create view ##percentpopulationvaccinated

CREATE view percentVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [portfolio project]..covidDeaths dea
join [portfolio project]..covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


SELECT *
FROM percentVaccinated
