CREATE DATABASE music_store;alter;
USE music_store;
SELECT * FROM album2;

-- 1. Whow is the senior most employee based on job title
SELECt * FROM employee
ORDER BY levels desc
LIMIT 1;

-- 2. Which countries have the most invoice
SELECT COUNT(*) as most_invoice, billing_country FROM invoice
GROUP BY billing_country
ORDER BY most_invoice desc;

-- 3. What are top 3 value of total invoice
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best coustomer? Write a query to retunt one city that has the highest sum of invoice total. Return both city name and sum of all invoice total
SELECT billing_city, sum(total) as total_invoice FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC;

-- 5. Who is the best customer? The customer who has spend most money will be declear as best customer. Write a query that returns the person who has spent the most money?
SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS spent  FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY spent DESC
LIMIT 1;

-- 6. write a query to return first name, last name, email, and genre of all rok music listener return your list ordered alphabeticaly by email strat with A.
SELECT distinct first_name, last_name, email FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
SELECT track_id FROM track
JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name like "Rock")
ORDER BY email; 

-- 7. lets invite the artists who have written most rock music in our dataset. Wrire query that returns the artist name and total track count of top 10 rock band.
SELECT  artist.artist_id, artist.name, count(artist.name) AS song_count
FROM track 
join album2 on album2.album_id = track.album_id
join artist on artist.artist_id=album2.artist_id
join genre on track.genre_id=genre.genre_id
WHERE genre.name="Rock"
group by artist.artist_id, artist.name
ORDER BY song_count desc
limit 10;

-- 8. Return all the track names that have song length longer than the average song length . Return name and miliseconds for each track. 
-- order by song lenght with the longest song listed first
SELECT name, milliseconds FROM track
WHERE milliseconds> 
(SELECT AVG(milliseconds) AS lenght FROM track)
ORDER BY milliseconds desc ;

-- 9. find how much amout spend by each customer on artiest? Write a query to return customer namne, artistname and total spent.
WITH best_selling_artist AS (SELECT artist.artist_id as artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) as total_price
FROM invoice_line JOIN track On invoice_line.track_id=track.track_id
JOIN album2 ON track.album_id=album2.album_id
JOIN artist ON album2.artist_id=artist.artist_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1
)
SELECT c.first_name as First_name, c.last_name AS last_name, best.artist_name as artist, SUM(il.unit_price*il.quantity) as total_amount
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track trk ON il.track_id=trk.track_id
JOIN album2 alb ON trk.album_id=alb.album_id
JOIN best_selling_artist best ON alb.artist_id= best.artist_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

-- 10. We want to find out most popular music genre for each country.
 WITH popular_genre AS (SELECT COUNT(invoice_line.quantity) AS purchess,customer.country, genre.name,
ROW_NUMBER()Over(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rowno
FROM invoice_line
JOIN invoice  ON invoice_line.invoice_id=invoice.invoice_id
JOIN customer ON invoice.invoice_id=customer.customer_id
JOIN track ON invoice_line.track_id=track.track_id
JOIN genre ON track.genre_id=genre.genre_id
GROUP BY 2,3
order by 1 DESC, 2 ASC
)
SELECT * FROM popular_genre
WHERE rowno<=1;

