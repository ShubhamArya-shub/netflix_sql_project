-- ============================================================
-- Netflix Movies and TV Shows Data Analysis using SQL
-- Database : PostgreSQL 18 (pgAdmin 4)
-- Table    : netflix
-- Solutions of 15 business problems
-- ============================================================

-- ------------------------------------------------------------
-- Table setup
-- WARNING: DROP TABLE deletes the table and all its data.
-- Run this block only once, when creating the table.
-- ------------------------------------------------------------
-- DROP TABLE IF EXISTS netflix;
CREATE TABLE IF NOT EXISTS netflix
(
    show_id       VARCHAR(10) PRIMARY KEY,
    type          VARCHAR(10),
    title         VARCHAR(250),
    director      VARCHAR(550),
    casts         VARCHAR(1050),
    country       VARCHAR(550),
    date_added    VARCHAR(55),
    release_year  INT,
    rating        VARCHAR(15),
    duration      VARCHAR(15),
    listed_in     VARCHAR(250),
    description   VARCHAR(550)
);

-- Import netflix_titles.csv with pgAdmin (Import/Export Data, Header ON).
-- The CSV column "cast" maps to the table column "casts" by position.

-- Quick checks
SELECT * FROM netflix;

SELECT COUNT(*) AS total_content
FROM netflix;


-- ============================================================
-- 15 Business Problems & Solutions
-- ============================================================

-- 1. Count the number of Movies vs TV Shows
SELECT
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;


-- 2. Find the most common rating for movies and TV shows
SELECT type, rating, total_count
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS total_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t
WHERE ranking = 1;


-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
-- A title can list several countries separated by commas, so split them
-- into rows first. TRIM removes the extra space before each country.
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
    COUNT(show_id) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 5. Identify the longest movie
-- duration is text ("99 min", "312 min"), so take the number part
-- and sort it as an integer. MAX(duration) would compare text.
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;


-- 6. Find content added in the last 5 years
-- The latest date_added in the dataset (Sep 2021) is used as the
-- reference, because CURRENT_DATE is much later than the data.
SELECT *
FROM netflix
WHERE TO_DATE(TRIM(date_added), 'Month DD, YYYY') >=
      (SELECT MAX(TO_DATE(TRIM(date_added), 'Month DD, YYYY')) FROM netflix)
      - INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;


-- 9. Count the number of content items in each genre
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;


-- 10. Find each year and the average number of content released in India
--     on Netflix. Return the top 5 years with the highest average content.
-- "Average" here means each year's share (%) of all India content.
-- Year is the year the content was added to Netflix (date_added).
SELECT
    EXTRACT(YEAR FROM TO_DATE(TRIM(date_added), 'Month DD, YYYY')) AS year,
    COUNT(*) AS total_content,
    ROUND(
        COUNT(*)::NUMERIC /
        (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%') * 100
    , 2) AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY avg_content_per_year DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND listed_in ILIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in, in the last 10 years
-- Result depends on the current date (CURRENT_DATE).
SELECT COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
  AND casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of
--     movies produced in India
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
  AND country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 15. Categorize the content based on the keywords 'kill' and 'violence'
--     in the description field. Label content containing these keywords
--     as 'Bad' and all other content as 'Good'. Count how many items
--     fall into each category.
SELECT
    category,
    COUNT(*) AS total_content
FROM (
    SELECT
        CASE
            WHEN description ILIKE '%kill%'
              OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized
GROUP BY category;

-- End of Project
