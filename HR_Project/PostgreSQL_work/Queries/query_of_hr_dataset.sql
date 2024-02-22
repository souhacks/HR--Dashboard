SELECT * FROM hr_details;

-- adding a new column age to dataset:
ALTER TABLE hr_details ADD COLUMN age INT;
UPDATE hr_details
SET age = EXTRACT(YEAR FROM AGE(current_date, birthdate));

SELECT birthdate, age FROM hr_details;

SELECT MIN(age) as youngest, MAX(age) as oldest FROM hr_details;

-- check age which are less than 0
SELECT COUNT(*) FROM hr_details WHERE age<18;

-- QUESTIONS:
-- 1. What is the gender breakdown of employess in the company?
SELECT GENDER, COUNT(*) AS count 
FROM hr_details 
WHERE age>=18 AND termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT * FROM hr_details;

SELECT race, COUNT(*) AS count FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY race 
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT * FROM hr_details;
--check the minimum and maximum age :
SELECT MIN(age) as youngest, 
MAX(age) as oldest FROM hr_details
WHERE age>=18 AND termdate IS NULL;

-- making age distribution:
SELECT
CASE
  WHEN age>=18 AND age<=24 THEN '18-24'
  WHEN age>=25 AND age<=34 THEN '25-34'
  WHEN age>=35 AND age<=44 THEN '35-44'
  WHEN age>=45 AND age<=54 THEN '45-54'
  WHEN age>=55 AND age<=64 THEN '55-64'
  ELSE '65+'
END AS age_group , COUNT(*) AS count
FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

-- How the gender distributed in different age_group:
SELECT
CASE
  WHEN age>=18 AND age<=24 THEN '18-24'
  WHEN age>=25 AND age<=34 THEN '25-34'
  WHEN age>=35 AND age<=44 THEN '35-44'
  WHEN age>=45 AND age<=54 THEN '45-54'
  WHEN age>=55 AND age<=64 THEN '55-64'
  ELSE '65+'
END AS age_group, gender, 
COUNT(*) AS count
FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group;

-- 4. How many employees work at headquarters versus remote location?
SELECT * FROM hr_details;

SELECT location, COUNT(*) AS count
FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment who have been terminated?
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM AGE(termdate, hire_date)) / (60 * 60 * 24 * 365))::numeric, 1) AS avg_length_employment
FROM 
    hr_details
WHERE 
    termdate <= CURRENT_DATE AND termdate IS NOT NULL AND age > 18;
	
-- 6. How does the gender distribution vary across departments and job titles?
SELECT * FROM hr_details;

SELECT department, jobtitle, gender, COUNT(*) AS count
FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*)
FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT * FROM hr_details;

SELECT department,
total_count,
terminated_count, 
round(terminated_count:: numeric/total_count, 1) AS termination_rate
FROM (
SELECT department, 
COUNT(*) AS total_count,
SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE 
    THEN 1 ELSE 0 END) AS terminated_count
FROM hr_details
WHERE age>=18
GROUP BY department) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across the locations by state?
SELECT * FROM hr_details;

SELECT location, location_state, COUNT(*) AS count
FROM hr_details
WHERE age>=18 AND termdate IS NULL
GROUP BY location_state, location
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on 
--     hire and term dates?
SELECT * FROM hr_details;

SELECT 
    year, 
    terminations,
    hires - terminations AS net_change,
    ROUND((hires - terminations) / hires::numeric * 100, 2) AS net_change_percent
FROM (
    SELECT 
        EXTRACT(YEAR FROM hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURRENT_DATE THEN 1 ELSE 0 END) AS terminations
    FROM 
        hr_details
    WHERE 
        age >= 18
    GROUP BY 
        EXTRACT(YEAR FROM hire_date)
) AS subquery
ORDER BY year ASC;
	
-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(EXTRACT(EPOCH FROM AGE(termdate, hire_date)) / (60 * 60 * 24 * 365)), 0) AS avg_tenure
FROM hr_details
WHERE termdate IS NOT NULL AND termdate <= CURRENT_DATE AND age>=18
GROUP BY department
ORDER BY avg_tenure DESC;