SELECT * 
FROM Project1..game_sales_data

--top 10 highest selling games
SELECT TOP 10 Name, Total_Shipped
FROM Project1..game_sales_data
ORDER BY 2 DESC

--Average sales by platform
SELECT Platform, AVG(Total_Shipped) as avg_sold
FROM Project1..game_sales_data
GROUP BY Platform
ORDER BY 1


--Developer with most games sold
SELECT Developer, SUM(Total_Shipped) AS num_sold
FROM Project1..game_sales_data
GROUP BY Developer
ORDER BY num_sold DESC

--Best selling game from each developer
SELECT Name, Developer, Total_Shipped as num_sold, 
RANK() OVER(PARTITION BY Developer ORDER BY Total_Shipped DESC) as num_sold 
FROM Project1..game_sales_data

--Best selling game from each publisher
SELECT Name, Publisher, Total_Shipped as num_sold, 
RANK() OVER(PARTITION BY Publisher ORDER BY Total_Shipped DESC) as num_sold 
FROM Project1..game_sales_data

--Best selling game each year
SELECT Name, Year,  Total_Shipped
FROM (
SELECT Name, Year, Total_Shipped,
	ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Total_Shipped DESC) AS RN
	FROM Project1..game_sales_data s
) s
WHERE RN = 1

--Highest user rated game from each year
SELECT Name, Year, ROUND(User_Score,2) , ROUND(Total_Shipped,2)
FROM (
SELECT Name, Year, User_Score, Total_Shipped,
	ROW_NUMBER() OVER (PARTITION BY Year ORDER BY User_Score DESC) AS RN
	FROM Project1..game_sales_data s
	WHERE User_Score IS NOT NULL
) s
WHERE RN = 1

--Highest critic rated game from each year
SELECT Name, Year, Critic_Score, Total_Shipped
FROM (
SELECT Name, Year, Critic_Score, Total_Shipped,
	ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Critic_Score DESC) AS RN
	FROM Project1..game_sales_data s
	WHERE Critic_Score IS NOT NULL
) s
WHERE RN = 1

--Best selling pokemon game
SELECT Name, Year, User_Score, Critic_Score, Total_Shipped
FROM Project1..game_sales_data
WHERE Name LIKE 'Pokemon%'
ORDER BY 4 DESC