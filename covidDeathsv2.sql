SELECT * 
FROM PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 3,4
--SELECT * 
--FROM PortfolioProjects..CovidVaccinate
--ORDER BY 3,4 

-- SELECT THE DATA THAT WE USING IN THE PROJECT

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProjects..CovidDeaths
where continent is not null
ORDER BY 1,2

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- shows likelihood of dying your contrac covid in your country

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths / total_cases)*100 AS DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE	 '%states%' and  continent is not null
ORDER BY 1,2

-- looking at the total cases vs population
-- shows whats percen of population got with covid
SELECT location,date,total_cases,new_cases,population,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE	 '%vene%' and continent is not null
ORDER BY 1,2

--looking at countries whith highest infection rate compared to population

SELECT location,population,max(total_cases) as HigthestIfection, max((total_cases/population)*100) AS PercentPopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
group by location,population
ORDER BY PercentPopulationInfected desc

-- showing countries with higthest death count per population
-- cuando tienes un error al mostrar los datos la funcion cast los setea a entero
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
WHERE continent is not null
group by location
order by TotalDeathCount desc

--lest´s break things by continent -dividir por continentes

--SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProjects..CovidDeaths
--WHERE continent is null
--group by location
--order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
WHERE continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers
SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null 
--group by date
ORDER BY 1,2

-- looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProjects..CovidDeaths dea
	join PortfolioProjects..CovidVaccinate vac
		on dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent is not null 
ORDER BY 2,3
-- use a CTE
with PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProjects..CovidDeaths dea
	join PortfolioProjects..CovidVaccinate vac
		on dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent is not null 
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/Population) *100
from PopvsVac

-- temp table
drop table if exists #PercentPopulationVaccinate
create table #PercentPopulationVaccinate
(
Continent varchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinate
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProjects..CovidDeaths dea
	join PortfolioProjects..CovidVaccinate vac
		on dea.location = vac.location and dea.date = vac.date
	--WHERE dea.continent is not null 
--ORDER BY 2,3
select *, (RollingPeopleVaccinated/Population) *100
from #PercentPopulationVaccinate

-- creating views to store data for later viualizacion
create view PercentPopulationVaccinate as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProjects..CovidDeaths dea
	join PortfolioProjects..CovidVaccinate vac
		on dea.location = vac.location and dea.date = vac.date
	WHERE dea.continent is not null 
--ORDER BY 2,3

select * 
from PercentPopulationVaccinate