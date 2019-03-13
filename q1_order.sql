--Question 1, report the pair of parties that have solid alliance
SET SEARCH_PATH TO parlgov;

SELECT * from q7 
ORDER BY countryid DESC, 
		 alliedpartyid1 DESC, 
		 alliedpartyid2 DESC;