-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;


create table q4(
	year INT,
	countryName VARCHAR(50),
	voteRange VARCHAR(20),
	partyName VARCHAR(100)
);

--get the short name of the party
CREATE VIEW  party1 AS
	SELECT party.id AS party_id, country_id, party.name_short AS partyName
	FROM party;

--get all elections in each country in each year
CREATE VIEW electionHistory AS
	SELECT EXTRACT(YEAR FROM election.e_date) AS year, country.id, country.name AS countryName,
			election.id AS election_id,
			(CASE WHEN election.votes_valid IS NULL
				 THEN (SELECT SUM(votes) FROM election_result
				 		WHERE election_result.election_id = election.id)
				 ELSE election.votes_valid
			 END) AS votesPool
	FROM election JOIN country ON country.id = election.country_id;

CREATE VIEW partyEHistory AS
	SELECT party1.party_id, country_id, partyName, election_result.election_id, election_result.votes AS party_votes
	FROM party1 JOIN election_result ON party1.party_id = election_result.party_id;

CREATE VIEW combinedInfo AS
	SELECT country_id,countryName, party_id, partyName, year, COALESCE(CAST (SUM(votes) AS FLOAT) / MAX(votesPool),0) AS votes_percentage
	FROM electionHistory JOIN partyEHistory ON electionHistory.election_id = partyEHistory.election_id
	WHERE electionHistory.year >= 1996 AND
			electionHistory.year < 2017
	GROUP BY electionHistory.election_id, country_id, party_id, countryName, partyName;

--in case there are more than one election in a year we take the avg
CREATE VIEW avgInfo AS
	SELECT	countryName, year, country_id,party_id, COALESCE(AVG(votes_percentage),0) AS avg_percentage, partyName
	FROM combinedInfo
	GROUP BY year, countryName, country_id, party_id;

CREATE VIEW Q4Answer AS
	SELECT year, countryName, partyName,
			(CASE
				WHEN avgInfo.avg_percentage <= 0.05 THEN '(0-5]'
				WHEN avgInfo.avg_percentage > 0.05 AND avgInfo.avg_percentage <= 0.10 THEN '(5-10]'
				WHEN avgInfo.avg_percentage > 0.10 AND avgInfo.avg_percentage <= 0.20 THEN '(10-20]'
				WHEN avgInfo.avg_percentage > 0.20 AND avgInfo.avg_percentage <= 0.30 THEN '(20-30]'
				WHEN avgInfo.avg_percentage > 0.30 AND avgInfo.avg_percentage <= 0.40 THEN '(30-40]'
				WHEN avgInfo.avg_percentage > 0.40 THEN '(40-100]'
			 END) AS voteRange
	FROM avgInfo;

--only from 1996-2017
INSERT INTO q4
SELECT year, CountryName, voteRange, partyName
FROM  Q4Answer;



