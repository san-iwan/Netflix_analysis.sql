-- count the number of items in each genre

select * from netflix;

select 
unnest(string_to_array(listed_in, ',')) as genre ,
count(show_id)
from netflix

group by genre;

-- find the average content added annually in india and return the top 5 years 

SELECT 
    EXTRACT(YEAR FROM date_imported) AS year,
    COUNT(*) AS total,
	ROUND(count(*)::numeric/(select  count(*) from netflix where country= 'India' )::numeric *100,2) as avg_per_year  
FROM netflix 
WHERE country = 'India'
GROUP BY year 
ORDER BY avg_per_year desc ;


--list all the movies that are documentaries

select 
*
from netflix
where listed_in  ILIKE '%documentaries%'
 ;
-- find all the content without directors

select title
from netflix 

where director is  null ;

--how many movies has salmankhan starred in last 10 years

select *

from netflix 

where cast_ ilike '%salman khan%';
--AND 
--date_imported >= current_date - interval '10 years' ;

-- find the top 10 actors who have appeared in the highest no of indian movies .

select
unnest(string_to_array(cast_,',')) as actors ,
count(*) as total_content
 from netflix
where country ilike '%India%' 
group by 1
order by 2 desc
limit 10;

--categorise content into "bad " based on the presence of words like kill and violence and rest as good and then count the content under each category

with new_table as
(select 
case 
when 
description ilike '%kill%'
or description ilike '%violence%'then 'bad_content'
else 'good_content'
end  content_category

from netflix )

select 
count (*),
content_type
from new_table
group by content_category ;


-- count the number of tv shows and movies
select content_type,
count (show_id) as counts
from netflix 
group by content_type;

-- find the most common rating for tv shows and movies

select 
distinct on(content_type) content_type ,rating ,
count(*) as total_count

from netflix
--where content_type = 'TV Show'
group by content_type ,rating 
order by content_type ,total_count desc

;
--find all the movies released in 2020

select *
from netflix

where content_type = 'Movies'
and release_year = 2020;

-- find the top 5 countries with most content on netflix

select 
unnest(string_to_array(country,',')) as country_,
count(*) total_content

from netflix
group by country_
order by total_content desc
limit 5 ;

--identify the longest movie.
 select 
 *
 From netflix

where content_type = 'Movies'
 AND duration = (select MAX(duration) from netflix);

 -- find the content added in last 5 years

 select * from netflix 

 where 
 date_imported >= current_date - interval '5 years '
 ;

 --find all the movies/tv shows directed 'Rajiv Chilaka'

 select
 *
 from netflix 
 where director ilike '%Rajiv Chilaka%' ;

 --list all the tv shows with more than 5 seasons


 select *

 from netflix

where content_type = 'TV Show'
and SPLIT_PART (duration, ' ',1 ) :: int > 5 :: int;