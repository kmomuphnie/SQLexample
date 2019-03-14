-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;
create table q5(
        countryName varchar(50),
        year int,
        participationRatio real
);

--find the participation ratios of all election in every countries from 2001 to 2016
CREATE VIEW allPRatios AS
	SELECT election.country_id, country.name AS countryName, 
			EXTRACT(YEAR FROM e_date) AS year,
			CAST(votes_cast AS FLOAT)/electorate AS participationRatio
	FROM election JOIN country ON election.country_id = country.id
	WHERE EXTRACT(YEAR FROM e_date) >= 2001 AND
			EXTRACT(YEAR FROM e_date) <=2016
	GROUP BY election.country_id, election.id, country.name;

--in case in some year, some countries have more than one election
CREATE VIEW avgPRatios AS
	SELECT country_id, countryName, AVG(CAST(participationRatio AS FLOAT)) AS participationRatio, year
	FROM allPRatios
	GROUP BY allPRatios.country_id, allPRatios.year;

CREATE VIEW coutryInvalid AS
	SELECT A1.country_id, A1.countryName, A1.participationRatio, A1.year
	FROM avgPRatios A1 JOIN avgPRatios A2 ON A1.country_id = A2.country_id
	WHERE A1.year < A2.year AND
			A1.participationRatio > A2.participationRatio;

CREATE VIEW countryValid AS
	(SELECT country_id, countryName, participationRatio, year
		FROM avgPRatios)
	EXCEPT
	(SELECT country_id, countryName, participationRatio, year
		FROM coutryInvalid);

INSERT INTO q5
SELECT countryName, year, participationRatio
FROM countryValid;
