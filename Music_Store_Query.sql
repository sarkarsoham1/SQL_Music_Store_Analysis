/* Question Set 1*/

/*Q1. Who is the senior most employee based on job title?*/

select * from employee 
	order by levels desc limit 1;

/*Q2. Which countries have the most invoices?*/

select billing_country, count(invoice_id) as invoices from invoice 
	group by billing_country order by invoices desc limit 1;

/*Q3. What are top 3 values of total invoice*/

select total as total_invoice from invoice 
	order by total desc limit 3;

/*Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city 
we made the most money. Write a quesry that returns one city that has the highest sum of invoice totals.
Return both the city name and sum of all invoice totals*/

select billing_city as city, sum(total) as sum from invoice 
	group by city order by sum desc limit 1;

/*Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer.
Write a query that returns the person who has spent the most money*/

select customer.customer_id, first_name, last_name, sum(invoice.total) as total from customer
	join invoice on customer.customer_id = invoice.customer_id group by customer.customer_id 
	order by total desc limit 1;

/* Question Set 2*/

/*Q1. Write query to return the email, first name, last name and genre of all Rock Music listeners.
Return your list ordered alphabetically by email starting with A*/

select distinct email, first_name, last_name from customer
	join invoice on customer.customer_id = invoice.customer_id
	join invoice_line on invoice.invoice_id = invoice_line.invoice_id
	join track on invoice_line.track_id = track.track_id
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
	order by email;

/*Q2. Let's invite the artists who have written the most rock music in our dataset. Write a query that
returns the Artist name and total track count of the top 10 rock bands*/

select artist.artist_id, artist.name, count(artist.artist_id) as total_songs from track
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.album_id
	join genre on genre.genre_id = track.genre_id
	where genre.name like 'Rock'
	group by artist.artist_id
	order by total_songs desc
	limit 10;

/*Q3. Return all the track names that have a song length longer than the average song length. Return the name 
and milliseconds for each track. Order by the song length with the longest song listed first.*/

select name, milliseconds from track 
	where milliseconds > (select avg(milliseconds) from track)
	order by milliseconds desc;

/* Question Set 3*/

/*Q1. Find how much amount spent by each customer on best selling artists? Write a query to return customer name,
artist name and total spent*/

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, 
	sum(invoice_line.unit_price * invoice_line.quantity) as total_sales from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1
	)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as amount_spent
	from invoice as i
	join customer as c on c.customer_id = i.customer_id
	join invoice_line as il on il.invoice_id = i.invoice_id
	join track on track.track_id = il.track_id
	join album on album.album_id = track.album_id
	join best_selling_artist as bsa on bsa.artist_id = album.artist_id
	group by 1,4
	order by 5 desc;

/*Q2. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as (
	select customer.country, genre.name, genre.genre_id, count(invoice_line.quantity) as purchases,
	row_number() over (partition by customer.country order by count(invoice_line.quantity) desc) as rowno
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 1,2,3
	order by 1, 4 desc
	)
select * from popular_genre where rowno=1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with top_customer as (
	select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	row_number() over(partition by billing_country order by sum(total) desc) as rowno
	from customer
	join invoice on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	order by 4,5 desc
	)
select * from top_customer where rowno=1;