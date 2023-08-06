CREATE DATABASE projects_hr;
USE projects_hr;

SELECT * FROM hr;

-- data cleaning and processing--

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

DESCRIBE hr;

SET sql_safe_updates=0;
UPDATE hr
SET birthdate=CASE
        WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
        END;
        
SELECT birthdate FROM hr;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

UPDATE hr
SET hire_date=CASE
        WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
        WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
        ELSE NULL
        END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
SELECT hire_date FROM hr;

-- change the date format and datatype of termdate column
UPDATE hr
SET termdate=date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate!='';

update hr
SET termdate= NULL
WHERE termdate='';

SELECT termdate FROM hr;

-- create age column

ALTER TABLE hr
ADD COLUMN age INT;

UPDATE HR
SET age= timestampdiff(YEAR,birthdate,curdate());

SELECT * FROM hr;
SELECT MIN(age),MAX(age) FROM hr;

-- 1 What is the gender breakdown of employees in the company
SELECT gender,COUNT(*) AS count
  FROM hr
  WHERE termdate IS NULL
  GROUP BY 1;
  
-- 2 What is the race breakdown of employees in the company
SELECT race,COUNT(*) AS count
	FROM hr
    WHERE termdate IS NULL
    GROUP BY 1;
    
-- 3 What is age distribution of employees in the company

SELECT 
      CASE 
           WHEN age>=18 AND age<=24 THEN '18-24'
           WHEN age>=25 AND age<=34 THEN '25-34'
		   WHEN age>=35 AND age<=44 THEN '35-44'
		   WHEN age>=45 AND age<=54 THEN '45- 54'
		   WHEN age>=55 AND age<=64 THEN '55- 64'
           ELSE '65+'
           END AS 'age_group',
           COUNT(*) AS count
           FROM hr
           GROUP BY 1;
           
-- 4 How many employees work at HQ vs remote

SELECT location, COUNT(*) AS employees_count
   FROM hr
   WHERE termdate IS NULL
   GROUP BY 1;
   
-- 5 What is avg length of employment who have been terminated
	SELECT ROUND(avg(year(termdate)-year(hire_date)),0)
           AS length_of_employment
           FROM hr
           WHERE termdate IS NOT NULL AND termdate<= curdate();
           
-- 6 How does the gender distribution vary across dept and job titles
SELECT department,jobtitle,gender,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY 1,2,3
ORDER BY 1,2,3;

-- 7 What is the ditribution of jobtitles across the company
SELECT jobtitle,COUNT(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY 1;

-- 8 Which dept has the higher turnover/termination rate

SELECT * FROM hr;

SELECT department,
       COUNT(*) AS count,
       COUNT(CASE
                 WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
                 END) AS terminated_count,
	   ROUND((COUNT(CASE 
                 WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
                 END)/COUNT(*))*100,2) AS termination_rate
		FROM hr
        GROUP BY department
        ORDER BY 4 DESC;
        
-- 9. What is the distribution of employees across location_state

SELECT location_state,COUNT(*) AS employee_count
FROM hr
WHERE termdate IS NULL
GROUP BY 1;
 
-- 10 How has the company employee count changed over time based on hire and termination date

SELECT * FROM hr;
SELECT year,
       hires,
       terminations,
       hires-terminations AS net_change,
       (terminations/hires)*100 AS change_percent
        FROM
        (
           SELECT YEAR(hire_date) AS year,
		   COUNT(*) AS hires,
           SUM(CASE
                   WHEN termdate IS NOT NULL AND termdate<= curdate() THEN 1
                END)AS terminations
		   FROM hr
		    GROUP BY YEAR(hire_date)) AS sub
GROUP BY year
ORDER BY year;

-- 11 What is the tenure distribution for each dept

SELECT department,round(avg(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate()
GROUP BY 1;            

      