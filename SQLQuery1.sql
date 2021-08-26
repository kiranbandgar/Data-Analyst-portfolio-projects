select *
from project..['covid deaths$']
where continent is not null
order by 3,4


--select data that are going to start
select location, date, total_cases, new_cases,population
from project.dbo.['covid deaths$']
order by 1,2

-- total cases vs total deaths
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from project.dbo.['covid deaths$']
order by 1,2

--percentage of populaiton infected with covid
select location,date,total_cases,population,(total_cases/population)*100 as Percentage_population_infected
from project..['covid deaths$']
where continent is not null
order by 1,2

--countries with high infection rate compared to population
select location,MAX(total_cases) as high_infection_count, max((total_cases/population))*100 as infection_population_percentage
from project.dbo.['covid deaths$']
where continent is not null
group by location
order by infection_population_percentage desc

--countries with high death rate compared to population
select location, MAX(cast(total_deaths as int)) as totaldeathcount
from project..['covid deaths$']
where continent is not null
group by location
order by totaldeathcount desc

--continent with high death rate
select continent, max(cast(total_deaths as int)) as total_death_count
from project..['covid deaths$']
where continent is not null
group by continent
order by total_death_count desc

--Global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from project..['covid deaths$']
where continent is not null
order by 1,2

--total population vs total vaccination
--shows the percentage of people get one vaccine of covid

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from project..['covid deaths$'] dea
join project..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2

--using CTE to solve calculation
with populationvsvaccination(continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from project..['covid deaths$'] dea
join project..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 1,2
)
select *,(RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from populationvsvaccination

--using temp table to solve above calculation
drop table if exists #percentage_population_vaccinated
create table #percentage_population_vaccinated
(continent varchar(50),
location varchar(50),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into #percentage_population_vaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from project..['covid deaths$'] dea
join project..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 1,2
select *,(RollingPeopleVaccinated/population)*100
from #percentage_population_vaccinated

--create view for further visualizations
create view percent_population_vaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from project..['covid deaths$'] dea
join project..['covid vaccinations$'] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

 
