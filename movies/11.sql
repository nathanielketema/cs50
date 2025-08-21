-- SQL query to list the titles of the five highest rated movies (in order)
-- that Chadwick Boseman starred in, starting with the highest rated.
SELECT title
FROM movies
WHERE
    id IN (
        -- Select the movies ordered by their rankings
        SELECT movie_id
        FROM ratings
        WHERE
            movie_id IN (
                -- Select movies Chadwick starred in
                SELECT movie_id
                FROM stars
                WHERE
                    person_id = (
                    -- Select Chadwick
                        SELECT id
                        FROM people
                        WHERE
                            name = 'Chadwick Boseman'
                    )
            )
        ORDER BY rating DESC
        LIMIT 5
    )
ORDER BY (
    SELECT rating
    FROM ratings
    WHERE
        ratings.movie_id = movies.id
) DESC;

-- or (very slow) (a tiny bit faster than join)

SELECT DISTINCT title
FROM movies, ratings, stars, people
WHERE
    movies.id = stars.movie_id AND
    movies.id = ratings.movie_id AND
    people.id = stars.person_id AND
    people.name = 'Chadwick Boseman'
ORDER BY ratings.rating DESC
LIMIT 5;

-- or (very slow)

SELECT DISTINCT movies.title
FROM movies
JOIN stars ON stars.movie_id = movies.id
JOIN people ON people.id = stars.person_id
JOIN ratings ON ratings.movie_id = movies.id
WHERE people.name = 'Chadwick Boseman'
ORDER BY ratings.rating DESC, movies.title ASC
LIMIT 5;
