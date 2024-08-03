select * from PortfolioProject..CovidDeath
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using
select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeath
order by 1,2

--show likelihood of ppl dying when contracted with covid
select location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as death_percent
from PortfolioProject..CovidDeath
where location like '%states%'
order by 1,2

--Looking at total cases vs population in  US, shows what percentage got covid
select location, date, total_cases, population, (total_cases/NULLIF(population,0)) * 100 as caseToPop
from PortfolioProject..CovidDeath
where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/NULLIF(population,0)) * 100) as PercentPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc


--show countries with highest death count
select location, Max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeath
--where location like '%india%'
group by location,population
order by 2 desc

--show continent
select continent, Max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeath
where Continent is not Null
group by continent
order by 2 desc

--show countries without continent
select location, Max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeath
where Continent is  Null
group by location
order by 2 desc

----Global numbers
select sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths, sum(new_deaths)/sum(nullif(new_cases,0)) * 100 as DeathPercentage  --, total_deaths, (total_deaths/NULLIF(total_cases,0)) * 100 as death_percent
from PortfolioProject..CovidDeath
where continent is not null 
order by 2 desc

-----look at total vaccination

select top (100) dea.location, dea.continent, dea.date,dea.population,vac.new_vaccinations, 
sum(CAST(vac.new_vaccinations as int)) Over (Partition by dea.location)
from PortfolioProject.dbo.CovidDeath dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
and dea.continent is not null and vac.new_vaccinations is not null
--order by vac.new_vaccinations desc


--Temp table
drop table if exists #TempCovidDeath
create table #TempCovidDeath(
location varchar(50),
HighestInfectionCount numeric,
population numeric,
PercentpopulationInfected numeric
)

insert into #TempCovidDeath 
select location, Max(total_cases) as HighestInfectionCount, population, Max((total_cases/NULLIF(population,0)) * 100) as PercentPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc


select * from #TempCovidDeath

--create Views to store the data later for visualization
create view PercentPopulationVaccinated as (
select continent, Max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeath
where Continent is not Null
group by continent
--order by 2 desc
)

select * from PercentPopulationVaccinated
