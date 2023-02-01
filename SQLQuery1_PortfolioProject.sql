Select * 
from PortfolioProject..CovidDeaths$
Where continent is not null 
order by  3,4 

--Select * 
--from PortfolioProject..CovidVaccinations$
--order by  3,4 

--**Here I am selecting the data that I will be using**

Select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths$
order by  1, 2

-- Here I will be looking at the Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country. 

Select location, date, total_cases, total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths$
--Where location--like '%states%' <- this filters the data to represent just the United States 
order by  1, 2

--Looking at the Total Cases Vs Population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (Total_cases/population)*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths$ 
where location like '%china%'
--Where location like '%states%'
order by  1, 2

--I am looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentofPopulationInfected
from PortfolioProject..CovidDeaths$ 
group by location, population
order by PercentofPopulationInfected desc

-- I am looking at the countries with the Highest Death Count per Population


Select location, MAX(cast(total_deaths as int)) as TotalDeathCount  --I have to cast the variable as it is a char and I need it to read as an integer.
from PortfolioProject..CovidDeaths$ 
Where continent is not null 
group by location
order by TotalDeathCount desc


--LET's BREAK THINGS DOWN BY CONTINENT
--I am showing the Continents with the highest death counts per population. 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount  --I have to cast the variable as it is a char and I need it to read as an integer.
from PortfolioProject..CovidDeaths$ 
Where continent is not null 
group by continent 
order by TotalDeathCount desc

-- I am looking at Global Numbers

Select date, SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPerctage --total_cases, total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null 
group by date
order by 1, 2 

--Total global Cases, Deaths, and Death Percentage 

Select SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPerctage --total_cases, total_deaths, (total_deaths/Total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null 
--group by date
order by 1, 2 


--I am Looking at the Total Population vs New Vaccinations per day

--USE CTE 

With PopvsVac (continent, location, date, population, new_vaccinations, RollingCountofPeopleVaxed)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingCountofPeopleVaxed
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select*,(RollingCountofPeopleVaxed/population)*100
from PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
New_vaccinations numeric,
RollingCountofPeopleVaxed numeric 
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingCountofPeopleVaxed
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select*,(RollingCountofPeopleVaxed/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations 


Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingCountofPeopleVaxed
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *
from PercentPopulationVaccinated



