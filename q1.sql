-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q1 CASCADE;
CREATE TABLE q1(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);


DROP VIEW IF EXISTS Inter_Pairs CASCADE;
DROP VIEW IF EXISTS Party_Pair CASCADE;
DROP VIEW IF EXISTS Country_Etimes CASCADE;
DROP VIEW IF EXISTS Pairs CASCADE;
DROP VIEW IF EXISTS Q1Answer CASCADE;
--store all allianced pairs
CREATE VIEW Inter_Pairs AS
	SELECT R1.election_id AS election_id, R1.party_id AS partyID1, R2.party_id AS partyID2
	FROM election_result R1, election_result R2
	WHERE R1.election_id = R2.election_id AND 
		  R1.party_id < R2.party_id AND
		  (R1.alliance_id = R2.id OR R1.id = R2.alliance_id OR R1.alliance_id = R2.alliance_id)
    ORDER BY R1.election_id;

--group the elections by country

CREATE VIEW Party_Pair AS
	SELECT election.country_id AS country_id, election_id, partyID1, partyID2
	FROM Inter_Pairs JOIN election ON Inter_Pairs.election_id = election.id;

--number of election happened in a country
CREATE VIEW Country_Etimes AS
	SELECT country_id, count(*) AS Etimes
	FROM election
	GROUP BY country_id;

CREATE VIEW Pairs AS
	SELECT country_id, partyID1, partyID2, count(distinct election_id) AS party_Etimes
	FROM Party_Pair
	GROUP BY country_id, partyID1, partyID2;



CREATE VIEW Q1Answer AS
	SELECT Country_Etimes.country_id, partyID1, partyID2
	FROM Pairs JOIN Country_Etimes on Pairs.country_id = Country_Etimes.country_id
	WHERE (CAST(Pairs.party_Etimes AS float) / Etimes) >= 0.3;


--add answer to q1
insert into q1
SELECT Q1Answer.country_id AS countryId, 
         Q1Answer.partyID1 AS alliedPartyId1, 
         Q1Answer.partyID2 AS alliedPartyId2
FROM Q1Answer;