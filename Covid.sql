select * from covid_Deaths
where continent is not null
order by location , date


-- select Data that we are going to be using

select location , date ,total_cases , new_cases , total_deaths , population
from covid_deaths
where continent is not null
order by location , date

--- looking at total cases vs total deaths
select location , date ,total_cases  , total_deaths , (Total_deaths/Total_cases)* 100 as DeathPercent
from covid_deaths
where location like '%states%'
order by location , date

--- looking at total cases vs population
--- shows what percentage of population got covid
select location , date ,total_cases  , population , (Total_cases/population)* 100 as PercentpopulationInfection
from covid_deaths
where location like '%states%'

order by location , date

--- looking at countries with highest ingection rate compared to population
select location  ,max(total_cases) as HighInfectionCount , population , Max((Total_cases/population))* 100 as PercentpopulationInfected
from covid_deaths
--where location like '%states%'
where continent is not null
group by   location ,population
order by PercentpopulationInfected desc

showing countries with highest death count per population
select location , max(cast(total_deaths as int)) as Totaldeathcount
from covid_deaths
--where location like '%states%'
where continent is not null
group by   location
order by Totaldeathcount desc

--- LET'S BREAK THINGS DOWN BY CONTINENT

select continent , max(cast(total_deaths as int)) as Totaldeathcount
from covid_deaths
--where location like '%states%'
where continent is not null
group by   continent
order by Totaldeathcount desc

---showing the continent with the highest death count per population
select continent , max(cast(total_deaths as int)) as Totaldeathcount
from covid_deaths
--where location like '%states%'
where continent is not null
group by   continent
order by Totaldeathcount desc




---Global Numbers--
select  date , sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(New_cases)*100 as deathpercent
from Covid_deaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2




---looking at the total population vs vaccinations

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.Date)
from covid_deaths dea
Join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
from covid_deaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


----- USE CTE

with popvsVac ( continent , location , date , population , NEw_vaccinations , RollingPeoplevaccinated)
as
(select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
from covid_deaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeoplevaccinated/population)*100
from popvsVac



---TEMP TABLE
Drop Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)


Insert into #PercentPopulationVaccinated

select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
from covid_deaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (RollingPeoplevaccinated/population)*100
from #PercentPopulationVaccinated

---Creating View to store viz
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location ,dea.date , dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeoplevaccinated
from covid_deaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3