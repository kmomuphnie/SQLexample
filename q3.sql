-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3(
	countryName VARCHAR(50),
	partyName VARCHAR(100),
	partyFamily VARCHAR(50),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear INT
);

--find the highest vote in each election
CREATE VIEW MaxVote AS
SELECT election_id, party_id, max(votes) AS highestVote
FROM election_result
GROUP BY election_id, party_id;

--
-- find out the winner of each election of each country
CREATE VIEW partyWonElection AS
SELECT MaxVote.party_id, party.country_id,
	   MaxVote.election_id
FROM MaxVote JOIN party ON MaxVote.party_id = party.id;


--find out how many times each party has won an election of each country
CREATE VIEW numOfTimesWon AS
SELECT party_id, country_id, count(election_id) AS numOfWon
FROM partyWonElection
GROUP BY party_id;

--find the average number of winning elections of parties of the same country
CREATE VIEW avgWinningElection AS
SELECT party.country_id AS country_id, 
	   (sum(numOfTimesWon.numOfWon)/count(party.id)) AS avg
FROM numOfTimesWon JOIN party ON numOfTimesWon.party_id = party.id
GROUP BY party.country_id;

--find the wanted party
CREATE VIEW wantedParty AS
SELECT numOfTimesWon.party_id AS party_id, numOfTimesWon.country_id AS country_id
FROM avgWinningElection JOIN numOfTimesWon on avgWinningElection.country_id = numOfTimesWon.country_id
WHERE numOfTimesWon.numOfWon > avgWinningElection.avg;

--find country name
CREATE VIEW wantedPartyInfo1 AS
SELECT w.party_id AS party_id, c.name AS countryName
FROM wantedParty w JOIN country c ON w.country_id = c.id;

CREATE VIEW wantedPartyInfo2 AS
SELECT w.party_id, countryName, p.name AS partyName
FROM wantedPartyInfo1 w JOIN party p ON w.party_id = p.id;

--find party family
CREATE VIEW wantedPartyInfo3 AS
SELECT w.party_id, countryName, partyName, p.family AS partyFamily
FROM wantedPartyInfo2 w JOIN party_family p ON w.party_id = p.party_id;

--find number of election won
CREATE VIEW wantedPartyInfo4 AS
SELECT w.party_id, countryName, partyName, partyFamily, n.numOfWon AS wonElections
FROM wantedPartyInfo3 w JOIN numOfTimesWon n ON w.party_id = n.party_id;

--find most recently won election id and year
CREATE VIEW mostRecentlyWonElection AS
SELECT p.party_id AS party_id, p.election_id AS election_id, max(e.e_date) AS e_date
FROM partyWonElection p JOIN election e ON p.election_id = e.id
GROUP BY p.party_id;

--answer
CREATE VIEW answer AS
SELECT countryName, partyName, partyFamily, wonElections, m.election_id AS mostRecentlyWonElectionId, EXTRACT(year FROM m.e_date) AS mostRecentlyWonElectionYear
FROM wantedPartyInfo4 w JOIN mostRecentlyWonElection m ON w.party_id = m.party_id;

INSERT INTO q3
SELECT *
FROM answer;