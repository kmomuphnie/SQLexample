-- Schema for storing a subset of the Parliaments and Governments database
-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH to parlgov;

SELECT *
FROM q3
ORDER BY countryName,
		 wonElections,
		 partyName DESC;