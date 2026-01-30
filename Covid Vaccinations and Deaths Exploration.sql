-- Data Exploration part

-- CovaidDeathes Exploration

select *
From PortfolioProject..CovidD

--this means we don't want this colm showing in the data
where continent is not null
order by 3,4


select *
From PortfolioProject..CovidD
where continent is not null
order by 3,4


-- Select Data that we are going to be using

select Location, date, total_cases ,new_cases, total_deaths, population
From PortfolioProject..CovidD
order by 1,2


-- looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Sadui Arabia
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathesPrecentage
From PortfolioProject..CovidD
Where location like '%chaina%'
and continent is not null
order by 1,2

-- Looking at total cases vs Population
-- Shows what precentage of Population
select Location, date, population, total_cases, (total_cases/population)*100 as PrecentPopulationInfected
From PortfolioProject..CovidD
--Where location like '%saudi%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population 

select Location, population, MAX(total_cases) as HighestInfevtionCount, MAX((total_cases/population))*100 as PrecentPopulationInfected
From PortfolioProject..CovidD
--Where location like '%saudi%'
Group by location, population
order by PrecentPopulationInfected desc

-- Showong Countries with Highest Deathes Count per population

Select Location,MAX(cast(total_deaths as int)) as totalDeathsCount
From PortfolioProject..CovidD

--here we fixed the data to show only the contries not the continent
where continent is not null
group by location
order by totalDeathsCount desc



--Break things down by Continent

Select location,MAX(cast(total_deaths as int)) as totalDeathsCount
From PortfolioProject..CovidD
where continent is null
group by location
order by totalDeathsCount desc


-- showing continents with the highest deaths count per population

Select continent,MAX(cast(total_deaths as int)) as totalDeathsCount
From PortfolioProject..CovidD
where continent is not null
group by continent
order by totalDeathsCount desc


-- Global numbers: which gives us the date of the total case and deathes numbers in the world

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathesPrecentage
From PortfolioProject..CovidD
--Where location like '%sadui%'
Where continent is not null
group by date
order by 1,2


-- Total Cases & Deathes in the World
-- 150574977    3180206	 - 2.11204149810363
-- between 2020-2021
-- Start: 2020-01-01
-- End:   2021-04-30

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathesPrecentage
From PortfolioProject..CovidD
-- Where location like '%chaina%'
Where continent is not null
--group by date
order by 1,2


-- CovidVaccinations and Deaths Exploration

-- Join on death.location = vac.location and death.date = vac.date
-- Looking at a cumulative (running) total of people vaccinated per country over time


select death.continent, death.location, death.date ,death.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))

-- Partition: Resets the count for each country and, Order: is for Adds vaccinations day by day in chronological order.
over (partition by death.location order by death.location, death.date) as RollingPepoleVaccinated

from PortfolioProject..CovidD death

join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
order by 2,3


-- Important

-- use CTE
-- Option 1
-- Looking at Ttoal Population vs Vaccinations in the World

With PopulationvsVaccination ( Continnet, location, date, population, new_vaccinations ,RollingPepoleVaccinated) as 

(
select death.continent, death.location, death.date ,death.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))

-- Partition: Resets the count for each country and, Order: is for Adds vaccinations day by day in chronological order.
over (partition by death.location order by death.location, death.date)
as RollingPepoleVaccinated

from PortfolioProject..CovidD death

join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3
)
select * , (RollingPepoleVaccinated/population)*100 as presentage
from PopulationvsVaccination


-- Temp Table
-- Option 2
-- Looking at Ttoal Population vs Vaccinations in the World

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPepoleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select death.continent, death.location, death.date ,death.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))

-- Partition: Resets the count for each country and, Order: is for Adds vaccinations day by day in chronological order.
over (partition by death.location order by death.location, death.date)
as RollingPepoleVaccinated

from PortfolioProject..CovidD death

join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
--Where death.continent is not null
--order by 2,3
select * , (RollingPepoleVaccinated/population)*100 as presentage
from #PercentPopulationVaccinated


-- Creating View to stor data later for visualization

USE PortfolioProject;
GO
Create View PercentPopulationVaccinated2 as 
select death.continent, death.location, death.date ,death.population,vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations))
over (partition by death.location order by death.location, death.date)
as RollingPepoleVaccinated

from PortfolioProject..CovidD death
join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
--order by 2,3


-- view the table that we made and this is someting we can use for visualization later
select *
from PercentPopulationVaccinated2