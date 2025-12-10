# 📊 Data Analyst Job Market – SQL Project
## Purpose of the Project

The project aims to analyze the Data Analyst job market using SQL.
It focuses on understanding skill demand, salary trends, remote job availability, and how different skills influence pay.
The goal is to extract practical insights that help understand what the industry currently values.

### The questions I wanted to answer through my SQL queries were:
1. What are the top-paying data analyst jobs?

2. What skills are required for these top-paying jobs?

3. What skills are most in demand for data analysts?

4. Which skills are associated with higher salaries?

5. What are the most optimal skills to learn?

## Tools and Technologies Used

SQL Server

SQL Server Management Studio

Aggregate functions (COUNT, AVG)

Joins (INNER JOIN)

Grouping, ordering, filtering

Relational data analysis concepts

## Dataset Description

The project uses four related tables:

**1. job_postings_fact**

Contains job-level details like:

job titles

salary ranges

job type (remote/hybrid/on-site)

company ID reference

**2. skills_job_dim**

A bridge table connecting jobs to skills.
It allows many-to-many mapping between job_postings and skills.

**3. skills_dim**

The master list of all skills, including skill IDs and skill names.

**4. company_dim**

Contains company-specific information such as:

company names

These four tables together help analyze skills ↔ jobs ↔ companies ↔ salaries.

## The Analysis 
Each query in this project was designed to explore different angles of the data analyst job market. Here’s how each question was approached and what insights it revealed.

1. Top Paying Data Analyst Jobs
To find the highest-paying roles, I filtered for remote data analyst positions with available yearly salary data and sorted them by salary in descending order. This helped highlight where the strongest earning opportunities are.

Query 

```sql
SELECT TOP 10
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM
    job_postings_fact
LEFT JOIN 
    company_dim 
    ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_location = 'Anywhere' 
    AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC;
```
Summary:

Salaries span a wide range, showing strong growth potential in the field.

High-paying roles come from diverse companies and industries.

Job titles vary significantly, indicating many specialized paths within analytics.

2. Skills for Top Paying Jobs
To understand what skills are associated with the top salaries, I joined the highest-paying job postings with their required skills. This shows which technical abilities employers value most in premium roles.

Query 
```sql
WITH top_paying_jobs AS (
    SELECT TOP 10
        job_id,
        job_title,
        salary_year_avg,
        name AS company_name
    FROM
        job_postings_fact
    LEFT JOIN 
        company_dim 
        ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_title_short = 'Data Analyst' 
        AND job_location = 'Anywhere' 
        AND salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
)

SELECT 
    top_paying_jobs.*,
    skills_dim.skills AS skills
FROM 
    top_paying_jobs
INNER JOIN 
    skills_job_dim 
    ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN 
    skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    top_paying_jobs.salary_year_avg DESC;
```
Summary:

SQL and Python appear most frequently.

Tools like Tableau are also common across high-paying positions.

A mix of foundational and specialized skills is required.

3. In-Demand Skills for Data Analysts
This query identifies which skills appear most often across remote data analyst job postings, giving a clear picture of what’s currently in highest demand.

Query
```sql
SELECT TOP 5
    skills_dim.skills AS skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM 
    job_postings_fact
INNER JOIN 
    skills_job_dim 
    ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN 
    skills_dim 
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' 
    AND job_work_from_home = 1
GROUP BY
    skills_dim.skills
ORDER BY
    demand_count DESC;
```
Summary:

SQL and Excel remain essential core skills.

Python, Tableau, and Power BI show strong demand, emphasizing their importance in modern analytics.

4. Skills Based on Salary
By averaging salaries associated with each skill, this query reveals which technical competencies tend to bring higher earning potential.

Query 
```sql
SELECT 
    skills,
    ROUND(AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True 
GROUP BY
    skills
ORDER BY
    avg_salary DESC
LIMIT 25;
```
Summary:

Big data, machine learning, and Python-based tools are among the highest-paid skills.

Knowledge of development, automation, and cloud tools significantly boosts salary potential.

5. Most Optimal Skills to Learn
This query combines demand and salary to highlight skills that offer both strong hiring potential and high compensation — ideal targets for learning and career growth.

Query
```sql
WITH skills_demand AS (
    SELECT
        s.skill_id,
        s.skills AS skills,
        COUNT(sj.job_id) AS demand_count
    FROM 
        job_postings_fact AS j
    INNER JOIN 
        skills_job_dim AS sj 
        ON j.job_id = sj.job_id
    INNER JOIN 
        skills_dim AS s 
        ON sj.skill_id = s.skill_id
    WHERE
        j.job_title_short = 'Data Analyst'
        AND j.salary_year_avg IS NOT NULL
        AND j.job_work_from_home = 'True'  
    GROUP BY
        s.skill_id,
        s.skills
), 
average_salary AS (
    SELECT 
        sj.skill_id,
        ROUND(AVG(TRY_CAST(j.salary_year_avg AS FLOAT)), 0) AS avg_salary
    FROM 
        job_postings_fact AS j
    INNER JOIN 
        skills_job_dim AS sj  
        ON j.job_id = sj.job_id
    INNER JOIN 
        skills_dim AS s 
        ON sj.skill_id = s.skill_id
    WHERE
        j.job_title_short = 'Data Analyst'
        AND j.salary_year_avg IS NOT NULL
        AND j.job_work_from_home = 'True'    
    GROUP BY
        sj.skill_id
)
SELECT TOP 25
    sd.skill_id,
    sd.skills,
    sd.demand_count,
    a.avg_salary
FROM
    skills_demand AS sd
INNER JOIN  
    average_salary AS a 
    ON sd.skill_id = a.skill_id
WHERE  
    sd.demand_count > 10
ORDER BY
    a.avg_salary DESC,
    sd.demand_count DESC;
```


## Approach / Methodology

Performed INNER JOINs across all required tables

Filtered data for relevant roles (Data Analyst)

Used salary and remote filters when needed

Applied grouping to calculate demand counts

Used averaging to understand salary patterns

Ranked results to identify top skills and trends

Created individual SQL files for each analysis

## Insights & Findings

The most common skills aren’t always the highest paying

Specialized and advanced tools often lead to higher average salaries

Remote roles require more diverse and technical skills

Salary potential varies strongly based on the skill set

Companies hiring remote analysts focus on software-centric tools

Demand vs salary comparison shows market gaps that analysts can target

## Project Structure
📁 sql-queries/
   ├── skill_demand.sql
   ├── top_paying_skills.sql
   ├── salary_vs_demand.sql
   ├── remote_jobs_count.sql
   └── remote_skills_analysis.sql

📄Readme.md
