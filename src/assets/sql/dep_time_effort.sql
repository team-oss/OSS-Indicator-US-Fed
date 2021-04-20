WITH A AS (
	SELECT dept_agency, COUNT(slug) repos, SUM(contributors) contributors, SUM(net) / 1000 kloc
	FROM gh_2007_2019.fed_repo_2019
	GROUP BY dept_agency
),
B AS (
	SELECT dept_agency, repos, contributors, (2.5 * ((2.4 * kloc)^1.05)^ 0.38 / 12) size_of_full_time_dev
	FROM A
	ORDER BY size_of_full_time_dev DESC
),
C AS (
	SELECT *
	FROM B
	WHERE size_of_full_time_dev > 0
)
SELECT SUM(size_of_full_time_dev)
FROM C
;
