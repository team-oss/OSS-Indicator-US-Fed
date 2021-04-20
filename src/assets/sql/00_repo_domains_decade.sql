DROP MATERIALIZED VIEW IF EXISTS gh_2007_2019.repo_domains_decade CASCADE;
CREATE MATERIALIZED VIEW gh_2007_2019.repo_domains_decade AS (
	WITH A AS (
		SELECT branch,
			id,
			oid,
			committedat,
			authors_email,
			authors_name,
			authors_id,
			additions
		FROM gh_2007_2019.commits
		WHERE committedat >= '2009-01-01'::timestamp
	),
	B AS (
		SELECT branch, id,
			UNNEST(authors_id) gh_usr,
			UNNEST(authors_email) email,
			additions::real / ARRAY_LENGTH(authors_email, 1) additions
		FROM A
	),
	C AS (
		SELECT branch,
			id,
			gh_usr,
			email,
			CASE
				WHEN email ~ '.@users.noreply.github.com$'
				OR NOT email ~ '^[^@]+@[^@]+\.[^@]+$' THEN null
				ELSE substring(email, '(?<=@).*$')
			END AS domain,
			additions
		FROM B
	),
	D AS (
		SELECT branch,
			domain,
			ARRAY_AGG(distinct COALESCE(gh_usr, email)) contributors,
			SUM(additions) additions,
			COUNT(distinct id) commits
		FROM C
		GROUP BY branch,
			domain
	),
	E AS (
		SELECT slug,
			domain,
			contributors,
			A.commits,
			additions
		FROM D A
			JOIN gh_2007_2019.repos B ON A.branch = B.branch
	)
	SELECT *
	FROM E
);
