select *
from CovidDeaths
where continent is null
order by 3,4

---------------------------------------------------------------------
---------------------------------------------------------------------

select *
from CovidVaccination
order by 3,4

---------------------------------------------------------------------
--data we will use
---------------------------------------------------------------------


select location ,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

---------------------------------------------------------------------
--Locations
---------------------------------------------------------------------


select distinct(location) as locations
from CovidDeaths
order by  locations

---------------------------------------------------------------------
-- Total_cases vs Total_deaths in Egypt
---------------------------------------------------------------------

select location ,date,total_cases,total_deaths ,(Cast ( total_deaths as float ) / Cast ( total_cases as float ))*100 as DeathPercentage
from CovidDeaths
where location = 'Egypt'
order by 1,2

---------------------------------------------------------------------
-- Total_cases vs Population in Egypt
---------------------------------------------------------------------

select location ,date,Population ,total_cases,(Cast ( total_cases as float ) / Cast ( Population as float ))*100 as CovidCasesPercentage
from CovidDeaths
where location = 'Egypt'
order by 1,2

---------------------------------------------------------------------
-- Total_cases vs Population in all locations
---------------------------------------------------------------------

select location ,date,Population ,total_cases,(Cast ( total_cases as float ) / Cast ( Population as float ))*100 as CovidCasesPercentage
from CovidDeaths
where continent is not null
order by 1,2

---------------------------------------------------------------------
-- Infection rates for locations vs Population
---------------------------------------------------------------------

select location ,Population ,max(total_cases) as MaxTotalCases,
max((Cast ( total_cases as float ) / Cast ( Population as float )))*100 as CovidCasesPercentage
from CovidDeaths
where continent is not null
group by location ,Population
order by CovidCasesPercentage

---------------------------------------------------------------------
-- The most infected Percentage 5 locations
---------------------------------------------------------------------

select top 5 location ,Population ,max(total_cases)as MaxTotalCases,
max((Cast ( total_cases as float ) / Cast ( Population as float )))*100 as CovidCasesPercentage
from CovidDeaths
where continent is not null
group by location ,Population
order by CovidCasesPercentage desc

---------------------------------------------------------------------
-- The most infected 10 locations
---------------------------------------------------------------------

select top 10 location ,Population ,max(Cast ( total_cases as float ))as MaxTotalCases,
max((Cast ( total_cases as float ) / Cast ( Population as float )))*100 as CovidCasesPercentage
from CovidDeaths
where continent is not null
group by location ,Population
order by MaxTotalCases desc


---------------------------------------------------------------------
--  Total_deaths vs Population
---------------------------------------------------------------------

select  location ,Population ,max(Cast ( total_deaths as float ))as MaxTotalDeaths,
max((Cast ( total_deaths as float ) / Cast ( Population as float )))*100 as CovidDeathPercentage
from CovidDeaths
where continent is not null
group by location ,Population
order by MaxTotalDeaths 


---------------------------------------------------------------------
--  The most death 10 locations
---------------------------------------------------------------------

select top 10 location ,Population ,max(Cast ( total_deaths as float ))as MaxTotalDeaths,
max((Cast ( total_deaths as float ) / Cast ( Population as float )))*100 as CovidDeathPercentage
from CovidDeaths
where continent is not null
group by location ,Population
order by MaxTotalDeaths desc

---------------------------------------------------------------------
--  Total_deaths vs Population (Continents)
---------------------------------------------------------------------

select  location ,max(Cast ( total_deaths as float ))as MaxTotalDeaths,
max((Cast ( total_deaths as float ) / Cast ( Population as float )))*100 as CovidDeathPercentage
from CovidDeaths
where continent is null
group by location ,Population
order by MaxTotalDeaths desc


---------------------------------------------------------------------
--  Global Numbers
---------------------------------------------------------------------

select  sum (Cast ( Population as float ))as GlobalPopulation ,
sum(Cast ( new_cases as float ))as GlobalCases , sum(Cast ( new_deaths as float ))as GlobalDeaths,
(sum(Cast ( new_cases as float ))/sum (Cast ( Population as float )))*100 as GlobalCovidCasesPercentage,
(sum(Cast ( new_deaths as float ))/sum (Cast ( Population as float )))*100 as GlobalCovidDeathPercentage
from CovidDeaths
where continent is not null

---------------------------------------------------------------------
--  Global Numbers vs date
---------------------------------------------------------------------

select  date,sum (Cast ( Population as float ))as GlobalPopulation ,
sum(Cast ( new_cases as float ))as GlobalCases , sum(Cast ( new_deaths as float ))as GlobalDeaths,
(sum(Cast ( new_cases as float ))/sum (Cast ( Population as float )))*100 as GlobalCovidCasesPercentage,
(sum(Cast ( new_deaths as float ))/sum (Cast ( Population as float )))*100 as GlobalCovidDeathPercentage
from CovidDeaths
where continent is not null
group by date
order by date 


---------------------------------------------------------------------
--  Join tabels
---------------------------------------------------------------------

select  *
from CovidDeaths as CDs join CovidVaccination as CVs
on CDs.date=CVs.date and CDs.location=CVs.location

---------------------------------------------------------------------
--  Total Population vs Totale Vaccination for locations
---------------------------------------------------------------------

select  CDs.continent,CDs.location,CDs.date,CDs.population,CVs.new_vaccinations,
sum(Cast(CVs.new_vaccinations as float)) over (partition by CDs.location order by CDs.location) as TotaleVaccination
from CovidDeaths as CDs join CovidVaccination as CVs
on CDs.date=CVs.date and CDs.location=CVs.location
where CDs.continent is not null
order by CDs.location,CDs.date

---------------------------------------------------------------------
--  Total Population vs Totale Vaccination for locations per date
---------------------------------------------------------------------

select  CDs.continent,CDs.location,CDs.date,CDs.population,CVs.new_vaccinations,
sum(Cast(CVs.new_vaccinations as float)) over (partition by CDs.location order by CDs.location,CDs.date ) as TotaleVaccination
from CovidDeaths as CDs join CovidVaccination as CVs
on CDs.date=CVs.date and CDs.location=CVs.location
where CDs.continent is not null
order by CDs.location,CDs.date


---------------------------------------------------------------------
--  CTE (CTEPVLD)  Totale Vaccination Percentage for Locations per date
---------------------------------------------------------------------

with CTEPVLD(continent,location,date,population,new_vaccinations,TotaleVaccination)as(
select  CDs.continent,CDs.location,CDs.date,CDs.population,CVs.new_vaccinations,
sum(Cast(CVs.new_vaccinations as float)) over (partition by CDs.location order by CDs.location,CDs.date ) as TotaleVaccination
from CovidDeaths as CDs join CovidVaccination as CVs
on CDs.date=CVs.date and CDs.location=CVs.location
where CDs.continent is not null
)
select * , (TotaleVaccination/population)*100 as TotaleVaccinationPercentage
from CTEPVLD
order by location,date


------------------------------------------------------------------------
--TEMP (TEMPVLD)  Totale Vaccination Percentage for Locations per date
------------------------------------------------------------------------

Drop table if exists #TEMPVLD
create table #TEMPVLD(Continent nvarchar(255),Location nvarchar(255),Date datetime,Population numeric,New_vaccinations numeric,TotaleVaccination numeric)
insert into #TEMPVLD  
select  CDs.continent,CDs.location,CDs.date,CDs.population,CVs.new_vaccinations,
sum(Cast(CVs.new_vaccinations as float)) over (partition by CDs.location order by CDs.location,CDs.date ) as TotaleVaccination
from CovidDeaths as CDs join CovidVaccination as CVs
on CDs.date=CVs.date and CDs.location=CVs.location
where CDs.continent is not null

select * , (TotaleVaccination/population)*100 as TotaleVaccinationPercentage
from #TEMPVLD
order by Location,Date

------------------------------------------------------------------------
-- Create View for TEMPVLD for later visualization
------------------------------------------------------------------------

create view TEMPVLD as
select  CDs.continent,CDs.location,CDs.date,CDs.population,CVs.new_vaccinations,
sum(Cast(CVs.new_vaccinations as float)) over (partition by CDs.location order by CDs.location,CDs.date ) as TotaleVaccination
from CovidDeaths as CDs join CovidVaccination as CVs
on CDs.date=CVs.date and CDs.location=CVs.location
where CDs.continent is not null

select * 
from TEMPVLD