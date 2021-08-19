select *
from [sql-PortfolioProject]..covidDeaths
Where continent is not NUll
order by 3,4

--select *
--from [sql-PortfolioProject]..covidVaccines
--order by 3,4

-- select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [sql-PortfolioProject]..covidDeaths
order by 1,2


-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [sql-PortfolioProject]..covidDeaths
Where location Like 'Ind%'
order by 1,2

-- Total cases vs Population
-- Shows What Percentage of population got Covid

Select location, date, total_cases, population,(total_cases/population)*100 as CasesPercentage
From [sql-PortfolioProject]..covidDeaths
Where location Like 'India'
order by 1,2

-- Countries With Highest Infection Rate

Select location, population, Max(total_cases) As MaxInfectedCount, Max((total_cases/population)*100) As InfectedPercentage
From [sql-PortfolioProject]..covidDeaths
Group by location,population
order by InfectedPercentage Desc


-- Countries with Highest Death Rate per Population

Select location, Max(Cast(total_deaths as int)) As MaxDeaths
From [sql-PortfolioProject]..covidDeaths
Where continent is not Null
Group by location
order by MaxDeaths Desc


-- continents with Highest Death Rate Per Population
Select continent,Max(CAST(total_deaths as int)) As TotalDeaths
From [sql-PortfolioProject]..covidDeaths
where continent is not null
group by continent
order by TotalDeaths DESC

-- Global numbers

Select  Sum(new_cases) As TotalCases, Sum(Cast(total_deaths As int)) As TotalDeaths, sum(Cast(total_deaths As int))/Sum(new_cases) *100 As DeathPercentage
From [sql-PortfolioProject]..covidDeaths
--Where location Like 'India'
Where continent is not NULL
--Group by date
order by 1,2

select *
from [sql-PortfolioProject]..covidVaccines

-- Joining CovidDeath And CovidVaccine Tables

Select *
From [sql-PortfolioProject]..covidDeaths cd
Join [sql-PortfolioProject]..covidVaccines cv
	ON cd.location = cv.location
	AND cd.date = cv.date

-- Total Population vs Total Vaccinations using CTE
With popvsvac (continent,location,date,population,new_vaccinations,CountofVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
Sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location,cd.date) As CountOfVaccinated
From [sql-PortfolioProject]..covidDeaths cd
Join [sql-PortfolioProject]..covidVaccines cv
	ON cd.location = cv.location
	AND cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *,(CountofVaccinated/population)*100 As percentageVaccinated
From popvsvac
Where location Like 'India'
order by percentageVaccinated DESC

-- Total population vs Total Vaccination using Temp Table
Drop Table if exists #percentagepeopleVaccinated
Create Table #percentagepeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CountofVaccinated numeric,
)

Insert into #percentagepeopleVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
Sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location,cd.date) As CountOfVaccinated
From [sql-PortfolioProject]..covidDeaths cd
Join [sql-PortfolioProject]..covidVaccines cv
	ON cd.location = cv.location
	AND cd.date = cv.date
where cd.continent is not null
--order by 2,3

select *, (CountofVaccinated/population)*100 As VaccinatedPercentage
From #percentagepeopleVaccinated


-- Creating View to store Data for Later Visulization

Create View percentagepeopleVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
Sum(CAST(cv.new_vaccinations as int)) OVER (partition by cd.location order by cd.location,cd.date) As CountOfVaccinated
From [sql-PortfolioProject]..covidDeaths cd
Join [sql-PortfolioProject]..covidVaccines cv
	ON cd.location = cv.location
	AND cd.date = cv.date
where cd.continent is not null
--order by 2,3


select *
From percentagepeopleVaccinated