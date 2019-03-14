
-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;

SELECT *
FROM q2
ORDER BY countryName,
		 partyName,
		 stateMarket DESC;