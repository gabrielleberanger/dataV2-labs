#Challenge 1 - What is the most successful district?

SELECT
	district_id,
	COUNT(DISTINCT(account_id)) AS ac_freq
FROM account
GROUP BY district_id
ORDER BY ac_freq DESC
LIMIT 5;

#Challenge 2 - How many people changed their place of residence?

SELECT
	account_id,
	GROUP_CONCAT(DISTINCT(bank_to)) AS all_bank_to,
	COUNT(amount) AS diff,
	GROUP_CONCAT(DISTINCT(amount)) AS rent
FROM ironhack4.order
WHERE k_symbol = 'SIPO'
GROUP BY account_id
HAVING diff>1;

#Challenge 3 - Best selling districts (V1)

	#Step 1 - Create table 'Single_Account_IDs'
	
CREATE TEMPORARY TABLE Single_Account_IDs
SELECT
	account.district_id,
	loan.amount,
	loan.account_id
FROM loan
LEFT JOIN account ON loan.account_id = account.account_id;

	#Step 2 - Create table 'Grouped_Account_IDs'
	
CREATE TEMPORARY TABLE Grouped_Account_IDs
SELECT
	account.district_id,
	MAX(loan.amount) AS max_loan_amount,
	GROUP_CONCAT(loan.account_id) AS grouped_account_ids
FROM loan
LEFT JOIN account ON loan.account_id = account.account_id
GROUP BY account.district_id;

	#Step 3 - Join tables
	
SELECT
	Grouped_Account_IDs.district_id,
	Grouped_Account_IDs.max_loan_amount,
	Single_Account_IDs.account_id
FROM Grouped_Account_IDs
INNER JOIN Single_Account_IDs
ON Grouped_Account_IDs.max_loan_amount = Single_Account_IDs.amount
ORDER BY max_loan_amount DESC;

#Challenge 4 - Best selling districts (V2)

SELECT
	account.district_id,
	SUM(loan.amount) AS total_amount
FROM loan
LEFT JOIN account ON loan.account_id = account.account_id
GROUP BY account.district_id
ORDER BY total_amount DESC;

#Challenge 5 - Best selling districts (V3)

	#Average amount

SELECT
	account.district_id,
	AVG(loan.amount) AS avg_amount
FROM loan
LEFT JOIN account ON loan.account_id = account.account_id
GROUP BY account.district_id
ORDER BY avg_amount DESC;

	#Median amount

#For each district, we calculate Q1 and Q3 on 2 separate tables. Then, we inner-join these tables on district_id, and calculate Q1+Q3/2.
#Temporary solution - Not working
SELECT
	DISTINCT district_id,
	(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount) OVER (PARTITION BY district_id)) AS median_per_district
FROM
	(SELECT account.district_id, loan.amount
	FROM loan
	LEFT JOIN account ON loan.account_id = account.account_id) AS Table
GROUP BY district_id;

#Bonus challenge

	#Step 1 - Create table 'Average_Salary'
	
CREATE TEMPORARY TABLE Average_Salary
SELECT
	A1 AS district_id,
	A11 AS avg_salary
FROM district;

	#Step 2 - Create table 'Loan'
	
CREATE TEMPORARY TABLE Loan
SELECT
	account.district_id,
	SUM(loan.amount) AS loan_amount
FROM loan
INNER JOIN account ON loan.account_id = account.account_id
GROUP BY account.district_id;

	#Step 3 - Create table 'Insurance'

CREATE TEMPORARY TABLE Insurance
SELECT
	DISTINCT account.district_id,
	SUM(trans.amount) AS insurance_amount
FROM trans
INNER JOIN account ON trans.account_id = account.account_id
WHERE trans.k_symbol = 'POJISTNE' AND trans.type = 'VYDAJ'
GROUP BY account.district_id;

	#Join tables

SELECT
	Average_Salary.district_id,
	Average_Salary.avg_salary,
	Loan.loan_amount,
	Insurance.insurance_amount	
FROM Average_Salary
INNER JOIN Loan ON Average_Salary.district_id = Loan.district_id
INNER JOIN Insurance ON Loan.district_id = Insurance.district_id
ORDER BY Average_Salary.avg_salary;
