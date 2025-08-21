-- SQL query to list the names of all people who starred in Toy Story.
SELECT people.name
FROM people, stars, movies
WHERE
    people.id = stars.person_id
    AND movies.id = stars.movie_id
    AND movies.title = 'Toy Story';

-- or

-- Select names
SELECT name
FROM people
WHERE
    id IN
    (
    -- Select person IDs
        SELECT person_id
        FROM stars
        WHERE movie_id = (
            -- Select Toy Story's ID
                SELECT id
                FROM movies
                WHERE title = 'Toy Story'
            )
    );

-- test
SELECT COUNT(*)
FROM people, stars, movies
WHERE
    people.id = stars.person_id
    AND movies.id = stars.movie_id
    AND movies.title = 'Toy Story';
