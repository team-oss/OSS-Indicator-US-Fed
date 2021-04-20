DROP MATERIALIZED VIEW IF EXISTS gh_2007_2019.baseline_msft_rht_decade;
CREATE MATERIALIZED VIEW gh_2007_2019.baseline_msft_rht_decade AS (
    WITH A AS (
        SELECT slug,
            substring(domain, '[^\.]+\.[^\.]+$') AS domain,
            contributors,
            additions
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
            COUNT(DISTINCT slug) repos,
            SUM(additions) additions
        FROM A
            JOIN B ON A.domain = B.domain
        GROUP BY sector,
            institution
    ),
    D AS (
        SELECT DISTINCT sector,
            institution,
            UNNEST(contributors) contributors
        FROM A
            JOIN B ON A.domain = B.domain
    ),
    E AS (
        SELECT sector,
            institution,
            COUNT(*) contributors
        FROM D
        GROUP BY sector,
            institution
    ),
    F AS (
        SELECT A.sector,
            A.institution,
            repos,
            B.contributors,
            additions
        FROM C A
            JOIN E B ON A.sector = B.sector
            AND A.institution = B.institution
    )
    SELECT *
    FROM F
    ORDER BY sector,
        institution
);
