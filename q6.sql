-- Schema for storing a subset of the Parliaments and Governments database
--histogram of parties left/right position
SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;


CREATE TABLE q6(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

--find number of parties whose position is in each range for each country
CREATE VIEW partyRange02 AS
	SELECT party.country_id, COALESCE(count(*), 0) AS r0_2
	FROM party JOIN party_position ON party.id = party_position.party_id
	WHERE party_position.left_right >=0 AND party_position.left_right < 2
	GROUP BY party.country_id;

CREATE VIEW partyRange24 AS
	SELECT party.country_id, COALESCE(count(*), 0) AS r2_4
	FROM party JOIN party_position ON party.id = party_position.party_id
	WHERE party_position.left_right >=2 AND party_position.left_right < 4
	GROUP BY party.country_id;

CREATE VIEW partyRange46 AS
	SELECT party.country_id, COALESCE(count(*), 0) AS r4_6
	FROM party JOIN party_position ON party.id = party_position.party_id
	WHERE party_position.left_right >=4 AND party_position.left_right < 6
	GROUP BY party.country_id;

CREATE VIEW partyRange68 AS
	SELECT party.country_id, COALESCE(count(*), 0) AS r6_8
	FROM party JOIN party_position ON party.id = party_position.party_id
	WHERE party_position.left_right >=6 AND party_position.left_right < 8
	GROUP BY party.country_id;

CREATE VIEW partyRange810 AS
	SELECT party.country_id, COALESCE(count(*), 0) AS r8_10
	FROM party JOIN party_position ON party.id = party_position.party_id
	WHERE party_position.left_right >=8 AND party_position.left_right <= 10
	GROUP BY party.country_id;

CREATE VIEW partyRange AS
	SELECT partyRange02.country_id AS country_id, r0_2, r2_4,r4_6,r6_8,r8_10
	FROM partyRange02 NATURAL JOIN
	 	 partyRange24 NATURAL JOIN
	 	 partyRange46 NATURAL JOIN
	 	 partyRange68 NATURAL JOIN
	 	 partyRange810
	ORDER BY partyRange02.country_id;

CREATE VIEW q6answer AS
	SELECT country_id, country.name AS countryName, r0_2, r2_4,r4_6,r6_8,r8_10
	FROM partyRange JOIN country ON partyRange.country_id = country.id
	ORDER BY country_id;

INSERT INTO q6
SELECT countryName, r0_2, r2_4,r4_6,r6_8,r8_10
FROM q6answer
ORDER BY countryName;













