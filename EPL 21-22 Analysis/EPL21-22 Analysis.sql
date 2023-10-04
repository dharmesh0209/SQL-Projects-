-- EPL 21-22 Season Analysis.

-- Dataset Overview.
SELECT * FROM ptstable;
SELECT * FROM Results;
SELECT * FROM stats;

SELECT count(*) FROM ptstable;
SELECT count(*) FROM results;
SELECT count(*) FROM stats;

-- Points Table Analysis

-- 1) EPL 21-22 Champions.
SELECT Position,Team,Points FROM ptstable
WHERE position = 1;

-- 2) Teams Qualified for Champions League 22-23 Season.(Top 4)
SELECT Position,Team,Points FROM ptstable
WHERE position<=4;

-- 3) Teams Qualified for Europa League 22-23 Season.
SELECT position,Team,Points FROM ptstable
WHERE position IN (5,6);

-- 4) Teams Qualified for Europa Conference League 22-23 Season.
SELECT position,team,points FROM ptstable
WHERE position = 7;  

-- 5) Relegated Teams
SELECT position,team,points FROM ptstable
WHERE position IN (18,19,20);

-- 6) Team with Most Wins(Top 3)
SELECT position,team,Won,points FROM ptstable
ORDER BY 3 DESC LIMIT 3;

-- 7) Team with Most Loss(top 3)
SELECT position,team,Loss,points FROM ptstable
ORDER BY 3 DESC LIMIT 3;

-- 8) Team with Most Draws(top 3)
SELECT position,team,Draw,points FROM ptstable
ORDER BY 3 DESC LIMIT 3;

-- 9) Teams Win %, Loss % and Draw %
SELECT position,team,round(100*(won/played),2) AS "Win %",
Round(100*(Loss/played),2) AS "Loss %",
Round(100*(Draw/Played),2) AS "Draw %"
FROM ptstable ORDER BY 3 DESC;

-- 10) Points per Matches
SELECT team,round((Points/Played),2) AS "Pts per match" FROM ptstable
ORDER BY 2 DESC;

-- Results Analysis
SELECT * FROM results;

-- 1) Home win vs Away Wins By Team
WITH homecte AS (
SELECT Hometeam,Count(*) AS HomeWins FROM results WHERE HomeTeam=Winner 
GROUP BY 1 ),
awaycte AS (
SELECT AwayTeam,count(*) AS AwayWins FROM results WHERE AwayTeam=winner
GROUP BY 1)
SELECT HomeTeam AS Team,Homewins,AwayWins FROM homecte,awaycte
WHERE hometeam=awayTeam ORDER BY 2 DESC,3 DESC;

-- 2) Home Loss Vs Away Loss By Team
WITH homecte AS (
SELECT Hometeam,Count(*) AS HomeLoss FROM results WHERE HomeTeam<>Winner and Winner<>"Draw" 
GROUP BY 1 ),
awaycte AS (
SELECT AwayTeam,count(*) AS AwayLoss FROM results WHERE AwayTeam<>Winner and Winner<>"Draw"
GROUP BY 1)
SELECT AwayTeam AS Team,HomeLoss,AwayLoss FROM Homecte right join awaycte
on Hometeam=AwayTeam ORDER BY 2 DESC,3 DESC;

-- 3) Home Draw vs Away Draw By Team
WITH homecte AS (
SELECT Hometeam,Count(*) AS HomeDraws FROM results WHERE Winner="Draw" 
GROUP BY 1),
Awaycte AS (
SELECT AwayTeam,Count(*) AS AwayDraws FROM results WHERE Winner="Draw"
GROUP BY 1)
SELECT Hometeam AS Team,HomeDraws,AwayDraws FROM homecte,awaycte
WHERE HomeTeam=AwayTeam ORDER BY 2 DESC,3 DESC;

-- 4) Clean Sheets By Team (Home,AWay,Total)
with Homecte as (
select HomeTeam,Count(*) as HomeCS from results where (Winner=HomeTeam or Winner="Draw")and 
(CleanSheets="Yes" or Cleansheets="Both")  group by 1 order by 2 desc),
Awaycte as (
select AwayTeam,Count(*) as AwayCS from results where (Winner=AwayTeam or Winner="Draw")and 
(CleanSheets="Yes" or Cleansheets="Both")  group by 1 order by 2 desc)
select HomeTeam as Team,HomeCS,AwayCS,HomeCS+AwayCS as TotalCS from homecte,awaycte
where Hometeam=AwayTeam order by 4 desc;

-- 5) Wins by Year

