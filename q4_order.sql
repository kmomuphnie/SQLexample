-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH TO parlgov; 

SELECT * 
FROM q4 
ORDER BY year DESC, countryName DESC, voteRange DESC, partyName DESC;