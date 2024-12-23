--Q1.  What range of years for baseball games played does the provided database cover? 1871-2016

--SELECT
	--MIN(YEARID) AS FIRST_YEAR,
	--MAX(YEARID) AS LASY_YEAR
--FROM TEAMS;

--Q2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played? Eddie Gaedel | Height: 43 | St. Louis Browns | 1 Game

--SELECT namefirst || ' ' || namelast AS name, 
 	 --  height, name AS team,
 	  -- g_all AS total_games
--FROM people INNER JOIN appearances USING (playerid)
		--	INNER JOIN teams USING (teamid,yearid)
--WHERE height = (SELECT MIN(height) FROM people);
   
--Q3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?

-- SELECT namefirst || ' ' || namelast AS player_name,
-- 		SUM(salary)::NUMERIC::MONEY AS total_salary
-- FROM people INNER JOIN salaries USING (playerid)
-- WHERE playerid IN (SELECT DISTINCT playerid
-- 					FROM collegeplaying INNER JOIN schools USING (schoolid)
-- 					WHERE schoolname  LIKE 'Vande%')
-- GROUP BY namefirst, namelast
-- ORDER BY total_salary DESC;


--Q4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

-- SELECT 
-- 	SUM(CASE WHEN pos = 'OF' THEN po END) AS outfield_putouts,
-- 		SUM(CASE WHEN pos IN ('SS', '1B', '2B', '3B') THEN po END) AS infield_putouts,
-- 		SUM(CASE WHEN pos IN ('P', 'C') THEN po END) AS battery_putouts
-- FROM fielding
-- WHERE yearid = 2016


--Q5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

-- WITH decades AS (SELECT CONCAT((yearid/10* 10)::TEXT, '''s') AS decade, *
-- 					FROM teams)

-- SELECT decade, ROUND(SUM(so)::NUMERIC/(SUM(g)/2),2) AS avg_strike_outs,
-- 				ROUND(SUM(hr)::NUMERIC/(SUM(g)/2),2) AS avg_home_runs
-- FROM decades
-- GROUP BY decade
-- ORDER BY decade


--Q6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


-- SELECT namefirst || ' ' || namelast AS playername,
-- 		ROUND((sb::NUMERIC/(sb+ cs)) * 100, 2) AS sb_success_pct
-- FROM batting INNER JOIN people USING (playerid)
-- WHERE yearid = 2016 AND (sb + cs) > 20
-- ORDER BY sb_success_pct DESC


--Q7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--MAX 116 -- MAX w/o Strike Season 83 (63 in strike year 1981)

-- SELECT MAX(w)
-- FROM teams
-- WHERE wswin = 'N'AND yearid BETWEEN 1970 AND 2016

-- SELECT MIN(w)
-- FROM teams
-- WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016 AND yearid <> 1981

-- SELECT *
-- FROM teams
-- WHERE wswin = 'Y' AND w = (SELECT MIN (w) FROM teams WHERE wswin = 'Y' AND yearid BETWEEN 1970 AND 2016)

--
-- 26.09% of the time the team with the most wins won also won the series 

-- WITH most_wins AS (SELECT yearid, MAX(w) AS most_wins
-- 					FROM teams 
-- 					WHERE yearid BETWEEN 1970 AND 2016
-- 					GROUP BY yearid)

-- SELECT ROUND(AVG(CASE WHEN w = most_wins THEN 1 ELSE 0 END)*100,2) AS ptc
-- FROM  most_wins INNER JOIN teams USING (yearid)
-- WHERE wswin = 'Y' 
			

--Q8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

-- (SELECT name, park_name, homegames.attendance/games AS avg_attendance, 'top_5' AS attendance_rank
-- FROM homegames INNER JOIN parks USING (park)
-- 				INNER JOIN teams ON homegames.year = teams.yearid AND homegames.team = teams.teamid
-- WHERE year = 2016 AND games >= 10
-- ORDER BY avg_attendance DESC
-- LIMIT 5)

-- UNION

-- (SELECT name, park_name, homegames.attendance/games AS avg_attendance, 'bottom_5' AS attendance_rank
-- FROM homegames INNER JOIN parks USING (park)
-- 				INNER JOIN teams ON homegames.year = teams.yearid AND homegames.team = teams.teamid
-- WHERE year = 2016 AND games >= 10
-- ORDER BY avg_attendance 
-- LIMIT 5)
-- ORDER BY avg_attendance DESC


--Q9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.

-- SELECT namefirst || ' ' || namelast AS manager_name, 
-- 	   name AS team_name, 
-- 	   lgid AS league_id,
-- 	   yearid
-- FROM people INNER JOIN awardsmanagers USING (playerid)
-- 			INNER JOIN managers USING(playerid,yearid,lgid)
-- 			INNER JOIN teams USING (teamid,yearid,lgid)
-- WHERE (playerid, awardid) IN (SELECT playerid, awardid
-- 					FROM awardsmanagers
-- 					WHERE awardid LIKE 'TSN%' AND lgid IN ('AL', 'NL')
-- 					GROUP BY playerid, awardid
-- 					HAVING COUNT(DISTINCT lgid) = 2)
-- 				ORDER BY yearid


--Q10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.

-- WITH total_hr AS (SELECT playerid, yearid, SUM(hr) AS total_hr
-- 					FROM batting
-- 					GROUP BY playerid, yearid),

-- max_hr AS (SELECT playerid, MAX(total_hr) AS max_hr
-- 			FROM total_hr
-- 			GROUP BY playerid
-- 			HAVING COUNT(yearid) >=10)

-- SELECT namefirst || ' ' || namelast AS player_name, max_hr
-- FROM max_hr INNER JOIN batting USING (playerid)
-- 			INNER JOIN people USING (playerid)
-- WHERE yearid = 2016 AND hr = max_hr AND hr > 0
-- ORDER BY max_hr DESC;








