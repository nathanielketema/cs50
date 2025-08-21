-- SQL query to list the names of all people who starred in a movie
-- released in 2004, ordered by birth year.
SELECT DISTINCT name
FROM people
WHERE
    id IN (
        -- Select person id
        SELECT person_id
        FROM stars
        WHERE movie_id IN (
            -- Select movie id
                SELECT id
                FROM movies
                WHERE year = 2004
            )
    )
ORDER BY birth ASC;

-- test
SELECT COUNT(DISTINCT name)
FROM people
WHERE
    id IN (
        -- Select person id
        SELECT person_id
        FROM stars
        WHERE movie_id IN (
            -- Select movie id
                SELECT id
                FROM movies
                WHERE year = 2004
            )
    )
ORDER BY birth ASC;
