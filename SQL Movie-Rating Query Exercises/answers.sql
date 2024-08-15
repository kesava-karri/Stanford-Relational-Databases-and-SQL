
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
