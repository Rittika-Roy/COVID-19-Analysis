select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--data we are going to use

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contact covid in your country

select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location='India' and continent is not null
order by 1,2

--looking at total cases vs population
--shows percentage of people who got infected with covid

select Location, date, total_cases,  population, (total_cases/population)*100 as total_case_percentage
from PortfolioProject..CovidDeaths
where location='india' and continent is not null
order by 1,2

--looking at countries having highest infection rates as compared to population
select Location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population)*100 )as PercentInfected
from PortfolioProject..CovidDeaths
--where location='india'
where continent is not null
group by location, population 
order by PercentInfected desc

--looking at countries having highest death rates as compared to population

--here we did casting as without casting when we looked at the dataset it didnt feel right to me
select Location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
group by location 
order by HighestDeathCount desc

--after executing the above query ,there are few things that need to be correct like (location=world), (location=south america) as they are grouping entire continent
-- So lets break down using continent 

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by  HighestDeathCount desc

-- for more accurate results lets break down by location

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is  null
group by location
order by  HighestDeathCount desc


--BREAKING DOWN BY CONTINENTS AND RUNNING SOME QUERY ON IT

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by  HighestDeathCount desc

-----GLOBAL NUMBERS

select  date, SUM(new_cases)      -- this gives the sum of new cASES all aroud the world at a a particular date
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


select  date, SUM(new_cases) TotalNewCases , sum(cast(new_deaths as int)) TotalNewDeaths , sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- this will give the total death percentage around the world
select  SUM(new_cases) TotalNewCases , sum(cast(new_deaths as int)) TotalNewDeaths , sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--JOINING THE TWO TABLES
select * from PortfolioProject..CovidVaccinations

--looking at total population vs vaccination

select dea.continent ,dea.location, dea.date ,dea.population , vac.new_vaccinations from
PortfolioProject..CovidDeaths  dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3


select dea.continent ,dea.location, dea.date ,dea.population , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from
PortfolioProject..CovidDeaths  dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--using CTE for looking at total population vs vaccination


With PopVsVac(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent ,dea.location, dea.date ,dea.population , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from
PortfolioProject..CovidDeaths  dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3  as The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified.

)
select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage from PopVsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopoulationVaccinated
create table #PercentPopoulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
RollingPeopleVaccinated bigint
)
 
 INSERT INTO #PercentPopoulationVaccinated
 select dea.continent ,dea.location, dea.date ,dea.population , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from
PortfolioProject..CovidDeaths  dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date

select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage from #PercentPopoulationVaccinated



--CREATING A VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopoulationVaccinated as
 select dea.continent ,dea.location, dea.date ,dea.population , vac.new_vaccinations ,
sum(convert(int,vac.new_vaccinations)) OVER (PARTITION BY  dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 as VaccinationPercentage
from
PortfolioProject..CovidDeaths  dea join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

SELECT * FROM PercentPopoulationVaccinated





