-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;

CREATE TABLE q2(
	countryName VARCHAR(50),
	partyName VARCHAR(100),
	partyFamily VARCHAR(50) ,
	stateMarket REAL
);

--find out how many cabinets created in each country for the past 20 years
CREATE VIEW numOfCabinet4EachCountry AS
SELECT country.id, country.name, COUNT(cabinet.id) AS numOfCabinet
FROM country, cabinet
WHERE country.id = cabinet.country_id AND
	  cabinet.start_date >= '2012-01-01' AND
	  cabinet.start_date < '2017-01-01'
GROUP BY country.id, country.name;

--find out how many cabinets a party has been joined for the past 20 years
CREATE VIEW numOfCarbinet4EachParty AS
SELECT party_id, country_id, COUNT(cabinet.id) AS numOfCabinet
FROM cabinet_party, cabinet
WHERE cabinet.start_date >= '2012-01-01' AND
	  cabinet.start_date < '2017-01-01' AND
	  cabinet_party.cabinet_id = cabinet.id
GROUP BY party_id, country_id;

--find the wanted party id
CREATE VIEW wantedParty AS
SELECT n2.party_id
FROM numOfCabinet4EachCountry n1, numOfCarbinet4EachParty n2
WHERE n1.numOfCabinet = n2.numOfCabinet AND
	  n1.id = n2.country_id;

-- find the wanted infomation of all parties
CREATE VIEW partyInfo AS
SELECT party_position.party_id, family AS partyFamily, state_market AS stateMarket
FROM party_family FULL JOIN party_position ON party_family.party_id = party_position.party_id, wantedParty
WHERE wantedParty.party_id = party_position.party_id;

--find party name and country id
CREATE VIEW partyInfo2 AS
SELECT p2.name AS partyName,
	   partyFamily,
	   stateMarket,
	   p2.country_id
FROM partyInfo p1 JOIN party p2 ON p1.party_id = p2.id;

--find country name
CREATE VIEW partyInfo3 AS
SELECT c.name AS countryName, partyName, partyFamily, stateMarket	  
FROM partyInfo2 p JOIN country c ON p.country_id = c.id;

--Answer
INSERT INTO q2
SELECT *
FROM partyInfo3;
