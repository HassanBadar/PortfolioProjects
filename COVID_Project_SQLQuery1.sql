SELECT *
FROM Portfolio_Projects..COVID_deaths
order by 3,4

--SELECT *
--FROM Portfolio_Projects..COVID_vaccines
--order by 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Projects..COVID_deaths
order by 1,2

-- Looking at the total cases vs the total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM Portfolio_Projects..COVID_deaths
where location = 'pakistan'
order by 1,2

-- Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as Case_Percentage
FROM Portfolio_Projects..COVID_deaths
where location = 'pakistan'
order by 1,2

-- Looking at countries with highest infection %age rate

SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population)*100) as Case_Percentage
FROM Portfolio_Projects..COVID_deaths
Group by location, population
order by Case_Percentage desc

-- Showing countries with the highest death count vs population
SELECT location, MAX(cast (total_deaths as int)) as highest_death_count
FROM Portfolio_Projects..COVID_deaths
where continent is not null
Group by location
order by highest_death_count desc

-- Checking by continent
-- Showing the continents with the highest death counts

SELECT continent, MAX(cast (total_deaths as int)) as highest_death_count
FROM Portfolio_Projects..COVID_deaths
where continent is not null
Group by continent
order by highest_death_count desc


-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage	    
FROM Portfolio_Projects..COVID_deaths
Where continent is not null
order by 1,2

-- Looking at total vaccinations vs population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_sum
FROM Portfolio_Projects..COVID_vaccines vac
JOIN Portfolio_Projects..COVID_deaths dea
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
	Order by 2,3

	-- USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, rolling_sum)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_sum
FROM Portfolio_Projects..COVID_vaccines vac
JOIN Portfolio_Projects..COVID_deaths dea
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
	)
Select *, (rolling_sum/population)*100 as vaccination_percentage
From PopVsVac

-- Creating view to store data for later visualizations

Create view PercentagePeopleVaccinated as
With PopVsVac (continent, location, date, population, new_vaccinations, rolling_sum)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_sum
FROM Portfolio_Projects..COVID_vaccines vac
JOIN Portfolio_Projects..COVID_deaths dea
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent is not null
	)
Select *, (rolling_sum/population)*100 as vaccination_percentage
From PopVsVac


