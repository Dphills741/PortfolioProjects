Select * 
From PortfolioProject..CovidDeaths$
order by 3,4 

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2 



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2 


-- Looking at Total Cases vs Population
-- Shows what percentage has contracted Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population

Select continent, location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where continent is not null
group by continent, location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per population

Select  continent, location, MAX(cast(total_deaths as bigint)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is not null
group by continent, location, population
order by TotalDeathCount desc 

--Breaking it down by continents highest death counts

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is null
group by location
order by TotalDeathCount desc 


--Global Numbers

Select date, SUM(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2 


-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from PopvsVac
order by 2,3



-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime,
population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from #PercentPopulationVaccinated
order by 2,3


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3