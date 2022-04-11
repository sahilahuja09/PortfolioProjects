select location,date,total_cases,new_cases,total_deaths,new_deaths
From coviddeaths
order by 1,2;

-- death percentage 
select location , date , total_cases , total_deaths , (total_deaths/total_cases)* 100 as death_percentage
From coviddeaths
where location = "India";

-- what percentage of population got covid
select location , date , total_cases , population , (total_deaths/population)* 100 as positive_percentage
From coviddeaths
where location = "India";

-- highest infection rate 
select location ,population ,Max(total_cases)  , Max((total_cases/population))* 100 as PopulationInfected
From coviddeaths
group by location ,population
order by PopulationInfected desc;

-- highest death count / population
select location ,population ,Max(cast(total_deaths as float)) as maxDeath, Max((total_deaths/population))* 100 as deathPercentage
From coviddeaths
where continent is not null
group by location ,population
order by maxDeath desc;

select date , Sum(cast(new_cases as float)) as total_cases,sum(cast(new_deaths as float)) as total_deaths
from coviddeaths
group by date;

select dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(convert(vac.new_vaccinations, float )) Over (partition by dea.location order by dea.location ,dea.date) as rolling_count
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
where new_vaccinations!="" and dea.date = vac.date;

-- percentage of population vaccinated on a rolling basis
with popvsvac(date,location,population,new_vaccinations,rolling_count)
as(
select dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(convert(vac.new_vaccinations, float )) Over (partition by dea.location order by dea.location ,dea.date) as rolling_count
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
where new_vaccinations!="" and dea.date = vac.date
)
select *,(rolling_count/population)*100
from popvsvac;

create view PercentPopulationVaccinated as
select dea.date,dea.location,dea.population,vac.new_vaccinations,
sum(convert(vac.new_vaccinations, float )) Over (partition by dea.location order by dea.location ,dea.date) as rolling_count
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location
where new_vaccinations!="" and dea.date = vac.datepercentpopulationvaccinated






