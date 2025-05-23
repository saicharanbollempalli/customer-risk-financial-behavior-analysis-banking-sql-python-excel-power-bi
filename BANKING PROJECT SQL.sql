CREATE DATABASE BANKING_CASE;
USE BANKING_CASE;
SELECT * FROM BANKING_PR;

-- 1. What is the average estimated income of customers by loyalty classification.
SELECT Loyalty_Classification,AVG(Estimated_Income) AS AVG_ES_INCOME FROM BANKING_PR GROUP BY Loyalty_Classification;
-- 2. How many customers own more than one type of bank account (checking, savings, foreign currency).
SELECT CLIENT_ID,NAME,AGE FROM BANKING_PR WHERE Checking_Accounts IS NOT NULL AND Saving_Accounts IS NOT NULL AND Foreign_Currency_Account IS NOT NULL;
-- 3. List the top 10 customers with the highest combined deposits (bank, savings, and foreign currency).
SELECT CLIENT_ID,NAME,AGE,Bank_Deposits + Saving_Accounts + Foreign_Currency_Account AS TOTAL_DEPOSITS FROM BANKING_PR ORDER BY TOTAL_DEPOSITS DESC LIMIT 10;
-- 4. What is the distribution of customers by risk weighting grouped by age brackets (e.g., <30, 30–50, >50)?
SELECT 
  CASE 
    WHEN AGE <30 THEN "BELOW_THIRTY" 
    WHEN AGE BETWEEN 30 AND 50 THEN "THIRTY_TO_FIFTY"
    ELSE "FIFTY_ABOVE" 
  END AS AGE_GROUP,
  ROUND(SUM(Credit_Card_Balance), 2) AS TOTAL_CC_BALANCE,
  ROUND(SUM(Bank_Loans), 2) AS TOTAL_BANK_LOANS
FROM BANKING_PR
GROUP BY AGE_GROUP;
SELECT ROUND(SUM(Credit_Card_Balance),2) AS TOTAL_CC_AMT,ROUND(SUM(Credit_Card_Balance),2) TT_CC_B,ROUND(SUM(BANK_LOANS),2) TT_B_LOANS,CASE 
WHEN AGE <30 THEN "BELOW_THIRTY" 
WHEN AGE BETWEEN 30 AND 50 THEN "THIRTY TO FIFTY"
ELSE "FIFTY_ABOVE" END AS AGE_GROUP FROM BANKING_PR GROUP BY AGE_GROUP;
-- 5. Which occupation groups show the highest average bank loan amounts and credit card balances.
SELECT Occupation,AVG(Bank_Loans) AS AVG_BNK_LOANS,AVG(Credit_Card_Balance) AS AVG_CC_BL FROM BANKING_PR GROUP BY OCCUPATION ORDER BY AVG_BNK_LOANS DESC,AVG_CC_BL DESC;
-- 6.How does the number of properties owned by customers influence their likelihood to maintain  higher-than-average income.
SELECT Properties_Owned,
       AVG(Estimated_Income) AS Avg_Income
FROM BANKING_PR
GROUP BY Properties_Owned
HAVING AVG(Estimated_Income) > (SELECT AVG(Estimated_Income) FROM BANKING_PR)
ORDER BY Avg_Income DESC;
-- 7. What percentage of high-risk customers hold multiple credit cards and have high outstanding balances. 
SELECT 
    COUNT(*) AS HighRisk_Customers,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) FROM BANKING_PR WHERE Risk_Weighting >= 4) * 100, 2
    ) AS Percentage_HighRisk_With_ManyCards
FROM BANKING_PR
WHERE Risk_Weighting >= 4
  AND Amount_of_Credit_Cards > 1
  AND Credit_Card_Balance > 5000;

-- 8. How do customer segments (Gold, Platinum, Jade, etc.) compare in terms of a calculated financial health score.
SELECT Loyalty_Classification, AVG(
        (
            (Bank_Deposits + Saving_Accounts + Foreign_Currency_Account +Superannuation_Savings) 
            - (Credit_Card_Balance + Bank_Loans)
        ) / NULLIF(Estimated_Income, 0)
    ) AS Avg_Financial_Health_Score FROM banking_pr GROUP BY Loyalty_Classification order by Avg_Financial_Health_Score;
