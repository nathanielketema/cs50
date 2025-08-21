-- SQL query to list the names of all people who have directed a movie 
-- that received a rating of at least 9.0.
SELECT name
FROM people
WHERE id IN (
    -- Select the directors
        SELECT DISTINCT person_id
        FROM directors
        WHERE movie_id IN (
            -- Select the movies
                SELECT movie_id
                FROM ratings
                WHERE rating >= 9.0
            )
    );

-- test
SELECT COUNT(*)
FROM people
WHERE id IN (
    -- Select the directors
        SELECT DISTINCT person_id
        FROM directors
        WHERE movie_id IN (
            -- Select the movies
                SELECT movie_id
                FROM ratings
                WHERE rating >= 9.0
            )
    );
