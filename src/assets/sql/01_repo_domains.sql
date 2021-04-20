DROP MATERIALIZED VIEW IF EXISTS gh_2007_2019.repo_domains CASCADE;
CREATE MATERIALIZED VIEW gh_2007_2019.repo_domains AS (
	WITH A AS (
		SELECT branch,
			id,
			oid,
			committedat,
			authors_email,
			authors_name,
			authors_id,
			additions,
			extract(
				year
				from committedat
			) AS year
		FROM gh_2007_2019.commits
		WHERE committedat >= '2009-01-01'::timestamp
	),
	B AS (
		SELECT branch,
			UNNEST(authors_id) gh_usr,
			UNNEST(authors_email) email,
			additions::real / ARRAY_LENGTH(authors_email, 1) additions,
			year
		FROM A
	),
	C AS (
		SELECT branch,
			gh_usr,
			email,
			CASE
				WHEN email ~ '.@users.noreply.github.com$'
				OR NOT email ~ '^[^@]+@[^@]+\.[^@]+$' THEN null
				ELSE substring(email, '(?<=@).*$')
			END AS domain,
			additions,
			year
		FROM B
	),
	D AS (
		SELECT branch,
			domain,
			year,
			ARRAY_AGG(distinct coalesce(gh_usr, email)) contributors,
			SUM(additions) additions
		FROM C
		GROUP BY branch,
			domain,
			year
	),
	E AS (
		SELECT slug,
			domain,
			year,
			contributors,
			additions
		FROM D A
			JOIN gh_2007_2019.repos B ON A.branch = B.branch
	)
	SELECT *
	FROM E
);
