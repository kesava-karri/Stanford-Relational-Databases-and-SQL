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
with T as select avg(avgBefore)-avg(avgAfter)
from(
select avg(stars) avgBefore 
from Movie natural join Rating
where year < 1980
group by mID
),
(select avg(stars) avgAfter 
from Movie natural join Rating
where year > 1980
group by mID);(
	select year, avg(stars) as avgStars 
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
