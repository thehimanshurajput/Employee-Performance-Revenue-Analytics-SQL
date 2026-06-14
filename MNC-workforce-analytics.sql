-- Ques 01 - How many employees does the company have?

SELECT 
    COUNT(*) AS total_employees
FROM
    employees;


-- Ques 02 - How many employees work in each country?

SELECT 
    locations.country, COUNT(*) AS total_employees
FROM
    employees
        JOIN
    locations ON employees.location_id = locations.location_id
GROUP BY locations.country
ORDER BY total_employees DESC;


-- Ques 03 - What is the gender distribution of employees?

SELECT 
    gender, COUNT(*) AS total_employees
FROM
    employees
GROUP BY gender
ORDER BY total_employees DESC;


-- Ques 04 - Who are the top 10 highest-paid employees?

SELECT 
    employee_id, first_name, last_name, annual_salary
FROM
    employees
ORDER BY annual_salary DESC
LIMIT 10;


-- Ques 05 - How many unique clients does the company serve?

SELECT 
    COUNT(DISTINCT client_account) AS total_clients
FROM
    clients;
    
    
-- Ques 06 - Which departments have the highest average salary?

SELECT 
    departments.department,
    ROUND(AVG(employees.annual_salary), 2) AS avg_salary
FROM
    employees
        JOIN
    departments ON employees.department_id = departments.department_id
GROUP BY departments.department
ORDER BY avg_salary DESC;


-- Ques 07 - Which countries generate the highest total revenue?

SELECT 
    locations.country,
    SUM(clients.revenue_in_millions) AS total_revenue
FROM
    employees
        JOIN
    locations ON employees.location_id = locations.location_id
        JOIN
    clients ON employees.client_id = clients.client_id
GROUP BY locations.country
ORDER BY total_revenue DESC;


-- Ques 08 - Which domains employ the most people?

SELECT 
    departments.domain, COUNT(*) AS total_employees
FROM
    employees
        JOIN
    departments ON employees.department_id = departments.department_id
GROUP BY departments.domain
ORDER BY total_employees DESC;


-- Ques 09 -  Which departments have an average salary above ₹15,00,000?

SELECT 
    departments.department,
    ROUND(AVG(employees.annual_salary), 2) AS avg_salary
FROM
    employees
        JOIN
    departments ON employees.department_id = departments.department_id
GROUP BY departments.department
HAVING AVG(employees.annual_salary) > 1500000
ORDER BY avg_salary DESC;


-- Ques 10 - Does employee experience influence salary?

SELECT 
    CASE
        WHEN total_experience < 3 THEN '0-3 Years'
        WHEN total_experience < 7 THEN '3-7 Years'
        WHEN total_experience < 12 THEN '7-12 Years'
        ELSE '12+ Years'
    END AS experience_group,
    ROUND(AVG(annual_salary), 2) AS avg_salary
FROM
    employees
GROUP BY experience_group
ORDER BY avg_salary;


-- Ques 11 - Find the Top 5 highest-paid employees in each country.

WITH ranked_employees AS
(
    SELECT
        employees.employee_id,
        employees.first_name,
        employees.last_name,
        locations.country,
        employees.annual_salary,
        ROW_NUMBER() OVER (
            PARTITION BY locations.country
            ORDER BY employees.annual_salary DESC
        ) AS salary_rank
    FROM employees
    JOIN locations
        ON employees.location_id = locations.location_id
)

SELECT
    employee_id,
    first_name,
    last_name,
    country,
    annual_salary,
    salary_rank
FROM ranked_employees
WHERE salary_rank <= 5
ORDER BY country, salary_rank;


-- Ques 12 - Find the highest revenue-generating employee in every department.

WITH ranked_revenue AS
(
    SELECT
        employees.employee_id,
        employees.first_name,
        employees.last_name,
        departments.department,
        clients.revenue_in_millions,
        RANK() OVER (
            PARTITION BY departments.department
            ORDER BY clients.revenue_in_millions DESC
        ) AS revenue_rank
    FROM employees
    JOIN departments
        ON employees.department_id = departments.department_id
    JOIN clients
        ON employees.client_id = clients.client_id
)

SELECT
    employee_id,
    first_name,
    last_name,
    department,
    revenue_in_millions
FROM ranked_revenue
WHERE revenue_rank = 1
ORDER BY department;


-- Ques 13 - Rank clients by total revenue contribution.

SELECT
    client_account,
    SUM(revenue_in_millions) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(revenue_in_millions) DESC
    ) AS revenue_rank
FROM clients
GROUP BY client_account;


-- Ques 14 - Find employees whose salary is above their department's average salary.

SELECT
    employee_id,
    first_name,
    last_name,
    annual_salary,
    department_id
FROM employees
WHERE annual_salary >
(
    SELECT AVG(annual_salary)
    FROM employees
    WHERE employees.department_id = employees.department_id
);


-- Ques 15 - Find the top-performing employee in every domain. 

WITH ranked_performance AS
(
    SELECT
        employees.employee_id,
        employees.first_name,
        employees.last_name,
        departments.domain,
        employees.performance_rating,
        RANK() OVER (
            PARTITION BY departments.domain
            ORDER BY employees.performance_rating DESC
        ) AS performance_rank
    FROM employees
    JOIN departments
        ON employees.department_id = departments.department_id
)

SELECT
    employee_id,
    first_name,
    last_name,
    domain,
    performance_rating
FROM ranked_performance
WHERE performance_rank = 1
ORDER BY domain;