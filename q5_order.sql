-- Schema for storing a subset of the Parliaments and Governments database
SET SEARCH_PATH TO parlgov;
SELECT * 
FROM q5 
ORDER BY countryName DESC, year DESC;