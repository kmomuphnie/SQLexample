-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;

CREATE TABLE q1(
	countryName VARCHAR(50) NOT NULL,
	partyName name VARCHAR(100) NOT NULL,
	partyFamily VARCHAR(50) NOT NULL,
	stateMarket REAL CHECK(state_market >= 0.0 AND state_market <= 10.0)
);

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
SELECT party_id, COUNT(cabinet.id) AS numOfCabinet
FROM cabinet_party, cabinet
WHERE cabinet.start_date >= '1996-01-01' AND
	  cabinet.start_date < '2017-01-01' AND
	  cabinet_party.cabinet_id = cabinet.id
GROUP BY party_id;

-- find the wanted infomation of all parties
CREATE VIEW partyInfo AS
SELECT party_id, family AS partyFamily, state_market AS stateMarket
FROM party_family, party_position on party_family.party_id = party_position.party_id;

--Answer
insert into q2
SELECT countryName,
	   party.name AS partyName,
	   partyFamily,
	   stateMarket
FROM numOfCabinet4EachCountry, numOfCarbinet4EachParty, partyInfo, party
WHERE numOfCabinet4EachCountry.numOfCabinet = numOfCarbinet4EachParty.numOfCabinet AND
	  numOfCarbinet4EachParty.party_id = partyInfo.party_id AND
	  numOfCarbinet4EachParty.party_id = party.id;