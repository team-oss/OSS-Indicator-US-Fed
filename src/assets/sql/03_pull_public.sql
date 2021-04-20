WITH A AS (
	SELECT *
	FROM gh_2007_2019.us_fed_public_hed
	WHERE sector = 'Federal'
	OR institution = ANY('{MSFT,RHT,University of California-Berkeley}'::text[])
	UNION ALL
	SELECT *
	FROM gh_2007_2019.baseline_msft_rht
	ORDER BY sector, institution, year
)
SELECT sector, institution, year::int, repos::bigint, contributors::bigint, additions::bigint
FROM A
;
