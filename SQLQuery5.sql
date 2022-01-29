SET ANSI_WARNINGS OFF


select * from [CovidDB-TEST]..CovidDeaths
order by 3,4


--select * from [CovidDB-TEST]..CovidVaccinations
--order by 3,4



select location, date, total_cases, new_cases, total_deaths, population 
from [CovidDB-TEST]..CovidDeaths
order by 1,2


-- Total Cases VS Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [CovidDB-TEST]..CovidDeaths
where location like '%egypt%'
order by 1,2

-- Total Cases VS Population
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulation
from [CovidDB-TEST]..CovidDeaths
where location like '%egypt%'
order by 1,2



-- Countries with the highest Infection Rate 
select location, population, MAX(total_cases) as max_total_cases, MAX((total_cases/population)*100) as max_Infected_population
from [CovidDB-TEST]..CovidDeaths
group by location, population
order by max_Infected_population desc




-- Countries with the highest death count
select location, MAX(cast(total_deaths as int)) as max_total_deaths
from [CovidDB-TEST]..CovidDeaths
where continent is not null
group by location
order by max_total_deaths desc



-- Global Numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as death_percentage
from [CovidDB-TEST]..CovidDeaths
where continent is not null
group by date 
order by 1,2


-- join the two tables
select * 
From [CovidDB-TEST]..CovidDeaths deaths
join [CovidDB-TEST]..CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date

 
-- Vaccinations VS Population

-- using CTE




with PopvsVacc (continent, location, date, population, new_vaccinations, people_vaccinated)
as (
select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
 SUM(cast(vacc.new_vaccinations as int)) over (Partition by deaths.location order by deaths.location,deaths.date) as people_vaccinated
From [CovidDB-TEST]..CovidDeaths deaths
join [CovidDB-TEST]..CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date
where deaths.continent is not null
--order by 2, 3
)
 
select *, (people_vaccinated/population) * 100 as  vaccinated_percentage
from PopvsVacc




-- create view
create view PercentPopulationVaccinated as 
select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
 SUM(cast(vacc.new_vaccinations as int)) over (Partition by deaths.location order by deaths.location,deaths.date) as people_vaccinated
From [CovidDB-TEST]..CovidDeaths deaths
join [CovidDB-TEST]..CovidVaccinations vacc
	on deaths.location = vacc.location and deaths.date = vacc.date
where deaths.continent is not null