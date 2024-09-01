--------------------------------------------------------------------------------
-- Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
Delete from Rating
where exists(
	select 1
	from Movie M
	where M.mID = Rating.mID
	and (year < 1970 or year > 2000) 
	and stars < 4
)

--------------------------------------------------------------------------------
-- For all movies that have an average rating of 4 stars or higher, add 25 to the release year.
with T as (
	select mID from Rating
	group by mID
	having avg(stars) >= 4
)

Update Movie
Set year = year+25
where mID in T

--------------------------------------------------------------------------------
-- SQL Movie-Rating Modification Exercises (Answers follow stack format)
-- Using the db "rating_modified.db" for these queries as it modifies the database
-- Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into Reviewer values(209, 'Roger Ebert')

--------------------------------------------------------------------------------
-- For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL.
with T as (
	select *, max(stars) as maxStars from Rating natural join Movie
	group by director
	having max(stars)
)

select director, title, maxStars from T
where director is not NULL
--------------------------------------------------------------------------------
-- Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
with T as (
	select *, avg(stars) as avgStars from Rating natural join Movie
	group by mID
)

select title, avgStars from T 

where avgStars in (select min(avgStars) from T)
--------------------------------------------------------------------------------
-- Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
select M.title, max(T.avgStars) as avgRating
from Movie M join (select *, avg(stars) as avgStars from Rating
group by mID) T on M.mID = T.mID

--------------------------------------------------------------------------------
-- Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.)
-- self join version:
select distinct M1.title, M1.director from Movie M1 join Movie M2 on M1.director = M2.director
where M1.mID <> M2.mID
order by M1.director, M1.title;
-- Extra challenge:
-- with count
select title, director
from Movie
where director in (select director from Movie
group by director
having count(mID) > 1)
order by director, title
-- without count
select M1.title, M1.director from Movie M1, Movie M2
where M1.director = M2.director and M1.title <> M2.title and M1.director is not NULL
order by M1.director, M1.title

--------------------------------------------------------------------------------
-- Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.)
-- One way:
  select rID, name
	from Rating natural join Reviewer
	group by rID
	having count(rID) >= 3
-- Alternate approach (self-join & natural join)(Extra challenge):
with T as (
  select * from Rating natural join Reviewer
)

select * 
from T T1 join T T2 join T T3 on T1.rID = T2.rID and T2.rID = T3.rID and T1.rID = T3.rID
where (T1.mID < T2.mID or T1.ratingDate < T2.ratingDate)
  and (T2.mID < T3.mID or T2.ratingDate < T3.ratingDate)
  and (T1.mID < T3.mID or T1.ratingDate < T3.ratingDate)

--------------------------------------------------------------------------------
-- List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order.
select title, avg(stars) as avgStars from Movie natural join Rating
group by mID
order by avgStars desc;

--------------------------------------------------------------------------------
-- For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars.
with T as (
	select min(stars) as minStars from Rating
)

select name, title, stars from T, Rating natural join Reviewer Re natural join Movie M
where stars = T.minStars;

--------------------------------------------------------------------------------
-- For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order.
-- Tags: Use of multiple CTEs
with 
	T1 as (
		select distinct rID, mID, name from Rating R natural join Reviewer Re
		),
	T2 as (
		select R1.rID as rID1, R2.rID as rID2, R2.mID, R1.name as name1, R2.name as name2 from T1 as R1, T1 as R2
		where R1.mID = R2.mID
	)

select distinct name1, name2 from T2
where name1 < name2
order by name1, name2;

--------------------------------------------------------------------------------
-- Find the titles of all movies not reviewed by Chris Jackson.
select title
from Movie
where mID not in (select mID from Reviewer natural join Rating natural join Movie
where name = "Chris Jackson");

--------------------------------------------------------------------------------
-- Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".)
with T as (
	select name, title from Reviewer natural join Movie
)

select name from T
union
select title from T;

--------------------------------------------------------------------------------
-- For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars.
select name, title, stars from Rating natural join Reviewer natural join Movie
where name = director;

--------------------------------------------------------------------------------
-- Find the names of all reviewers who rated Gone with the Wind.
select distinct name from Rating natural join Reviewer natural join Movie
where title = "Gone with the Wind";

--------------------------------------------------------------------------------
-- Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.)
-- The query I came up with
select abs(
  (select avg(avgStars)
	from (select year, avg(stars) as avgStars from Movie natural join Rating
	group by title) T
	where T.year > 1980) 
	- 
	(select avg(avgStars)
	from (select year, avg(stars) as avgStars from Movie natural join Rating
	group by title) T
	where T.year < 1980)
);

-- Simplified & Optimized with Common Table Expression (CTE)
with T as (
  select year, avg(stars) avgStars 
  from Movie natural join Rating
  group by mID
)

select abs (
	(select avg(avgStars) from T where year < 1980) - 
	(select avg(avgStars) from T where year > 1980)
);

-- Actual [varies in 10^-10 decimal value]
-- It differed 'cause the way rounding works in sql

--------------------------------------------------------------------------------
-- For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title.
select title, max(stars) - min(stars) as spread from Movie natural join Rating
group by mID
order by spread desc, title;
--------------------------------------------------------------------------------
-- For each movie that has at least one rating, find the highest number of stars that movie received. 
-- Return the movie title and number of stars. Sort by movie title.

-- Initial Thoughts: 
-- 2 instances of Ratings, based on mID if it has more than one review then collect those
-- Use these to compare the max stars for that particular Movie
-- Return title & stars, sort by title 

select  title, stars
from Movie M inner join Rating R using (mID)
where M.mID in (select mID from Rating R
group by R.mID
having max(stars))
group by M.mID having max(stars)
order by title ;

-- Better version:
select title, stars from Movie natural join Rating
group by mID 
having max(stars)
order by title;
--------------------------------------------------------------------------------
-- For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie.

-- Thoughts:
-- First try to get the movies with more than one review from the same reviewer
-- Then grab those when ratingDate is latest & rating is greater than it's counterpart :)

select name, title from Rating R1, Rating R2, Reviewer R, Movie M
where R1.rID = R2.rID and R1.mID = R2.mID and R1.stars > R2.stars and R1.ratingDate > R2.ratingDate 
				and R.rID = R1.rID  and R1.mID = M.mID;

--------------------------------------------------------------------------------
-- Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars.
select name, title, stars, ratingDate 
from Rating  as ra, Reviewer as re, Movie as M 
where ra.rID = re.rID and ra.mID = M.mID
order by name, title, stars;
--------------------------------------------------------------------------------
-- Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
select year
from Movie
where mID in (select mID from Rating  where stars = 4 or stars = 5)
order by year;

-- Using natural join :)
select distinct year from Movie natural join Rating
where stars = 4 or stars = 5
order by year;
--------------------------------------------------------------------------------
-- Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date.
select name
from Reviewer
where rID in (select rID from Rating where ratingDate is NULL);
--------------------------------------------------------------------------------
-- Find the titles of all movies that have no ratings.
select title
from Movie
where mID not in (select mID from Rating);
--------------------------------------------------------------------------------
-- Find the titles of all movies directed by Steven Spielberg.
select title
from Movie
where director = "Steven Spielberg";
--------------------------------------------------------------------------------
