Select *
From PortfolioProject..CovidDeaths
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract COVID-19 in your country (in my case United States)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Displays percentage of population that contracted COVID-19

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as HighInfectionPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location, population
order by HighInfectionPercentage desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location
order by TotalDeathCount desc

-- Ran into an issue. Searching for locations and Continents would show instead of Countries under "Location".

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

-- Trying it again!

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Breaking things down by Continent and no longer by Country



-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- TotalDeathCount in North America seems a lot lower than initially anticipated, lets see why.

Select Location, continent, MAX(cast(total_deaths as int)) as TotalDeathCountForMax, SUM(cast(total_deaths as int)) as TotalDeathCountWithOutMax
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group by location, continent
order by continent desc

-- Initially, I noticed that the total death count would change due to the fact we used  "where continent is not null".
-- When I changed it to "Where continent is null", the number was larger. We were filtering out much needed data.

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(new_cases)/SUM(cast(new_deaths as int))*100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated