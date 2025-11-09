-- 2. Multi-Table Join Query
with rating_5 as (
	select r.rating, r.booking_id
	from reviews r
	where r.rating = 5
),
pod as (
	select l.location_name, l.location_id
	from locations l
	where l.type = 'Pod'
),
cte_bookings as (
	select 
		b.booking_id,
		b.location_id,
		b.guest_id,
		b.booking_date,
		b.total_price,
		b.check_in_date,
		b.duration,
		check_in_date + duration AS check_out_date,
		LEAD(check_in_date + duration) OVER(partition by guest_id order by (check_in_date + duration) DESC) prev_checkout_date
	from bookings b
)
select g.guest_name, l.location_name, b.booking_date, b.check_in_date, b.duration, b.check_out_date, b.prev_checkout_date, b.total_price, r.rating from cte_bookings b
inner join rating_5 r 
	on r.booking_id = b.booking_id
INNER join pod l 
	on l.location_id = b.location_id
left join guests g
	on g.guest_id = b.guest_id
order by guest_name desc, check_out_date desc;

-- 3. Aggregation Query
with cte as (
	select l.city, COUNT(b.booking_id) AS total_booking, AVG(r.rating) as avg_rating from bookings b
	left join reviews r
		on r.booking_id = b.booking_id
	left join locations l 
		on l.location_id = b.location_id
	group by l.city
) select * from cte
where total_booking >= 10 and avg_rating >= 4;