SELECT winner AS Team,
SUM(CASE WHEN extract(year FROM date)='2021' AND winner=winner THEN 1 ELSE 0 END) AS "Wins in 2021",
sum(CASE WHEN extract(year FROM date)='2022' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in 2022"
FROM results where WInner<>"Draw" GROUP BY 1 ORDER BY 1;

-- 6) Wins by Month
-- Premier League Starts in August and ends in May
SELECT winner AS Team,
SUM(CASE WHEN extract(month FROM date)='8' AND winner=winner THEN 1 ELSE 0 END) AS "Wins in August",
SUM(CASE WHEN extract(month FROM date)='9' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in September",
SUM(CASE WHEN extract(month FROM date)='10' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in October",
SUM(CASE WHEN extract(month FROM date)='11' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in November",
SUM(CASE WHEN extract(month FROM date)='12' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in December",
SUM(CASE WHEN extract(month FROM date)='1' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in January",
SUM(CASE WHEN extract(month FROM date)='2' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in February",
SUM(CASE WHEN extract(month FROM date)='3' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in March",
SUM(CASE WHEN extract(month FROM date)='4' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in April",
SUM(CASE WHEN extract(month FROM date)='5' AND Winner=Winner THEN 1 ELSE 0 END) AS "Wins in May"
FROM results where Winner<>"Draw" GROUP BY 1 ORDER BY 1;

-- 7) Loss By Year
WITH Cte1 AS (
SELECT p.Team,r.Date,r.HomeTeam,r.AwayTeam,r.Winner FROM ptstable p, results r 
WHERE p.team=r.HomeTeam OR p.team=r.AwayTeam
ORDER BY 1)
SELECT Team,sum(CASE WHEN extract(Year FROM Date)='2021' AND (Winner<>Team AND Winner<>"Draw") THEN 1 ELSE 0 END ) AS "2021 Loss",
sum(Case when extract(Year FROM Date)='2022' AND (Winner<>Team AND Winner<>"Draw") THEN 1 ELSE 0 END) AS "2022 Loss"
FROM cte1 GROUP BY  1 ORDER BY 1 ;

-- 8) Matches Won by Winmargin>=3
select winner,count(*) as "WinMargin>=3" from results where WinMargin>=3
group by 1 order by 2 desc;

-- 9 ) Goals Scored Home Vs Away(%)
WITH Home AS (
SELECT HomeTeam,SUM(HtGoals) AS "HomeGoals" FROM results GROUP BY 1),
Away AS(
SELECT AwayTeam,SUM(AtGoals) as "AwayGoals" FROM results GROUP BY 1)
SELECT HomeTeam AS Team,HomeGoals,AwayGoals,Round(100*(HomeGoals/(HomeGoals+AwayGoals)),2) AS "Home Goals %",
Round(100*(AwayGoals/(HomeGoals+AwayGoals)),2) AS "Away Goals %"
FROM Home JOIN Away
ON HomeTeam=AwayTeam ORDER BY 1;

-- 10) Goals Conceded Home vs Away (%)
WITH Home AS (
SELECT HomeTeam,SUM(AtGoals) AS HGC FROM results GROUP BY 1),
Away AS(
SELECT AwayTeam,SUM(HtGoals) as AGC FROM results GROUP BY 1)
SELECT HomeTeam AS Team,HGC,AGC,Round(100*(HGC/(HGC+AGC)),2) AS "Home Goals Conceded %",
Round(100*(AGC/(HGC+AGC)),2) AS "Away Goals Conceded %"
FROM Home JOIN Away
ON HomeTeam=AwayTeam ORDER BY 1;

-- PLAYER ANALYSIS--
 SELECT * FROM stats;
 -- 1) Squad Size for Each Club
 SELECT Club,Count(*) AS "Squad Size" FROM stats GROUP BY 1 ORDER BY 2 DESC;
 
 -- 2) Average Squad Age by Club
SELECT Club,ROUND(AVG(Age),2) AS Average_Age FROM stats GROUP BY 1 ORDER BY 2 ;
 
 -- 3) TOP 5 Goalscorers in the League
 SELECT Player,Position,Appearances,Goals From stats ORDER BY 4 DESC LIMIT 5;
 
-- 4) Top Scorer for Each Team
WITH Goals AS (
SELECT Club,Player,Goals,RANK() OVER(PARTITION BY Club ORDER BY Goals DESC) AS rk
FROM stats)
SELECT Club,Player,Goals FROM GOALS WHERE rk=1;

-- 5) TOP 5 Highest Scoring Midfielders
SELECT Club,Player,Goals FROM stats WHERE Position="Midfielder"
ORDER BY 3 DESC LIMIT 5;

-- 6 ) Highest Goal Contribution(G+A) by CLub
WITH GOALS AS (
SELECT player,club,position,(Goals + Assists) AS "Goal_Contribution", 
RANK() OVER(PARTITION BY Club ORDER BY (Goals + Assists) DESC) as rk FROM stats)
SELECT player,club,position,Goal_Contribution FROM GOALS WHERE rk=1;

-- 7) Goals per 90 (Top 10)
SELECT player,club,round((Goals/minutes)*90,2) as Goals_per_90 FROM stats WHERE Minutes>=1300 ORDER BY 3 DESC LIMIT 10 ;

-- 8) Goals Contribution per 90 (top 10)
SELECT player,club,round(((Goals+Assists)/minutes)*90,2) as Goals_per_90 FROM stats where Minutes>=1300 ORDER BY 3 DESC LIMIT 10 ;


-- 9) Top 5 Highest Scoring Defenders
SELECT Club,Player,Goals FROM stats WHERE Position="Defender"
ORDER BY 3 DESC LIMIT 5;

-- 10) Total Penalties Awareded to each Club
SELECT Club,SUM(Penalties) as Penalties FROM stats GROUP BY 1 ORDER BY 2 DESC;

-- 11) Highest Penalty Taken for each club
SELECT s1.Player,s1.Club,s1.Penalties FROM stats s1
WHERE s1.penalties = (SELECT MAX(s2.penalties) from stats s2 where s1.club=s2.club ) 
order by 3 DESC; 

-- 12) Total Yellow and  Red Cards Received by Club
WITH Card AS(
SELECT Club,player,yellow_cards+red_cards AS "Cards", 
RANK() OVER(PARTITION BY club ORDER BY  (yellow_cards+red_cards) DESC) AS rk FROM stats) 
SELECT Club,Player,Cards FROM Card WHERE rk=1;

-- 13) Total Red cards by Club
SELECT club,SUM(red_cards) AS RedCards FROM stats GROUP BY 1 ORDER BY 2 DESC;
































































































































































































































































































































































