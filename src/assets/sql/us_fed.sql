CREATE TABLE gh_2007_2019.us_fed (
    domain text NOT NULL,
    dept_agency text NOT NULL,
    CONSTRAINT us_fed_pkey PRIMARY KEY (domain)
);
ALTER TABLE gh_2007_2019.us_fed OWNER to ncses_oss;
