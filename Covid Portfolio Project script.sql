Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Changing datatypes
Select *
from CovidDeaths

exec sp_help 'CovidDeaths'

alter table CovidDeaths
alter column total_deaths float 

alter table CovidDeaths
alter column total_cases float

alter table CovidDeaths
alter column new_deaths float

alter table CovidDeaths
alter column new_cases float

alter table Covidvaccinations 
alter column new_vaccinations numeric

alter table CovidDeaths
alter column population float

--Select Data that we're going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases vs Population
Select location, date,population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like'%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like'%states%'
group by location, population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
group by location
order by TotalDeathCount desc

--Lets break things down by continent 

--Showing Continents with the highest death count per population


Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Case when SUM(new_cases) = 0 then 0 else SUM(cast(new_deaths as int))/SUM(New_Cases)END *100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP Table 
DROP Table if exists #PercentPolulationVaccinated
Create Table #PercentPolulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert Into #PercentPolulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPolulationVaccinated


--Creating view to store data later for visualizations

Create View PercentPolulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(numeric,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--Order by 2,3

Select *
From PercentPolulationVaccinated