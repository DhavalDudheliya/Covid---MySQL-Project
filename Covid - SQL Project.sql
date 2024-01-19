

select * 
from PortfolioProject..CovidDeaths
--Where continent is not NULL
order by 3,4

--select * 
--from PortfolioProject..CovidVaccination
--order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got covid 
Select location, date, total_cases, population, (cast(total_cases as numeric)/cast(population as numeric))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as numeric)/cast(population as numeric))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by 1,2


-- Showing the countries with highest deathCount per Poplulation
Select location, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENTS
Select location, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by Location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc



-- GLOBAL NUMBERS

-- Showing total cases ( Duration - week )
Select date, total_cases, total_deaths, new_cases, population, (cast(total_cases as numeric)/cast(population as numeric))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location = 'World'

-- showing total cases per week
Select date, SUM(new_cases)
from PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Showing global Death Percentage

--Select location, total_cases, total_deaths, cast(total_deaths as numeric)/cast(total_cases as numeric)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--group by location

Select SUM(cast(new_cases as numeric)) as total_cases, SUM(cast(new_deaths as numeric)) as total_deaths, SUM(cast(new_deaths as numeric))/SUM(cast(new_cases as numeric))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null




-- Loking at toalt population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--********************************* Day by Day Vaccination *********************************************************************************

With PopVsVac (continent,location, date, population, new_vaccinatios, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleCaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac



------ Using Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleCaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



---- Create View #PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleCaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
