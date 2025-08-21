-- Keep a log of any SQL queries you execute as you solve the mystery.

-- What I know so far
-- * The theft took place on July 28, 2024 and 
-- * It took place on Humphrey Street.

-- The crime scene description of the theft that occured
SELECT description
FROM crime_scene_reports
WHERE
    year = 2024 AND
    month = 7 AND
    day = 28 AND
    street = 'Humphrey Street' AND
    id = 295;

-- Interview trascripts relevant to the crime
SELECT name, transcript
FROM interviews
WHERE
    year = 2024 AND
    month = 7 AND
    day = 28 AND
    id IN (161, 162, 163);

-- Suspected license plates
SELECT hour, minute, activity, license_plate
FROM bakery_security_logs
WHERE
    year = 2024 AND
    month = 7 AND
    day = 28 AND
    hour = 10 AND
    minute BETWEEN 15 AND 25;

-- Suspected phone calls
SELECT caller, receiver, duration
FROM phone_calls
WHERE
    year = 2024 AND
    month = 7 AND
    day = 28 AND
    duration <= 60;

-- Suspected bank accounts
SELECT account_number, amount
FROM atm_transactions
WHERE
    year = 2024 AND
    month = 7 AND
    day = 28 AND
    atm_location = 'Leggett Street' AND
    transaction_type = 'withdraw';

-- Suspects flight ID
SELECT id
FROM flights
WHERE
    year = 2024 AND
    month = 7 AND
    day = 29 AND
    origin_airport_id = (
    -- Airport ID of Fiftyville
        SELECT id
        FROM airports
        WHERE
            city = 'Fiftyville'
    )
ORDER BY hour ASC LIMIT 1;

-- Thief --> Bruce (gotcha)
SELECT name
FROM people
WHERE
    id IN (
        SELECT person_id
        FROM bank_accounts
        WHERE
            account_number IN (
                SELECT account_number
                FROM atm_transactions
                WHERE
                    year = 2024 AND
                    month = 7 AND
                    day = 28 AND
                    atm_location = 'Leggett Street' AND
                    transaction_type = 'withdraw'
            )
            AND phone_number IN (
                SELECT caller
                FROM phone_calls
                WHERE
                    year = 2024 AND
                    month = 7 AND
                    day = 28 AND
                    duration <= 60
            )
            AND license_plate IN (
                SELECT license_plate
                FROM bakery_security_logs
                WHERE
                    year = 2024 AND
                    month = 7 AND
                    day = 28 AND
                    hour = 10 AND
                    minute BETWEEN 15 AND 25
            )
            AND passport_number IN (
                SELECT passport_number
                FROM passengers
                WHERE
                    flight_id IN (
                        SELECT id
                        FROM flights
                        WHERE
                            year = 2024 AND
                            month = 7 AND
                            day = 29 AND
                            origin_airport_id = (
                                -- Airport ID of Fiftyville
                                SELECT id
                                FROM airports
                                WHERE
                                    city = 'Fiftyville'
                            )
                        ORDER BY hour ASC LIMIT 1
                    )
            )
    );

-- The city the theif went to
SELECT city
FROM airports
WHERE
    id = (
        SELECT destination_airport_id
        FROM flights
        WHERE
            id = (
                SELECT flight_id
                FROM passengers
                WHERE
                    passport_number = (
                        SELECT passport_number
                        FROM people
                        WHERE name = 'Bruce'
                    )
            )
    );

-- The Accomplice
SELECT name
FROM people
WHERE
    phone_number = (
        SELECT receiver
        FROM phone_calls
        WHERE
            year = 2024 AND
            month = 7 AND
            day = 28 AND
            duration <= 60 AND
            caller = (
                SELECT phone_number
                FROM people
                WHERE
                    name = 'Bruce'
            )
    );
