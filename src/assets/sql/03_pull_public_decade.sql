WITH A AS (
	SELECT *
	FROM gh_2007_2019.us_fed_public_decade
	WHERE sector = 'Federal'
	OR institution = ANY('{MSFT,RHT,University of California-Berkeley}'::text[])
	UNION ALL
	SELECT *
	FROM gh_2007_2019.baseline_msft_rht_decade
	ORDER BY repos DESC, additions DESC
)
SELECT sector, institution, repos::bigint, contributors::bigint, additions::bigint
FROM A
;
