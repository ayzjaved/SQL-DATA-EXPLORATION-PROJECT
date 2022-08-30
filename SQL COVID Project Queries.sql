--# SQL COVID PROJECT (DATA EXPLORATION QUERIES

)
--# COVID DEATH TABLE 
Select *
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
order by 3,4


--# COVID VACCINATION TABLE
Select *
From [Portfolio project 1]..CovidVaccinations
order by 3,4


--# DATA SELECTION
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
order by 1,2


--# TOTAL CASES VS NEW CASES 
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio project 1]..[CovidDeaths]
where location like '%states%' and continent is not null
order by 1,2


--# TOTAL CASES VS POPULATION
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
order by 1,2


--# MAXIMUM POPULATION INFECTION RATE
Select location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentOfPopulationInfected
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
Group by location, population
order by PercentOfPopulationInfected desc


--# DATA BREAKDOWN THROUGH CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
Group by continent
order by TotalDeathCount desc


--# COUNTRIES WITH HIGHEST DEATH COUNT PER POPUATIONS 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
Group by location
order by TotalDeathCount desc


--# CONTINENT HIGHEST DEATH RATE 
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio project 1]..[CovidDeaths]
where continent is not null
Group by location
order by TotalDeathCount desc


--# GLOBAL INFO OF DEATH RATE
Select SUM(new_cases) as  total_cases, SUM(cast(new_deaths as int))  as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio project 1]..[CovidDeaths]
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2


--# VACCINATION DATA OF POPULATION
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccines
--, (RollingPeopleVaccines/Population)*100
From [Portfolio project 1]..CovidDeaths dea
join [Portfolio Project 1]..CovidVaccinations vacc 
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
order by 2,3


--# BY TABLE EXPRESSION CTE FOR BETTER QUERY 
with PopvsVacc (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccines)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccines
--, (RollingPeopleVaccines/Population)*100
From [Portfolio project 1]..CovidDeaths dea
join [Portfolio Project 1]..CovidVaccinations vacc 
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccines/Population)*100
From PopvsVacc

--#  ANOTHER METHOD FOR CREATING TEMPLATE TABLE 
DROP Table if exists #PercentPopulationVaccination
Create table  #PercentPopulationVaccination
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
population numeric,
new_Vaccinations numeric,
RollingPeopleVaccines numeric
)
Insert into #PercentPopulationVaccination
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccines
--, (RollingPeopleVaccines/Population)*100
From [Portfolio project 1]..CovidDeaths dea
join [Portfolio Project 1]..CovidVaccinations vacc 
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
--order by 2,3
Select * , (RollingPeopleVaccines/Population)*100
From #PercentPopulationVaccination


--# VIEW TO STORE DATA FOR VISSUALIZATION
Create View PercentPopulationVaccination as
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccines
--, (RollingPeopleVaccines/Population)*100
From [Portfolio project 1]..CovidDeaths dea
join [Portfolio Project 1]..CovidVaccinations vacc 
	On dea.location = vacc.location
	and dea.date = vacc.date 
where dea.continent is not null
--order by 2,3
