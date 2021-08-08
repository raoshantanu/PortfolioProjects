
-- Test Query:
SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--Select Data that we'll be using, & use ORDER BY to order by column 1, then column 2 if first column shares values:
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2


-- Look at Total Cases vs Total Deaths:
-- Shows likelihood of dying if you contract COVID in your country (United States in this example):
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at total cases vs population:
-- Displays Percentage of Population that contracted COVID:
SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPopulation
FROM PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

--Looking at Countries with Highest Infection Rates compared to Population:
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP by location, population
order by PercentPopulationInfected desc;


-- Looking at Countries with the Highest Death Count per Population:
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP by location
order by TotalDeathCount desc;


--Showing Continents with highest Death Count:
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP by location
order by TotalDeathCount desc;


-- GLobal Numbers/Statistics:
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


--Looking at Vaccinations Table now, and performing JOIN on two data sets:
SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and
	dea.date = vac.date;



-- Looking at Total Population vs Vaccinations:
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;



--Using CTE:
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac












