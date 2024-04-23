SELECT *
  FROM [Portfolio Project]..CovidDeaths
 
SELECT *
  FROM [Portfolio Project]..CovidVaccinations


   -- INFORMACIÓN MÁS IMPORTANTE --

SELECT location,
       date,
	   total_cases,
	   new_cases, 
	   total_deaths,
	   population
  FROM [Portfolio Project].dbo.CovidDeaths
 ORDER BY location, date DESC


-- AQUÍ CONTÉ LA CANTIDAD DE REGISTROS POR CONTINENTE --

SELECT DISTINCT continent,
       count(continent) AS count_continent
  FROM [Portfolio Project]..CovidDeaths
 WHERE continent IS NOT NULL 
 GROUP BY continent
 ORDER BY count_continent DESC


 -- PORCENTAJE DE MUERTES EN EEUU--

SELECT location,
       date,
	   total_cases,
       total_deaths,
       (total_deaths)/(total_cases)*100 AS likelihood_of_dying
  FROM [Portfolio Project].dbo.CovidDeaths
 WHERE location LIKE '%states' AND continent IS NOT NULL


 -- PORCENTAJE DE MUERTES POR CONTINENTE --

 -- OP 1 --

SELECT continent,
       SUM(CAST(total_cases AS BIGINT)) AS total_cases,
       SUM(CAST(total_deaths AS BIGINT)) AS total_deaths,
       SUM(CAST(SUM(CAST(total_deaths AS BIGINT)*1.0)/
	       NULLIF(SUM(CAST(total_cases AS BIGINT)*1.0), 0)*100 AS DECIMAL(10, 3))) 
		   OVER (PARTITION BY continent) AS likelihood_of_dying
  FROM [Portfolio Project].dbo.CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY continent

 -- OP 1 -- BETTER --

SELECT continent,
       SUM(CAST(total_cases AS BIGINT)) AS total_cases,
       SUM(CAST(total_deaths AS BIGINT)) AS total_deaths,
       SUM(CAST(total_deaths AS BIGINT)*1.0)/
	       NULLIF(SUM(CAST(total_cases AS BIGINT)*1.0), 0)*100 AS likelihood_of_dying
  FROM [Portfolio Project].dbo.CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY continent


 -- OP 2 --

WITH CTE_continent AS
  (SELECT continent,
          SUM(CAST(total_cases AS BIGINT)) AS total_cases,
          SUM(CAST(total_deaths AS BIGINT)) AS total_deaths
     FROM [Portfolio Project]..CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY continent)

SELECT continent,
       total_cases,
       total_deaths,
       CAST((total_deaths*1.00/total_cases*1.00)*100 AS DECIMAL(10, 2)) AS likelihood_of_dying
FROM CTE_continent


 -- PORCENTAJE DEL TOTAL --

-- OP 1 --

 WITH CTE_continent AS
	(SELECT continent,
			SUM(CAST(total_cases AS BIGINT)) AS total_cases,
			SUM(CAST(total_deaths AS BIGINT)) AS total_deaths
	  FROM [Portfolio Project]..CovidDeaths
     WHERE continent IS NOT NULL
	 GROUP BY continent)

 SELECT continent,
        total_cases,
		total_deaths,
		CAST(total_deaths*1.0/
			 (SELECT SUM(total_deaths)
			    FROM CTE_continent)*100 AS DECIMAL(10,2)) AS total_deaths_percentage
   FROM CTE_continent


-- OP 2 --

SELECT continent,
       SUM(CAST(total_cases AS BIGINT)) AS total_cases,
	   SUM(CAST(total_deaths AS BIGINT)) AS total_deaths,
	   CAST(SUM(CAST(total_deaths AS BIGINT)*1.0)/
	                (SELECT SUM(CAST(total_deaths AS BIGINT)) 
	                   FROM [Portfolio Project].dbo.CovidDeaths 
			          WHERE continent IS NOT NULL)*100 AS DECIMAL(10,2)) AS likelihood_of_dying
  FROM [Portfolio Project].dbo.CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY continent


 -- PORCENTAJE DE LA POBLACIÓN SE INFECTÓ CON COVID --XX--
 /* 
 NO se sabe si se tomará en cuenta porque implica que el número de casos es mayor que la población 2000%
 No se especifica a

 SELECT location,
	    SUM(total_cases) AS total_cases, 
	    AVG(population) AS population,
		CAST(SUM(total_cases)/AVG(population)*100 AS DECIMAL (10,2)) AS percentage_infected
  FROM [Portfolio Project].dbo.CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location
 ORDER BY location
 */

 -- Shows what percentage of population infected with Covid
 -- Explicar que tiene sentido si se ve a nivel fecha, y location. En tal día en tal país el x% de población estaba infectada

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
  From [Portfolio Project].dbo.CovidDeaths
--Where location like '%states%'
order by 1,2


-- más alto porcentaje de covid por día de acuerdo a la población--

SELECT location,
       population,
	   MAX(total_cases) AS highest_case,
	   CAST(MAX(total_cases/population)*100 AS DECIMAL (10,2)) AS highest_rate
  FROM [Portfolio Project]..CovidDeaths
 GROUP BY location, population
 ORDER BY 4 DESC,3 DESC
  


  -- más alto porcentaje de casos de covid por día de acuerdo a la población--

SELECT location,
       population,
	   MAX(total_cases) AS highest_count,
	   CAST(MAX(total_cases/population)*100 AS DECIMAL (10,2)) AS highest_rate
  FROM [Portfolio Project]..CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location, population
 ORDER BY 4 DESC,3 DESC
  

  -- más alto porcentaje de muertes de casos de covid por día de acuerdo a la población Y SU RANGO --

WITH cte2 AS (
SELECT location,
       population,
	   MAX(total_deaths) AS highest_count,
	   CAST(MAX(total_deaths/population)*100 AS DECIMAL (10,2)) AS highest_rate,
	   RANK () OVER(ORDER BY MAX(total_deaths/population) DESC) AS rank
  FROM [Portfolio Project]..CovidDeaths
 GROUP BY location, population
 
)

-- quiero saber rango en el que está Col ---

SELECT *
  FROM cte2
WHERE location LIKE '%col%'


-- muertes por location

SELECT location,
       SUM(CAST(total_deaths AS INT)) AS total_deaths
  FROM [Portfolio Project]..CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY location
 ORDER BY 2 DESC

 -- mayores muertes por location POR DÍA

 SELECT location,
        MAX(CAST(total_deaths AS INT)) AS MAX_deaths
   FROM [Portfolio Project]..CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY location
  ORDER BY 2 DESC

  --
  -- Showing contintents with the highest death count per population

  SELECT continent, MAX(CAST(total_deaths AS BIGINT)) AS total_deaths
    FROM [Portfolio Project]..CovidDeaths
   WHERE continent IS NOT NULL
   GROUP BY continent
   ORDER BY 2 DESC


   --New cases, all the new cases que se agregan al total de casos

   -- GLOBAL NUMBERS

   -- estas son las muertes totales nuevas de ese día, no acumuladas. el total case son acumuladas a ese día.
   -- esto muestra del mundo mundial el número de casos y muertes

SELECT SUM(new_cases) AS total_cases,
       SUM(cast(new_deaths AS BIGINT)) AS total_deaths, 
	   SUM(cast(new_deaths AS BIGINT))/SUM(New_Cases)*100 AS DeathPercentage
  FROM [Portfolio Project]..CovidDeaths
 WHERE continent is not null 
 ORDER BY 1,2

 -- porcentaje de la población que ha recibido al menos una sóla vacuna

 SELECT cd.location,
        cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.date ASC) AS running_vaccinations,
		SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.date ASC)/population*100 AS percentage_vaccinations
   FROM [Portfolio Project]..CovidDeaths cd
   JOIN [Portfolio Project]..CovidVaccinations cv
     ON cd.location = cv.location 
	    AND cd.date = cv.date --COMBO
  WHERE cd.continent IS NOT NULL
  
  -- la misma query pero en Temp Table

 DROP TABLE IF EXISTS #TempTable -- para evitar errores

 CREATE TABLE #TempTable 
 (
  location VARCHAR(255),
  date DATETIME,
  population BIGINT,
  new_vaccinations BIGINT,
  running_vaccinations BIGINT,
  percentage_vaccinations BIGINT
  )

  INSERT INTO #TempTable
  SELECT cd.location,
        cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.date ASC) AS running_vaccinations,
		SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.date ASC)/population*100 AS percentage_vaccinations
   FROM [Portfolio Project]..CovidDeaths cd
   JOIN [Portfolio Project]..CovidVaccinations cv
     ON cd.location = cv.location 
	    AND cd.date = cv.date --COMBO
  WHERE cd.continent IS NOT NULL

  
  SELECT *
    FROM #TempTable
	
	GO

CREATE VIEW View1 AS
 SELECT cd.location,
        cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.date ASC) AS running_vaccinations,
		SUM(CAST(cv.new_vaccinations AS BIGINT)) OVER (PARTITION BY cd.location ORDER BY cd.date ASC)/population*100 AS percentage_vaccinations
   FROM [Portfolio Project]..CovidDeaths cd
   JOIN [Portfolio Project]..CovidVaccinations cv
     ON cd.location = cv.location 
	    AND cd.date = cv.date --COMBO
  WHERE cd.continent IS NOT NULL

  GO

  SELECT *
    FROM View1


--	DROP VIEW View1 -- esto se elimina dependiendo la base de datos seleccionada --


