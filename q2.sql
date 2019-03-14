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

--find out how many cabinets created in each country for the past 20 years
CREATE VIEW numOfCabinet4EachCountry AS
SELECT country.id, country.name, COUNT(cabinet.id) AS numOfCabinet
FROM country, cabinet
WHERE country.id = cabinet.country_id AND
	  cabinet.start_date >= '1996-01-01' AND
	  cabinet.start_date < '2017-01-01'
GROUP BY country.id;

--find out how many cabinets a party has been joined for the past 20 years
CREATE VIEW numOfCarbinet4EachParty AS
SELECT cabinet_party.party_id, COUNT(cabinet.id) AS numOfCabinet
FROM cabinet_party, cabinet
WHERE cabinet.start_date >= '1996-01-01' AND
	  cabinet.start_date < '2017-01-01' AND
	  cabinet_party.cabinet_id = cabinet.id
GROUP BY cabinet_party.party_id;

-- find the wanted infomation of all parties
CREATE VIEW partyInfo AS
SELECT party_position.party_id, family AS partyFamily, state_market AS stateMarket
FROM party_family JOIN party_position on party_family.party_id = party_position.party_id;


--Answer
CREATE VIEW Q2Answer
SELECT countryName,
	   party.name AS partyName,
	   partyFamily,
	   stateMarket
FROM numOfCabinet4EachCountry, numOfCarbinet4EachParty, partyInfo, party
WHERE numOfCabinet4EachCountry.numOfCabinet = numOfCarbinet4EachParty.numOfCabinet AND
	  numOfCarbinet4EachParty.party_id = partyInfo.party_id AND
	  numOfCarbinet4EachParty.party_id = party.id;


insert into q2
SELECT countryName, partyName, partyFamily, stateMarket
FROM Q2Answer
