DROP MATERIALIZED VIEW IF EXISTS gh_2007_2019.baseline_msft_rht;
CREATE MATERIALIZED VIEW gh_2007_2019.baseline_msft_rht AS (
    WITH A AS (
        SELECT slug,
            substring(domain, '[^\.]+\.[^\.]+$') AS domain,
            contributors,
            additions,
            year
        FROM gh_2007_2019.repo_domains
    ),
    B AS (
        SELECT 'Baseline' sector,
            UNNEST('{MSFT,RHT}'::text []) institution,
            UNNEST('{microsoft.com,redhat.com}'::text []) AS domain
    ),
    C AS (
        SELECT sector,
            institution,
            year,
            COUNT(DISTINCT slug) repos,
            SUM(additions) additions
        FROM A
            JOIN B ON A.domain = B.domain
        GROUP BY sector,
            institution,
            year
    ),
    D AS (
        SELECT DISTINCT sector,
            institution,
            year,
            UNNEST(contributors) contributors
        FROM A
            JOIN B ON A.domain = B.domain
    ),
    E AS (
        SELECT sector,
            institution,
            year,
            COUNT(*) contributors
        FROM D
        GROUP BY sector,
            institution,
            year
    ),
    F AS (
        SELECT A.sector,
            A.institution,
            A.year,
            repos,
            B.contributors,
            additions
        FROM C A
            JOIN E B ON A.sector = B.sector
            AND A.institution = B.institution
            AND A.year = B.year
    )
    SELECT *
    FROM F
    ORDER BY sector,
        institution,
        year
);
