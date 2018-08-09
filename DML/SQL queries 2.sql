USE [Spring_2018_Baseball]

/* Question 1 */
SELECT s.[lgID],s.[teamID],t.[name],format(AVG(s.salary),'C','en-us') as 'Average_Salary'
from [dbo].[Salaries] s, [dbo].[Teams] t
where s.[yearID]=2015
and s.teamID=t.teamID
group by s.lgID,s.teamID,t.name
order by s.lgID, s.teamID;


/* Question 2 */
SELECT s.[playerID], m.[nameGiven]+'('+ m.[nameFirst] + ')'+ m.[nameLast] as 'Name',
format (Avg(s.[salary]),'C','en-us') as 'Average_Salary'
 from [dbo].[Master] m,[dbo].[Salaries] s
WHERE  s.playerID = m.playerID
group by  s.playerID, M.playerID,M.nameGiven,M.nameFirst,M.nameLast
having avg(s.salary) > $400000 
order by s.[playerID];


/* Question 3 */
SELECT a.playerID , m.nameGiven + ' (' + m.nameFirst + ') ' + m.nameLast as 'Player_Name', 
a.teamID , t.name 
FROM dbo.Appearances a, dbo.Master m, teams t
WHERE a.yearID = '2010'
AND a.playerID IN (SELECT b.playerID FROM dbo.Appearances b WHERE b.yearID = '2015')
AND a.playerID = m.playerID
AND a.teamID = t.teamID
AND a.yearID=t.yearID
ORDER BY a.playerID;


/* Question 4 */
SELECT playerID , teamID  , yearID , FORMAT(salary, 'C','en-us') AS 'Salary' 
FROM dbo.Salaries
WHERE teamID = 'NYA' 
AND  salary > SOME (SELECT salary FROM dbo.Salaries WHERE teamID = 'NYA' AND  yearID = '2014')
ORDER BY yearID;

/* Question 5 */
SELECT s.lgID , t.name , FORMAT(MIN(s.salary), 'C', 'en-us') AS 'Minimum Salary',
FORMAT(AVG(s.salary), 'C', 'en-us') AS 'Average Salary', FORMAT(max(s.salary), 'C', 'en-us') AS 'Maximum Salary'
FROM Salaries s, Teams t
WHERE s.lgID = 'AL' 
AND s.yearID = 2015 
AND s.lgID = t.lgID 
AND s.teamID = t.teamID
GROUP BY  t.name, s.lgID;


/* Question 6 */
SELECT s.teamID ,FORMAT(AVG(s.salary), 'C', 'en-us') AS 'Average Salary'
FROM Salaries s
WHERE s.yearID = '2010'
GROUP BY s.teamID
HAVING AVG(s.salary) > (SELECT AVG(salary) FROM Salaries WHERE teamID = 'NYN' AND yearID = '2010');

/* Question 7 */

SELECT distinct m.nameLast + ', ' + m.nameFirst AS 'Player Name', t.name AS 'Team Name'
FROM dbo.Master m, dbo.Teams t, 
((SELECT playerID, teamID FROM Appearances WHERE yearID = '2010') AS a
INNER JOIN
(SELECT playerID, teamID FROM Appearances WHERE yearID = '2015') AS b
ON a.playerID = b.playerID 
AND a.teamID = b.teamID)
WHERE m.playerID = a.playerID
AND t.teamID = a.teamID
AND t.yearID IN ('2010', '2015');	

/* Question 8 */
SELECT DISTINCT m.nameLast + ', ' + m.nameFirst AS 'Player Name', t.name AS 'Team Name'
From dbo.Salaries s, dbo.Master m, dbo.Teams t
WHERE s.yearID = '2016'
AND s.salary > ALL (SELECT salary from dbo.Salaries WHERE yearID = '2013') 
AND s.playerID = m.playerID 
AND s.teamID = t.teamID
AND s.yearID = t.yearID
ORDER BY t.name;

/* Question 9 */
WITH Average_Salary AS (SELECT AVG(salary) as 'avg_salary', teamID FROM Salaries WHERE yearID = '2012' Group BY teamID) 

SELECT DISTINCT t.name AS 'Team Name', concat(m.nameLast , ', ' , m.nameFirst) AS 'Player Name',
FORMAT(s.salary,'C', 'en-us') AS 'Salary', FORMAT(s.salary - aSal.avg_salary, 'C', 'en-us') AS 'Difference'
FROM Salaries s, Master m, Teams t, Average_Salary aSal
WHERE s.yearID = '2012'
AND m.playerID = s.playerID 
AND t.teamID = s.teamID 
AND s.teamID = aSal.teamID
ORDER BY t.name, concat(m.nameLast , ', ' , m.nameFirst);
Go

