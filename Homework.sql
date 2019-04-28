USE SAKILA;

-- 1a. Display the first and last names of all actors from the table actor.

Select first_name, last_name 
From actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
Select Upper(concat(first_name," ", last_name))
From actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id, first_name, last_name
From actor
Where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

Select actor_id, first_name, last_name
From actor
Where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
Select actor_id, first_name, last_name
From actor
Where last_name like "%LI%"
Order By last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
Select country_id, country
From country
where country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).

Alter Table actor
add Description blob;

select *
from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

Alter Table actor
drop column Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

Select last_name, count(*)
From actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(*) as same_lastname
From actor
group by last_name
Having same_lastname >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

Select *
From actor
Where first_name = "Groucho"
and last_name = "Williams";

UPDATE ACTOR 
   SET first_name = 'HARPO' 
 WHERE first_name  = 'GROUCHO' 
   AND last_name = 'WILLIAMS'
;
-- Performing a select after update to verify update results. 
SELECT * FROM ACTOR 
 WHERE first_name  = 'HARPO' 
   AND last_name = 'WILLIAMS'
;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

SELECT *
  FROM ACTOR
 WHERE ACTOR_ID  = 172
;

-- Update with case statement to determine the update value for first_name.
UPDATE ACTOR SET first_name = 
  CASE WHEN first_name = 'HARPO'
         THEN 'GROUCHO'
		 ELSE 'MUCHO GROUCHO'
  END
 WHERE ACTOR_ID  = 172
;

SELECT first_name 
  FROM ACTOR
 WHERE ACTOR_ID  = 172
;

-- 5a. . You cannot locate the schema of the `address` table. Which query 
-- would you use to re-create it?
-- Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>


SHOW CREATE TABLE address ;

-- Create table query can be run after reviewing the original create
-- table DDL that is retrieved using the show.


CREATE TABLE `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

/*6a. Use `JOIN` to display the first and last names, as well as the address,
  of each staff member. Use the tables `staff` and `address`:*/
SELECT   S.first_name
        ,S.last_name
        ,A.address

  FROM  STAFF   S 
  
  LEFT JOIN ADDRESS A
         ON S.address_id = A.address_id
 ;
 
 /*6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
Use tables `staff` and `payment`.*/
SELECT  P.staff_id
       ,concat(S.first_name,' ',S.last_name) as Name
       ,SUM(P.amount) as Total_Amount
  FROM PAYMENT P
  JOIN STAFF S ON P.staff_id = S.staff_id 
 GROUP BY P.staff_id
;
/*6c. List each film and the number of actors who are listed for that film. 
Use tables `film_actor` and `film`. Use inner join. */

SELECT   FA.film_id
		,F.title
		,count(FA.actor_id) as Actor_Count
  FROM   FILM_ACTOR FA
		,FILM F 
 WHERE   FA.film_id = F.film_id
 GROUP BY FA.film_id
-- ORDER BY Actor_Count DESC
;

/*6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? */
SELECT  I.film_id, F.title
	   ,count(I.inventory_id) as count_copies
  FROM  INVENTORY I 
	   ,FILM F 
 WHERE  I.film_id in 
        (SELECT F.film_id FROM FILM F 
          WHERE F.title like 'Hunchback%Impossible%')
   AND I.FILM_ID = F.FILM_ID
 GROUP BY 1
 ;

/*6e. Using the tables `payment` and `customer` and the `JOIN` command, 
list the total paid by each customer. List the customers alphabetically by last name: */

select    C.first_name, C.last_name, Sum(P.amount) as Cust_Total 
  from    PAYMENT  P
	     ,CUSTOMER C
where     P.customer_id = C.customer_id
Group BY  C.last_name, C.first_name
ORDER BY  C.last_name  
;

-- 7a.
/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters `K` and `Q` have 
also soared in popularity. Use subqueries to display the titles of movies starting 
with the letters `K` and `Q` whose language is English.*/

SELECT title 
  FROM FILM F
 WHERE ((F.title like 'K%')  OR
	   (F.title like 'Q%')  AND
	   (F.language_id IN  ( Select language_id 
							from  language L
                            where L.name = 'English' )))
					                        
 ;

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
--     Film id is 17 for 'Alone Trip'

select  A.first_name, A.last_name 
  from  film_actor FA
       ,actor       A
where  FA.film_id = (SELECT FILM_ID FROM FILM F WHERE F.title = 'Alone Trip')
  and  FA.actor_id = A.actor_id
;
	
 -- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
 -- email addresses of all Canadian customers. Use joins to retrieve this information.
 
SELECT C.first_name, C.last_name, C.email
  FROM CUSTOMER C
 WHERE address_id in (select  A.address_id 
                        from  ADDRESS A
                             ,CITY    CI
                             ,COUNTRY CN
                       where  A.city_id     = CI.city_id
                         AND  CI.country_id = CN.country_id
                         AND  CN.country = 'Canada')
					  
;
-- 7d.
-- Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as family films.

SELECT F.title, F.description
  from FILM F
 WHERE F.film_id in 
                (select  FC.film_id 
                   from  film_category FC
                        ,Category      C
				  where  FC.category_id = C.category_id
                    and  C.name = 'Family'
                )
;				

/* 7e. Display the most frequently rented movies in descending order. */
select  I.film_id, F.title,  count(*) as count_rented
 from   rental    R 
       ,inventory I 
       ,Film      F
where   R.inventory_id = I.inventory_id
  and   I.film_id      = F.film_id
Group by I.film_id, F.title
order by count_rented Desc
;

/* 7f. Write a query to display how much business, in dollars, each store brought in. 
Use  PAYMENT, CUSTOMER */
SELECT    C.store_id, Sum(P.amount) as Total_store
    From  Payment  P
         ,Customer C
         
	where  P.customer_id = C.customer_id 
    Group by C.store_id
;


/* 7g. Write a query to display for each store its store ID, city, and country.*/
-- Use Store, address, city country
SELECT S.store_id, CI.city, CN.country
 FROM  STORE   S
      ,ADDRESS A
      ,CITY    CI
      ,COUNTRY CN
 
 where S.address_id  = A.address_id
   and A.city_id     = CI.city_id
   and CI.country_id = CN.country_id
;

/* 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to 
use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT C.name as Genre, sum(P.AMOUNT) as Gross_revenue
  FROM   PAYMENT  P
		,RENTAL   R
        ,inventory I
        ,FILM_CATEGORY FC
        ,Category  C
WHERE    P.rental_id = R.rental_id
  AND    R.inventory_id = I.inventory_id
  AND    I.film_id      = FC.film_id
  AND    FC.category_id = C.category_id
GROUP BY C.name
ORDER BY 2 DESC
LIMIT  5 
;  

/* 8a. In your new role as an executive, you would like to have an easy way of viewing 
the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/

CREATE VIEW Gross_revenue_genre as 
	(SELECT C.name as Genre, sum(P.AMOUNT) as Gross_revenue
	  FROM   PAYMENT  P
			,RENTAL   R
			,inventory I
			,FILM_CATEGORY FC
			,Category  C
	WHERE    P.rental_id = R.rental_id
	  AND    R.inventory_id = I.inventory_id
	  AND    I.film_id      = FC.film_id
	  AND    FC.category_id = C.category_id
	GROUP BY C.name
	ORDER BY 2 DESC
	LIMIT  5 )
;

/* 8b. How would you display the view that you created in 8a?*/ 
SHOW CREATE VIEW Gross_revenue_genre;

-- Use below query to display all rows from the view. 

SELECT * FROM Gross_revenue_genre ;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query 
-- to delete it.

DROP VIEW Gross_revenue_genre;
