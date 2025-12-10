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