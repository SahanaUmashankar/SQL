Use [Spring_2018_Baseball];

/*1.Using the Salaries table, select playerid, yearid and salary. Remember to format the salary using the format command.*/

select s.[yearID],s.[playerID],FORMAT (s.salary, 'C', 'en-us') as 'salary'
from [dbo].[Salaries]s;

/*2.Modify the query in #1 so it also shows a monthly salary (salary divided by 12). Rename the derived column Monthly Salary*/

select s.[yearID],s.[playerID],
FORMAT (s.salary, 'C', 'en-us') as 'salary',
FORMAT (s.salary/12, 'C', 'en-us') as 'monthly salary'
from [dbo].[Salaries]s;

/*3.Provide a list of the teamids in the Salaries tables listing each team once.*/

select distinct([teamID]) from [dbo].[Salaries];

/*4.Select the Teamid, PlayerID and Salary from the Salaries table for all players with salaries over $1 million dollars.*/

select s.[teamID],s.[yearID],s.[playerID],FORMAT (s.salary, 'C', 'en-us') as 'salary'
from [dbo].[Salaries]s where salary > 100000.00;


/*5.Modify the query for #4 to show the same information for players on the New York Yankees. Hint: Use teamid NYA in your where statement*/

select s.[teamID] as teamID,s.[yearID],s.[playerID],FORMAT (s.salary, 'C', 'en-us') as 'salary'
from [dbo].[Salaries]s where salary > 100000.00 and teamID ='NYA'

/*6.Modify the query in #4 to show the players first and last name in addition to the information already shown. You will need to use the Master and Salaries tables with the correct join.*/

select s.[teamID],s.[yearID],s.[playerID],
m.[nameFirst],m.[nameLast],
FORMAT (s.salary, 'C', 'en-us') as 'salary'
from [dbo].[Salaries]s  inner join [dbo].[Master]m 
on s.[playerID]=m.[playerID] and salary > 100000.00;

/*7.Modify the query for #4 again, but this time show the FranchName from the teamsFranchise table instead of the teamid. For this query, you must use the Master, Salaries, Teams and TeamsFranchises with the appropriate joins*/

select tf.[franchName],s.[yearID],s.[playerID],FORMAT (s.salary, 'C', 'en-us') as 'salary'
from [dbo].[Salaries]s 
inner join [dbo].[Master]m 
on s.[playerID]=m.[playerID] 
inner join  [dbo].[Teams]t
on s.[yearID]=t.[yearID] and s.[lgID]=t.[lgID] and s.[teamID]=t.[teamID]
inner join [dbo].[TeamsFranchises]tf
on tf.[franchID] = t.[franchID]
 and salary > 100000.00;
 
 /*8.Using the MASTER table. List the first, last and given name for all players that use their initials as their first name (Hint: nameFirst contains at least 1 period(.) Also, concatenate the nameGiven, nameFirst and nameLast into a single column called Full Name putting the nameFirst in parenthesis. For example: James (Jim) Markulic*/

 SELECT nameFirst, nameLast, nameGiven, 
nameGiven + ' ( ' + nameFirst + ' ) ' + nameLast AS 'Full Name' 
FROM [dbo].[Master] WHERE nameFirst like '%.%';

/*9.Modify the query in #8 by adding the Salaries table and only show players who’s name does not contain a period (.) ad who played in 2000 and had a salary between $400,000 and $500,000. The salary in your results must be properly formatted showing dollars and cents. The results must also be sorted by Salary and then Last Name. You must use a BETWEEN clause in you with statement.*/

 SELECT m.nameFirst, m.nameLast, m.nameGiven, 
m.nameGiven + ' ( ' + m.nameFirst + ' ) ' + m.nameLast AS 'Full Name',
Format(s.salary,'C','en-us') as 'salary'
FROM [dbo].[Master]m ,[dbo].[Salaries]s 
WHERE m.[playerID]=s.[playerID] and nameFirst not like '%.%' and s.yearID=2000
and s.salary between $400000 and $500000
order by s.salary,m.nameLast;


 /*10.Using the appropriate Set Operator (slide 32) and the MASTER and APPEARANCES tables, list the player, full name (as shown in #8 & 9) and the teamid of players who were in the appearances table for 2000 but not for 2001. HINT: You need to create 2 separate queries (one to select the data for each year, and use the SET Operator to combine the data to get the correct results. You can also refer to the Relational Algebra Chapter for additional information regarding how the set operators work.*/


 (select a.[playerID],m.nameGiven + ' ( ' + m.nameFirst + ' ) ' + m.nameLast AS 'Full Name', t.[teamID]
 from [dbo].[Appearances]a, [dbo].[Master]m,[dbo].[Teams]t
 where a.[playerID]=m.[playerID] and a.[teamID]= t.[teamID]
  and a.yearID =2000)

  EXCEPT

   (select a.[playerID],m.nameGiven + ' ( ' + m.nameFirst + ' ) ' + m.nameLast AS 'Full Name', t.[teamID]
 from [dbo].[Appearances]a, [dbo].[Master]m,[dbo].[Teams]t
 where a.[playerID]=m.[playerID] and a.[teamID]= t.[teamID]
  and a.yearID =2001)

  /* 11.Modify the query in #10 to use the appropriate Set Operator to show players who are in the appearances table for 2000 and 2001*/

   (select a.[playerID],m.nameGiven + ' ( ' + m.nameFirst + ' ) ' + m.nameLast AS 'Full Name', t.[teamID]
 from [dbo].[Appearances]a, [dbo].[Master]m,[dbo].[Teams]t
 where a.[playerID]=m.[playerID] and a.[teamID]= t.[teamID]
  and a.yearID =2000)

INTERSECT

(select a.[playerID],m.nameGiven + ' ( ' + m.nameFirst + ' ) ' + m.nameLast AS 'Full Name', t.[teamID]
 from [dbo].[Appearances]a, [dbo].[Master]m,[dbo].[Teams]t
 where a.[playerID]=m.[playerID] and a.[teamID]= t.[teamID]
  and a.yearID =2001)

/*12.Write one query to calculate the averages salary in the Salaries table using the formula Average Salary = sum(salaries)/count(playerid) and a second query using the average aggregate function. Explain the difference in the results.*/

SELECT 
FORMAT(SUM(s.salary)/COUNT(s.playerID), 'C', 'en-us') AS 'Avg_Using_Divide',
FORMAT(AVG(s.salary), 'C', 'en-us') AS 'Aggregrate_Average'
FROM Salaries s;

/*13.Using the Salaries table and the appropriate aggregate function, calculate the average salary by teamid sorted by teamid*/

select FORMAT(AVG(s.salary), 'C', 'en-us') AS 'Average salary', s.[teamID]
FROM  [dbo].[Salaries]s
group by s.[teamID]
order by s.[teamID];

/*14.Using the Salaries table and the appropriate aggregate function, calculate the average salary by lgid and teamid sorted by lgid and teamid*/

select s.[lgID],s.[teamID],FORMAT(AVG(s.salary), 'C', 'en-us') AS 'Average salary'
FROM  [dbo].[Salaries]s
group by s.[lgID],s.[teamID]
order by s.[lgID],s.[teamID];

/*15.Using the Salaries table and the appropriate aggregate function, calculatethe average salary by lgid and teamid sorted by lgid and teamid for 2015*/

select s.[lgID],s.[teamID],FORMAT(AVG(s.salary), 'C', 'en-us') AS 'Average salary'
FROM  [dbo].[Salaries]s
where s.[yearID]=2015
group by s.[lgID],s.[teamID]
order by s.[lgID],s.[teamID];



