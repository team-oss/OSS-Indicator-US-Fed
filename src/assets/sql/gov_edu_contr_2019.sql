DROP MATERIALIZED VIEW IF EXISTS gh_2007_2019.gov_edu_contr_year;
CREATE MATERIALIZED VIEW gh_2007_2019.gov_edu_contr_year AS (
    WITH A AS (
        SELECT branch,
            id,
            UNNEST(authors_id) author,
            UNNEST(authors_email) email,
            additions,
            EXTRACT(year FROM committedat) AS year
        FROM gh_2007_2019.commits
        WHERE committedat >= '2009-01-01'
    ),
    B AS (
        SELECT branch,
            id,
            author,
            email,
            additions
        FROM A
        WHERE email ~ '.(gov|mil|edu)$'
    ),
    C AS (
        SELECT branch,
            id,
            COALESCE(author, email) author,
            substring(email, '(?<=@.*)\w+(?=\.(gov|mil|edu))') AS domain,
            additions
        FROM B
    ),
    D AS (
        SELECT dept_agency,
            B.*
        FROM gh_2007_2019.us_fed A
            JOIN C B ON A.domain = B.domain
    ),
    E AS (
        SELECT dept_agency,
            COUNT(DISTINCT branch) repos,
            COUNT(DISTINCT author) contributors,
            SUM(additions) additions
        FROM D
        GROUP BY dept_agency
    )
    SELECT *
    FROM E
    ORDER BY dept_agency
);
