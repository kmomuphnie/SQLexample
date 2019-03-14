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
SELECT election_id, max(votes) AS highestVote
FROM election_result
GROUP BY election_id;

--
-- find out the winner of each election of each country
CREATE VIEW partyWonElection AS
SELECT election_result.party_id, party.country_id,
	   MaxVote.election_id
FROM MaxVote, election_result, party
WHERE MaxVote.election_id = election_result.election_id AND 
	  election_result.party_id = party.id AND MaxVote.highestVote = election_result.votes;

--find out how many times each party has won an election of each country
CREATE VIEW numOfTimesWon AS
SELECT party_id, country_id, count(election_id) AS numOfWon
FROM partyWonElection
GROUP BY party_id, country_id;

-- --find the average number of winning elections of parties of the same country
-- CREATE VIEW avgWinningElection AS
-- SELECT party.country_id AS country_id, 
-- 	   (sum(numOfTimesWon.numOfWon)/count(party.id)) AS avg
-- FROM numOfTimesWon JOIN party ON numOfTimesWon.party_id = party.id
-- GROUP BY party.country_id;

--find the total number won
CREATE VIEW totalWon AS
SELECT country_id, sum(numOfWon) AS totalnumberwon
FROM numOfTimesWon
GROUP BY country_id;

--find the total party
CREATE VIEW totalParty4EachCountry AS
SELECT country_id, count(party.id) AS totalparty
FROM party
GROUP BY country_id;

--find the average number of winning elections of parties of the same country
CREATE VIEW avgWinningElection AS
SELECT totalParty4EachCountry.country_id, (totalnumberwon/totalparty) AS avg
FROM totalWon, totalParty4EachCountry
WHERE totalWon.country_id = totalParty4EachCountry.country_id;

--find the wanted party
CREATE VIEW wantedParty AS
SELECT numOfTimesWon.party_id AS party_id, numOfTimesWon.country_id AS country_id
FROM avgWinningElection JOIN numOfTimesWon on avgWinningElection.country_id = numOfTimesWon.country_id
WHERE numOfTimesWon.numOfWon > 3 * avgWinningElection.avg;

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
FROM wantedPartyInfo2 w LEFT JOIN party_family p ON w.party_id = p.party_id;

--find number of election won
CREATE VIEW wantedPartyInfo4 AS
SELECT w.party_id, countryName, partyName, partyFamily, n.numOfWon AS wonElections
FROM wantedPartyInfo3 w JOIN numOfTimesWon n ON w.party_id = n.party_id;

--find most recently won election id and year
CREATE VIEW mostRecentlyWonElectionYe AS
SELECT p.party_id, max(e.e_date) AS e_date
FROM partyWonElection p JOIN election e ON p.election_id = e.id
GROUP BY p.party_id;

-- CREATE VIEW mostRecentlyWonElection AS
-- SELECT p.party_id, m.e_date, e.id AS election_id
-- FROM mostRecentlyWonElectionYe m, election e, partyWonElection p
-- WHERE m.party_id = p.party_id AND p.country_id = e.country_id AND m.e_date = e.e_date;
CREATE VIEW mostRecentlyWonElection AS
SELECT DISTINCT p.party_id, m.e_date, e.id AS election_id
FROM (mostRecentlyWonElectionYe m NATURAL JOIN partyWonElection p) NATRUAL JOIN election e;

--answer
CREATE VIEW answer AS
SELECT countryName, partyName, partyFamily, wonElections, m.election_id AS mostRecentlyWonElectionId, EXTRACT(year FROM m.e_date) AS mostRecentlyWonElectionYear
FROM wantedPartyInfo4 w JOIN mostRecentlyWonElection m ON w.party_id = m.party_id;

INSERT INTO q3
SELECT *
FROM answer;