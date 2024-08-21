--------------------------------------------------------------------------------
-- Find the name and grade of all students who are liked by more than one other student.
select name, grade
from (
		select ID2
		from Likes L
		group by ID2
		having count(ID2) > 1)
join Highschooler on ID2 = ID

--------------------------------------------------------------------------------
-- Find the difference between the number of students in the school and the number of different first names.
select abs((select count(*) from Highschooler)
        - (select count(distinct name) from Highschooler))

--------------------------------------------------------------------------------
-- For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C.
-- Thoughts:
-- Students who like each other & are not friends check if they have a mutual friend 

-- Go thru Likes rel
-- First check if they're not friends
-- Now Run a query over Friend which looks for a ID who is friends with both our targets
-- Grab that student C 
-- Repeat this process for all the students in Likes relation

-- First Check: To see if they're not friends
with T as (
	select *
	from Likes L
	where not exists (
		select *
		from Friend F
		where (L.ID1 = F.ID1 and L.ID2 = F.ID2)
		or (L.ID1 = F.ID2 and L.ID2 = F.ID1)
	)
)

select H1.name, H1.grade,  H2.name, H2.grade, H3.name, H3.grade
from (
	select T.ID1 as A, T.ID2 as B, F1.ID2 as C
	from T
	join Friend F1 on T.ID1 = F1.ID1 -- Finding friends of A
	join Friend F2 on T.ID2 = F2.ID2 -- Finding friends of B
	where F1.ID2 = F2.ID1 -- Finding the common friend
) as T2
join Highschooler H1 on T2.A = H1.ID
join Highschooler H2 on T2.B = H2.ID
join Highschooler H3 on T2.C = H3.ID
--------------------------------------------------------------------------------
-- Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade.
--Thoughts:
-- Looking for students who have friends only from the same grade & not from any other grade
with T as (
	select H1.ID as ID1, H1.name as name1, H1.grade as grade1, 
				min(H2.grade) as min_friend_grade, max(H2.grade) as max_friend_grade
	from Friend F
	join Highschooler H1 on F.ID1 = H1.ID
	join Highschooler H2 on F.ID2 = H2.ID
	group by ID1, name1, grade1
	order by grade1
)

select name1,  grade1
from T 
where ID1 in (select ID1 from T where min_friend_grade - max_friend_grade = 0)

-- Optimized version:
with T as (
	select H1.ID as ID1, H1.name as name1, H1.grade as grade1, 
				min(H2.grade) as min_friend_grade, max(H2.grade) as max_friend_grade
	from Friend F
	join Highschooler H1 on F.ID1 = H1.ID
	join Highschooler H2 on F.ID2 = H2.ID
	group by ID1, name1, grade1
)

select name1,  grade1
from T 
where grade1 = min_friend_grade and grade1 = max_friend_grade
order by grade1, name1

--------------------------------------------------------------------------------
-- For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades.
select H1.name, H1.grade, H2.name, H2.grade
from Likes 
join Highschooler H1 on ID1 = H1.ID
join Highschooler H2 on ID2 = H2.ID
where ID2 not in (select ID1 from Likes)


--------------------------------------------------------------------------------
-- Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade.
select name, grade
from Highschooler
where ID not in (select ID1 from Likes 
union
select ID2 from Likes)

--------------------------------------------------------------------------------
-- For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order.
with T as (
	select H1.name as name1, H1.grade as grade1, H2.name as name2, H2.grade as grade2
	from Highschooler H1
	join Likes L on H1.ID = L.ID1
	join Highschooler H2 on H2.ID = L.ID2
)

select T1.name1, T1.grade1, T1.name2, T1.grade2 from T T1, T T2
where T1.name1= T2.name2 and T1.name2 = T2.name1 and T1.name1 < T1.name2
order by T1.name1, T2.name1

--------------------------------------------------------------------------------
-- For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like.
select H1.name, H1.grade, H2.name, H2.grade
from Highschooler H1
join Likes L on H1.ID = L.ID1
join Highschooler H2 on H2.ID = L.ID2
where abs(H1.grade - H2.grade) >= 2

--------------------------------------------------------------------------------
-- Find the names of all students who are friends with someone named Gabriel.
-- Thoughts:
-- Grab Gabriel's ID
-- Find the IDs of the one's he's friends with
-- Use these IDs to find the names of Gabriel's friends

-- There's apparently 2 different student with the same name Gabriel
-- So need to use both their IDs
select name
from Highschooler
where ID in (select ID2
from (select ID from Highschooler where name = "Gabriel") join Friend on ID1 = ID);

-- No join version
select name 
from Highschooler
where ID in (select ID2
from Friend
where ID1 in (select ID from Highschooler where name = "Gabriel"));

--------------------------------------------------------------------------------
