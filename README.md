<p align="center">
  <img src="logo.png" alt="Netflix Logo" width="300">
</p>

# Netflix Movies and TV Shows Data Analysis using SQL

## Overview

This project is a SQL analysis of Netflix's movies and TV shows data. It uses PostgreSQL to clean, explore and answer **15 business questions** about content types, ratings, countries, genres, actors and more. The queries and the findings are in this repository.

## Objectives

- Compare the distribution of content types (Movies vs TV Shows)
- Find the most common ratings for each content type
- Analyze content by release year, country, duration and genre
- Find content using keywords and conditions (director, actor, description)

## Dataset

The data comes from the Kaggle dataset **Netflix Movies and TV Shows**.

- Dataset link: [Netflix Movies and TV Shows (Kaggle)](https://www.kaggle.com/datasets/shivamb/netflix-shows)
- Size: 8,807 rows and 12 columns (6,131 Movies and 2,676 TV Shows)
- Latest `date_added` in the data: 25 September 2021

## Tools Used

- PostgreSQL 18
- pgAdmin 4
- SQL (window functions, CTE-style subqueries, string and date functions)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
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
```

## How to Run

1. Create a database (for example `netflix_db`) in pgAdmin.
2. Run the `CREATE TABLE` statement from `Solutions_of_15_business_problems.sql`.
3. Right-click the `netflix` table, choose **Import/Export Data**, select `netflix_titles.csv`, and turn **Header** ON. The CSV column `cast` maps to the table column `casts` by position.
4. Run the queries one by one.

## Business Problems and Solutions

The full SQL for every problem is in [`Solutions_of_15_business_problems.sql`](Solutions_of_15_business_problems.sql).

### 1. Count the number of Movies vs TV Shows

```sql
SELECT type, COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

### 2. Find the most common rating for movies and TV shows

```sql
SELECT type, rating, total_count
FROM (
    SELECT type, rating, COUNT(*) AS total_count,
           RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) AS t
WHERE ranking = 1;
```

### 3. List all movies released in a specific year (e.g., 2020)

```sql
SELECT * FROM netflix
WHERE type = 'Movie' AND release_year = 2020;
```

### 4. Find the top 5 countries with the most content on Netflix

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
       COUNT(show_id) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

### 5. Identify the longest movie

```sql
SELECT * FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
LIMIT 1;
```

### 6. Find content added in the last 5 years

```sql
SELECT * FROM netflix
WHERE TO_DATE(TRIM(date_added), 'Month DD, YYYY') >=
      (SELECT MAX(TO_DATE(TRIM(date_added), 'Month DD, YYYY')) FROM netflix)
      - INTERVAL '5 years';
```

### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

### 8. List all TV shows with more than 5 seasons

```sql
SELECT * FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

### 9. Count the number of content items in each genre

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
       COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;
```

### 10. Find each year and the average number of content released in India (top 5 years)

```sql
SELECT EXTRACT(YEAR FROM TO_DATE(TRIM(date_added), 'Month DD, YYYY')) AS year,
       COUNT(*) AS total_content,
       ROUND(COUNT(*)::NUMERIC /
             (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%') * 100, 2)
             AS avg_content_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY avg_content_per_year DESC
LIMIT 5;
```

### 11. List all movies that are documentaries

```sql
SELECT * FROM netflix
WHERE type = 'Movie' AND listed_in ILIKE '%Documentaries%';
```

### 12. Find all content without a director

```sql
SELECT * FROM netflix
WHERE director IS NULL;
```

### 13. Find how many movies actor 'Salman Khan' appeared in, in the last 10 years

```sql
SELECT COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie'
  AND casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. Find the top 10 actors with the most movies produced in India

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
       COUNT(*) AS total_movies
FROM netflix
WHERE type = 'Movie' AND country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### 15. Categorize content as 'Good' or 'Bad' based on the keywords 'kill' and 'violence'

```sql
SELECT category, COUNT(*) AS total_content
FROM (
    SELECT CASE
             WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
             ELSE 'Good'
           END AS category
    FROM netflix
) AS categorized
GROUP BY category;
```

## Findings

- **Content mix:** Movies make up about 70% of the catalog (6,131 Movies vs 2,676 TV Shows).
- **Ratings:** TV-MA is the most common rating for both Movies (2,062) and TV Shows (1,145), so Netflix's catalog leans toward mature audiences.
- **Countries:** The United States leads with 3,690 titles, followed by India (1,046), the United Kingdom (806), Canada (445) and France (393).
- **Longest movie:** *Black Mirror: Bandersnatch* at 312 minutes.
- **Recent additions:** 8,422 titles were added in the 5 years before the latest date in the data.
- **Long-running shows:** 99 TV shows have more than 5 seasons.
- **Genres:** International Movies (2,752), Dramas (2,427) and Comedies (1,674) are the top genres. There are 42 distinct genres.
- **India:** 2018 was the peak year, with 349 titles added (33.37% of all India content), followed by 2019 (20.84%) and 2020 (19.02%).
- **Documentaries:** 869 movies are documentaries.
- **Missing directors:** 2,634 titles have no director listed.
- **Actors in Indian movies:** Anupam Kher (40), Shah Rukh Khan (34) and Naseeruddin Shah (31) appear in the most Indian movies.
- **Content labels:** 342 titles mention "kill" or "violence" in the description (labeled Bad), and 8,465 do not (labeled Good).

## Data Notes

- Some columns hold several values in one cell (`country`, `casts`, `listed_in`), so the queries split them with `STRING_TO_ARRAY` and `UNNEST`, and clean them with `TRIM`.
- `date_added` is stored as text, so it is converted with `TO_DATE`.
- For "last 5 years" (problem 6), the latest date in the dataset is used as the reference, because the data ends in September 2021.
- Problem 13 uses `CURRENT_DATE`, so its result changes over time.
- Three rows have the duration value in the `rating` column and a NULL `duration`.

## Project Structure

```
.
├── README.md
├── logo.png
├── netflix_titles.csv
└── Solutions_of_15_business_problems.sql
```

## Author

**Shubham Kumar**

- GitHub: [ShubhamArya-shub](https://github.com/ShubhamArya-shub)
- LinkedIn: [shubham-arya](https://www.linkedin.com/in/shubham-arya-1706b7391)
