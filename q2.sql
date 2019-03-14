-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;

DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2(
	countryName VARCHAR(50),
	partyName VARCHAR(100),
	partyFamily VARCHAR(50),
	stateMarket REAL
);

DROP TABLE IF EXISTS numOfCabinet4EachCountry CASCADE;
DROP TABLE IF EXISTS numOfCarbinet4EachParty CASCADE;
DROP TABLE IF EXISTS partyInfo CASCADE;
DROP TABLE IF EXISTS Q2Answer CASCADE;

--find out how many cabinets created in each country for the past 20 years

CREATE VIEW numOfCabinet4EachCountry AS
	SELECT cabinet.country_id, country.name AS countryName, COUNT(DISTINCT cabinet.id) AS numOfCabinet
	FROM country JOIN cabinet on country.id = cabinet.country_id
	WHERE cabinet.start_date >= '1996-01-01' AND
	      cabinet.start_date < '2017-01-01'
	GROUP BY country.id;

--find out how many cabinets a party has been joined for the past 20 years
CREATE VIEW numOfCarbinet4EachParty AS
	SELECT cabinet_party.party_id, COUNT(cabinet.id) AS partyCabinetTimes
	FROM cabinet_party JOIN cabinet on cabinet_party.cabinet_id = cabinet.id
	WHERE cabinet.start_date >= '1996-01-01' AND
	  cabinet.start_date < '2017-01-01' 
	GROUP BY cabinet_party.party_id, cabinet.country_id;

-- find the wanted infomation of all parties
CREATE VIEW partyInfo AS
	SELECT party_position.party_id, family AS partyFamily, state_market AS stateMarket
	FROM party_family NATURAL LEFT JOIN party_position;


--Answer
CREATE VIEW q2Answer AS
	SELECT numOfCabinet4EachCountry.countryName, party.name AS partyName, partyFamily, stateMarket
	FROM numOfCabinet4EachCountry, numOfCarbinet4EachParty, partyInfo, party, country
	WHERE numOfCarbinet4EachParty.partyCabinetTimes = numOfCabinet4EachCountry.numOfCabinet AND
	  		numOfCarbinet4EachParty.party_id = partyInfo.party_id AND
	  		numOfCarbinet4EachParty.party_id = party.id AND
	  		numOfCarbinet4EachParty.country_id = country.id;


insert into q2
SELECT countryName, partyName, partyFamily, stateMarket
FROM q2Answer;