/* Question 10 */
WITH WinPercent AS (SELECT (100.0 * SUM(W))/SUM(G) AS ManagerPercent, playerID, teamID FROM Managers GROUP BY playerID, teamID),
TeamPercent AS  (SELECT (100.0 * SUM(W))/SUM(G) AS TeamPercent, teamID FROM Teams GROUP BY teamID)

SELECT DISTINCT t.name AS 'Team Name',concat( m.nameLast , ', ' , m.nameFirst) AS 'Manager', 
LTRIM(STR(wp.ManagerPercent, 15, 2)) + '%' AS 'Manager Percent',
LTRIM(STR(tp.TeamPercent, 15, 2)) + '%' AS 'TeamPercent',
LTRIM(STR(wp.ManagerPercent - tp.TeamPercent, 15, 2)) + '%' AS 'Per_Difference'
FROM  Master m, Teams t, WinPercent wp,TeamPercent tp
WHERE m.playerID = wp.playerID 
AND wp.teamID = tp.teamID 
AND tp.teamID = t.teamID 
AND wp.ManagerPercent > tp.TeamPercent
ORDER BY t.name;
Go

/* Question 11 */
SELECT m.nameLast + ', ' + m.nameFirst AS 'Player', COUNT(DISTINCT a.teamID) AS '# Of Teams'
FROM Master m, Appearances a
WHERE m.playerID = a.playerID
GROUP By m.nameFirst, m.nameLast;
Go

/* Question 12 */
IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Master' AND COLUMN_NAME = 'SU83_Avg_Salary')
BEGIN ALTER TABLE Master
ADD SU83_Avg_Salary float END
GO

UPDATE Master
SET SU83_Avg_Salary = (SELECT SUM(salary) from Salaries s WHERE s.playerID = Master.playerID GROUP BY s.playerID) 
WHERE Master.playerID IN (SELECT sal.playerID FROM Salaries sal);

SELECT concat(m.nameLast , ', ' , m.nameFirst) AS 'Player name', FORMAT(m.SU83_Avg_Salary, 'C', 'en-us') AS 'Total Salary'
FROM Master m
WHERE m.SU83_Avg_Salary IS NOT NULL;
Go

/* Question 13 */
IF NOT EXISTS (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Salaries' AND COLUMN_NAME = 'SU83_401K')
BEGIN ALTER TABLE Salaries
ADD SU83_401K float END
GO

UPDATE Salaries
SET SU83_401K = 
(select CASE WHEN salary < 2000000 THEN (0.1 * salary)
     WHEN salary >= 2000000 THEN (0.05 * salary)
END);
					
SELECT s.playerID , s.yearID , 
FORMAT(s.salary, 'C', 'en-us') AS 'Salary', FORMAT(SU83_401K, 'C', 'en-us') AS 'Amount 401K'
FROM Salaries s
WHERE SU83_401K IS NOT NULL
ORDER BY s.yearID, s.playerID;
Go

/* Question 14 */
SELECT m.playerID AS 'playerID', concat( m.nameGiven , ' (' ,m.nameFirst ,') ' ,m.nameLast) AS 'Full Name',
CAST([birthMonth] AS VARCHAR(4)) + '/' + CAST([birthDay] AS VARCHAR(2)) + '/' + CAST([birthYear] AS VARCHAR(4)) AS 'Birth Day',
FORMAT(s.salary, 'C', 'en-us') AS 'NYA Salary'
FROM Salaries s, Master m
WHERE s.playerID = m.playerID 
AND s.teamID = 'NYA' 
AND s.yearID = '1990' 
AND s.salary > ANY (SELECT salary FROM Salaries WHERE teamID = 'BOS')
ORDER BY s.salary DESC;
Go

/* Question 15 */
SELECT m.playerID ,concat( m.nameFirst , ' ' , m.nameLast) AS 'Player Name', m.birthYear ,
h.yearID , h.category ,
CAST([birthMonth] AS VARCHAR(4)) + '-' + CAST([birthDay] AS VARCHAR(2)) + '-' + CAST([birthYear] AS VARCHAR(4)) AS 'calcdate',
CAST(07 AS VARCHAR(2)) + '-' + CAST(07 AS VARCHAR(2)) + '-' + CAST([yearID] AS VARCHAR(4)) AS 'inductdate',
DATEDIFF (day, CONVERT(datetime, CAST([birthMonth] AS VARCHAR(2)) + '-' + CAST([birthDay] AS VARCHAR(2)) + '-' + CAST([birthYear] AS VARCHAR(4))), 
	           CONVERT(datetime, CAST(07 AS VARCHAR(2)) + '-' + CAST(07 AS VARCHAR(2)) + '-' + CAST([yearID] AS VARCHAR(4))))/365 AS 'age'
FROM Master m, HallOfFame h
WHERE h.playerID = m.playerID 
AND h.inducted = 'Y';
Go

