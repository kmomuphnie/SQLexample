-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3(
	countryName VARCHAR(50),
	partyName VARCHAR(100),
	partyFamily VARCHAR(50),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear DATE
);

-- find out the winner of each election of each country
CREATE VIEW partyWonElection AS
SELECT election_result.party_id AS party_id, party.country_id AS country_id,
	   election_result.election_id AS election_id
FROM election_result JOIN party ON election_result.party_id = party.id
WHERE election_result.votes = 
	(SELECT max(votes) AS highestVote
	 FROM election_result
	 GROUP BY election_id);

--find out how many times each party has won an election of each country
CREATE VIEW numOfTimesWon AS
SELECT party_id, country_id, count(election_id) AS numOfWon
FROM partyWonElection
GROUP BY party_id, country_id;

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

--find party family
CREATE VIEW wantedPartyInfo2 AS
SELECT w.party_id AS party_id, w.countryName AS countryName, p.family AS partyFamily
FROM wantedPartyInfo1 w JOIN party_family p ON w.party_id = p.party_id;

--find number of election won
CREATE VIEW wantedPartyInfo3 AS
SELECT w.party_id AS party_id, w.countryName AS countryName, w.partyFamily AS partyFamily, n.numOfWon AS wonElections
FROM wantedPartyInfo2 w JOIN numOfTimesWon n ON w.party_id = n.party_id;

--find most recently won election id and year
CREATE VIEW mostRecentlyWonElection AS
SELECT p.party_id AS party_id, p.election_id AS election_id, max(e.e_date) AS e_date
FROM partyWonElection p JOIN election e ON p.election_id = e.id
GROUP BY p.party_id, p.election_id;

--answer
CREATE VIEW answer AS
SELECT w.countryName AS countryName, w.partyFamily AS partyFamily, w.wonElections AS wonElections, m.election_id AS mostRecentlyWonElectionId, m.e_date AS mostRecentlyWonElectionYear
FROM wantedPartyInfo3 w JOIN mostRecentlyWonElection m ON w.party_id = m.party_id;

INSERT INTO q3
SELECT *
FROM answer;