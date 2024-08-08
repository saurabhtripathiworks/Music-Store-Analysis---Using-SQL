Question Set 1

1. Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC 
LIMIT 1 ;

2. Which countries have the most Invoices?

SELECT COUNT(*) AS INVOICE , billing_country FROM invoice
group by billing_country
ORDER BY INVOICE DESC ; 

3. What are top 3 values of total invoice?

SELECT TOTAL FROM invoice
ORDER BY TOTAL DESC 
LIMIT 3 ;

4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals

select BILLING_CITY , sum(TOTAL) AS INVOICE_TOTAL FROM INVOICE 
GROUP BY BILLING_CITY 
ORDER BY INVOICE_TOTAL DESC ;

5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money

SELECT SUM(I.TOTAL) AS MAX_AMOUNT, C.customer_id, C.FIRST_NAME, C.LAST_NAME
FROM invoice I
JOIN customer C ON I.customer_id = C.customer_id
GROUP BY C.customer_id, C.FIRST_NAME, C.LAST_NAME
ORDER BY MAX_AMOUNT DESC
LIMIT 1;


Question Set 2

1. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT C.EMAIL, C.FIRST_NAME, C.LAST_NAME
FROM CUSTOMER C
JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
WHERE IL.TRACK_ID IN (
    SELECT T.TRACK_ID
    FROM TRACK T
    JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
    WHERE G.NAME LIKE 'ROCK'
)
ORDER BY C.EMAIL;

2. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name, COUNT(track.track_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;

Question Set 3

1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent

WITH best_selling_artist AS (
    SELECT 
        artist.artist_id AS artist_id, 
        artist.name AS artist_name, 
        SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id, artist.name
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

2. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres

WITH sales_per_country AS (
    SELECT 
        customer.country, 
        genre.name AS genre_name, 
        COUNT(invoice_line.quantity) AS purchases_per_genre
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name
),
max_genre_per_country AS (
    SELECT 
        country, 
        MAX(purchases_per_genre) AS max_genre_number
    FROM sales_per_country
    GROUP BY country
)
SELECT 
    spc.country, 
    spc.genre_name, 
    spc.purchases_per_genre
FROM sales_per_country spc
JOIN max_genre_per_country mgpc 
    ON spc.country = mgpc.country 
    AND spc.purchases_per_genre = mgpc.max_genre_number
ORDER BY spc.country, spc.purchases_per_genre DESC;

3. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount

WITH sales_per_country AS (
    SELECT 
        customer.country, 
        genre.name AS genre_name, 
        COUNT(invoice_line.quantity) AS purchases_per_genre
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name
),
max_genre_per_country AS (
    SELECT 
        country, 
        MAX(purchases_per_genre) AS max_genre_number
    FROM sales_per_country
    GROUP BY country
)
SELECT 
    spc.country, 
    spc.genre_name, 
    spc.purchases_per_genre
FROM sales_per_country spc
JOIN max_genre_per_country mgpc
    ON spc.country = mgpc.country
    AND spc.purchases_per_genre = mgpc.max_genre_number
ORDER BY spc.country, spc.genre_name;



























