# Netflix Content Analysis Using SQL
![netflix_logo](https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.pcmag.com%2Freviews%2Fnetflix&psig=AOvVaw2Hz_lUVwYrGh7ZLb2liWN2&ust=1754064210237000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCKjiwMO8544DFQAAAAAdAAAAABAE)
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



## 4. SQL Analysis – Business Questions and Solutions


## Q1. What is the distribution of content across different genres?

Understanding genre distribution helps identify content diversity and dominant content themes on Netflix.
```sql
SELECT 
    unnest(string_to_array(listed_in, ',')) AS genre,
    COUNT(show_id)
FROM 
    netflix
GROUP BY 
    genre;

```


## Q2. Which 5 years saw the highest content addition in India?

Reveals content growth trends in the Indian market, useful for regional strategy assessment.
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


## Q3. Which movies are categorised as documentaries?

Identifying documentary content helps understand Netflix’s educational and non-fictional offerings.
```sql
SELECT *
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

```


## Q4. Which titles lack director information?

Helps assess metadata completeness, which is critical for accurate recommendations and analytics.
```sql
SELECT title
FROM netflix 
WHERE director IS NULL;

```
⸻

## Q5. How many movies has Salman Khan featured in (last 10 years)?

Analyses star-driven content and helps evaluate actor influence on the platform.
```sql
SELECT *
FROM netflix 
WHERE cast_ ILIKE '%salman khan%';
-- Optional:
-- AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

```


## Q6. Who are the top 10 most frequent actors in Indian content?

Identifies the most prominent and bankable actors in regional content.
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


## Q7. What proportion of content contains violent keywords?

Content categorization based on keywords helps monitor viewer safety and content sensitivity.
```sql
WITH new_table AS (
    SELECT 
        content_type,
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
    new_table
GROUP BY 
    content_category;

```


## Q8. What is the overall split between Movies and TV Shows?

Understanding the content format mix helps evaluate platform focus.
```sql
SELECT 
    content_type,
    COUNT(show_id) AS counts
FROM 
    netflix 
GROUP BY 
    content_type;

```


## Q9. What are the most common maturity ratings for each content type?

Analyses audience targeting and helps assess content compliance by age group.
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


## Q10. Which movies were released in 2020?

Provides insights into recent content additions and catalog freshness.
```sql
SELECT *
FROM netflix
WHERE 
    content_type = 'Movie'
    AND release_year = 2020;

```


## Q11. What are the top 5 countries by number of titles?

Indicates Netflix’s regional content strength and international content focus.
```sql
SELECT 
    unnest(string_to_array(country, ',')) AS country_,
    COUNT(*) AS total_content
FROM 
    netflix
GROUP BY 
    country_
ORDER BY 
    total_content DESC
LIMIT 5;

```


## Q12. What is the longest movie available on the platform?

Highlights unique content that may stand out due to its duration or storytelling format.
```sql
SELECT *
FROM netflix
WHERE 
    content_type = 'Movie'
    AND duration = (SELECT MAX(duration) FROM netflix);

```


## Q13. What content was added in the last 5 years?

Tracks recent expansion and helps evaluate platform growth.
```sql
SELECT *
FROM netflix 
WHERE 
    date_imported >= CURRENT_DATE - INTERVAL '5 years';

```


## Q14. What content is directed by Rajiv Chilaka?

Used for analysing creator-specific catalogues or fan-driven recommendations.
```sql
SELECT *
FROM netflix 
WHERE director ILIKE '%Rajiv Chilaka%';

```


## Q15. Which TV Shows have more than 5 seasons?
```sql
Identifies long-running or high-engagement series useful for retention-focused analysis.

SELECT *
FROM netflix
WHERE 
    content_type = 'TV Show'
    AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```
