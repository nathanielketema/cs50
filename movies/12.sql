-- SQL query to list the titles of all movies in which both Bradley Cooper 
-- and Jennifer Lawrence starred.

-- Select the movie titles
SELECT title
FROM movies
WHERE id IN (
    -- Select the movies they starred in
        SELECT movie_id
        FROM stars
        WHERE
            person_id IN (
                SELECT id
                FROM people
                WHERE
                    name = 'Bradley Cooper'
            ) AND
            movie_id IN (
                SELECT movie_id
                FROM stars
                WHERE
                    person_id = (
                        SELECT id
                        FROM people
                        WHERE name = 'Jennifer Lawrence'
                    )
            )
    );

-- or

SELECT title
FROM movies
WHERE id IN (
-- Select the movies they starred in
        SELECT movie_id
        FROM stars
        WHERE
            person_id IN (
                -- Select their IDs
                SELECT id
                FROM people
                WHERE
                    name IN ('Bradley Cooper', 'Jennifer Lawrence')
            )
        GROUP BY movie_id
        HAVING COUNT(DISTINCT person_id) = 2
    );
;

-- test
SELECT COUNT(*)
FROM movies
WHERE id IN (
-- Select the movies they starred in
        SELECT movie_id
        FROM stars
        WHERE
            person_id IN (
                -- Select their IDs
                SELECT id
                FROM people
                WHERE
                    name IN ('Bradley Cooper', 'Jennifer Lawrence')
            )
        GROUP BY movie_id
        HAVING COUNT(DISTINCT person_id) = 2
    );
;
