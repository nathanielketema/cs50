-- SQL query to list the titles of all movies released in 2008.
SELECT title
FROM movies
WHERE year = 2008;


-- To test the above query
SELECT COUNT(*)
FROM movies
WHERE year = 2008;
