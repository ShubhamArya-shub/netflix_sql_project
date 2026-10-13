-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

SELECT 
COUNT(*) AS total_content
FROM netflix;

-- 15 Business Problems

-- 1. Count the number of Movies vs Tv Shows
SELECT 
type,
count(*) as total_content
FROM netflix
GROUP BY type

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
SELECT * FROM netflix
WHERE
type = 'Movie'
AND 
release_year = 2020

-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Identify the longest movie
SELECT * FROM netflix
WHERE 
type = 'Movie'
and
duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(TRIM(date_added), 'Month DD, YYYY') >=
      (SELECT MAX(TO_DATE(TRIM(date_added), 'Month DD, YYYY')) FROM netflix)
      - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- 9. Count the number of content items in each genre
SELECT
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
-- 10. Find each year and the average numbers of content release by India on netflix.
-- return top 5 year with highest avg content release
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
SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10