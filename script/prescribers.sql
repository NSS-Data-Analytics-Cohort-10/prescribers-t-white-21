-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
	
--a: npi-1881634483	claim_count-99707
	
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;
	
--a: BRUCE PENDLEY, FAMILY PRACTICE, 99707

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT specialty_description, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
INNER JOIN prescription
	USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;

--a: FAMILY PRACTICE

--     b. Which specialty had the most total number of claims for opioids?

SELECT specialty_description, SUM(total_claim_count) AS claim_count_sum
FROM prescriber
LEFT JOIN prescription
	USING (npi)
LEFT JOIN drug
	USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC
LIMIT 10;

--a: Nurse Practioner

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT specialty_description, COUNT(drug_name)
FROM prescriber
full JOIN prescription
	USING (npi)
GROUP BY specialty_description
ORDER BY COUNT(drug_name)


--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT generic_name, 
	CAST (SUM(total_drug_cost) AS money)
FROM prescription
LEFT JOIN drug
	USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC
LIMIT 25;

--a: INSULIN GLARGINE,HUM.REC.ANLOG

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT generic_name, 
	ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS daily_cost
FROM prescription
LEFT JOIN drug
	USING (drug_name)
GROUP BY generiC_name
ORDER BY daily_cost DESC;

--a: "C1 ESTERASE INHIBITOR"


-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT drug_name, 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither' END AS drug_type
FROM drug;


--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT  
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
	END AS drug_type,
	CAST (SUM(total_drug_cost) AS money)
FROM drug
LEFT JOIN prescription
USING (drug_name)
WHERE 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
	END <>'neither'
GROUP BY 
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
	END;

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT DISTINCT (cbsaname)
FROM CBSA
WHERE cbsaname LIKE '%TN%';

--a: 10

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname, SUM(population) AS total_pop
FROM cbsa
LEFT JOIN zip_fips
	USING (fipscounty)
LEFT JOIN population
	USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY total_pop DESC;

--a: largest combined: "Memphis, TN-MS-AR"	67870189
	-- smallest combined: "Morristown, TN"	1163520

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT county, state, population
FROM cbsa
FULL JOIN fips_county
	USING (fipscounty)
LEFT JOIN population
	USING (fipscounty)
WHERE cbsa IS NULL
	AND population IS NOT NULL
ORDER BY population DESC;

--a: Sevier

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, 
	SUM(total_claim_count) AS total_claims
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY total_claims DESC;

--a: 7 total

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, 
	SUM(total_claim_count) AS total_claims,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'YES'
		ELSE 'NO' END AS opioid
FROM prescription
LEFT JOIN drug
	USING (drug_name)
WHERE total_claim_count >= 3000
GROUP BY drug_name, opioid_drug_flag
ORDER BY total_claims DESC;

--a: 7 total, 2 opiods. LEVEOTHYROXINE SODIUM @ #1

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name, 
	SUM(total_claim_count) AS total_claims,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'YES'
		ELSE 'NO' END AS opioid,
	nppes_provider_first_name,
	nppes_provider_last_org_name
FROM prescription
LEFT JOIN drug
	USING (drug_name)
LEFT JOIN prescriber
	USING (npi)
WHERE total_claim_count >= 3000
GROUP BY drug_name, opioid_drug_flag, nppes_provider_first_name,
	nppes_provider_last_org_name
ORDER BY total_claims DESC;

--a: 9 total (3 prescribers of LEVOTHYROXINE SODIUM). OXY @ #1

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT npi, drug_name
FROM prescriber AS ps
CROSS JOIN drug
WHERE ps.specialty_description = 'Pain Management'
	AND ps.nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y';


--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count

SELECT ps.npi, drug.drug_name, rx.total_claim_count
FROM prescriber ps 
CROSS JOIN drug
LEFT JOIN prescription rx	
	ON ps.npi=rx.npi
 	AND drug.drug_name=rx.drug_name
WHERE ps.specialty_description = 'Pain Management'
	AND ps.nppes_provider_city = 'NASHVILLE'
	AND drug.opioId_drug_flag = 'Y';
	
-- --     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT ps.npi, 
	drug.drug_name, 
	COALESCE(rx.total_claim_count, 0) AS total_claims
FROM prescriber ps 
CROSS JOIN drug
LEFT JOIN prescription rx	
	ON ps.npi=rx.npi
 	AND drug.drug_name=rx.drug_name
WHERE ps.specialty_description = 'Pain Management'
	AND ps.nppes_provider_city = 'NASHVILLE'
	AND drug.opioId_drug_flag = 'Y';
	

