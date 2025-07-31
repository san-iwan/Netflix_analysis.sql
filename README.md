# Netflix Content Analysis Using SQL

## 1. Objective

This project aims to conduct a structured, data-driven analysis of Netflix's publicly available content catalogue using SQL. The goal is to extract trends related to content type, regional growth, genre popularity, metadata quality, and user-oriented attributes (e.g., cast, rating) to help inform strategic decisions in content acquisition, regional market expansion, and platform improvement.

---

## 2. Dataset Schema

The dataset is structured in a single table named `netflix` and contains the following columns:

| Column Name     | Description                                                        |
|------------------|--------------------------------------------------------------------|
| show_id          | Unique identifier for each content item                            |
| title            | Name of the content                                                |
| director         | Name(s) of the director(s), if available                           |
| cast_            | List of cast members (comma-separated)                             |
| country          | Country where the content was released         |
| date_added       | Date when the content was added to Netflix                         |
| release_year     | Year of content release                                            |
| rating           | Maturity rating of the content                                     |
| duration         | Duration (in minutes or number of seasons)                         |
| listed_in        | Genre or category (comma-separated)                                |
| description      | Brief synopsis of the content                                      |
| content_type     | Indicates whether the content is a "Movie" or "TV Show"            |
| date_imported    | Date when the content was added to Netflix (in proper format)                 |

---

## 3. Summary of Findings and Strategic Insights

- **Content Composition**: Movies outnumber TV Shows by a significant margin, indicating a single-format focus.
- **Genre Coverage**: Documentaries, Dramas, and Action are highly represented, aligning with high-demand categories globally.
- **Geographic Focus**: Content additions in India have grown substantially in recent years, highlighting regional expansion efforts.
- **Metadata Inconsistency**: A notable portion of entries lacks director data, which may hinder recommendations and user filtering.
- **Star Power**: A small group of actors dominates Indian content, useful for performance marketing and influencer strategy.
- **Rating Distribution**: TV-MA and TV-14 dominate, suggesting a focus on mature and teen audiences.
- **Violent Theme Identification**: Content flagged with terms like "kill" or "violence" is non-trivial and may require category-level monitoring.
- **Monthly Trends**: Clear uptick in content additions during the 2019–2020 period, potentially due to the COVID-19 pandemic.

---



## 4. SQL Analysis – Questions and Solutions

---

### Q1. Count the content in each genre 
```sql
SELECT 
    unnest(string_to_array(listed_in, ',')) AS genre,
    COUNT(show_id)
FROM 
    netflix
GROUP BY 
    genre;

```
## Q2. Average Annual Content Added in India (Top 5 Years)
```sql
SELECT 
    EXTRACT(YEAR FROM date_imported) AS year,
    COUNT(*) AS total,
    ROUND(COUNT(*)::NUMERIC / (
        SELECT COUNT(*) FROM netflix WHERE country = 'India'
    )::NUMERIC * 100, 2) AS avg_per_year
FROM 
    netflix
WHERE 
    country = 'India'
GROUP BY 
    year
ORDER BY 
    avg_per_year DESC
LIMIT 5;


```
## Q3. List All Movies That Are Documentaries
```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

```
⸻

## Q4. Find All Content Without Directors
```sql
SELECT title
FROM netflix
WHERE director IS NULL;

```
⸻

## Q5. Count Movies Featuring Salman Khan in the Last 10 Years
```sql
SELECT *
FROM netflix
WHERE cast_ ILIKE '%salman khan%';
-- You may add a date filter based on your dataset

```
⸻

## Q6. Top 10 Actors in Indian Content
```sql
SELECT 
    unnest(string_to_array(cast_, ',')) AS actor,
    COUNT(*) AS total_content
FROM 
    netflix
WHERE 
    country ILIKE '%India%'
GROUP BY 
    actor
ORDER BY 
    total_content DESC
LIMIT 10;

```
⸻

## Q7. Categorise Content as “Good” or “Bad” Based on Description
```sql
WITH content_categorized AS (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad_content'
            ELSE 'good_content'
        END AS content_category
    FROM 
        netflix
)
SELECT 
    content_category,
    COUNT(*)
FROM 
    content_categorized
GROUP BY 
    content_category;

```
⸻

## Q8. Count the Number of TV Shows and Movies
```sql
SELECT 
    content_type,
    COUNT(show_id) AS count
FROM 
    netflix
GROUP BY 
    content_type;

```
⸻

## Q9. Most Common Rating for TV Shows and Movies
```sql
SELECT DISTINCT ON (content_type)
    content_type,
    rating,
    COUNT(*) AS total_count
FROM 
    netflix
GROUP BY 
    content_type, rating
ORDER BY 
    content_type, total_count DESC;

```
⸻

## Q10. List All Movies Released in 2020
```sql
SELECT *
FROM netflix
WHERE release_year = 2020 AND content_type = 'Movie';

```
⸻

## Q11. TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE 
    content_type = 'TV Show' 
    AND SPLIT_PART(duration, ' ', 1)::int > 5;

```
⸻

## Q12. Country with the Most Content
```sql
SELECT 
    country, 
    COUNT(*) AS total_content
FROM 
    netflix
GROUP BY 
    country
ORDER BY 
    total_content DESC
LIMIT 1;

```
⸻

## Q13. Top 5 Directors by Number of Titles
```sql
SELECT 
    director, 
    COUNT(*) AS total_titles
FROM 
    netflix
WHERE 
    director IS NOT NULL
GROUP BY 
    director
ORDER BY 
    total_titles DESC
LIMIT 5;

```
⸻

## Q14. Monthly Trend of Content Addition
```sql
SELECT 
    DATE_TRUNC('month', date_added) AS month,
    COUNT(*) AS content_added
FROM 
    netflix
WHERE 
    date_added IS NOT NULL
GROUP BY 
    month
ORDER BY 
    month;

```
⸻

## Q15. Content Type and Rating Distribution in Indian Content
```sql
SELECT 
    content_type,
    rating,
    COUNT(*) AS count,
    ROUND(COUNT(*)::NUMERIC / (
        SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%'
    ) * 100, 2) AS percentage
FROM 
    netflix
WHERE 
    country ILIKE '%India%'
GROUP BY 
    content_type, rating
ORDER BY 
    percentage DESC;

```

