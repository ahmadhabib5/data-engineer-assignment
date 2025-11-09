DROP TABLE IF EXISTS public.Reviews CASCADE;
DROP TABLE IF EXISTS public.Bookings CASCADE;
DROP TABLE IF EXISTS public.Guests CASCADE;
DROP TABLE IF EXISTS public.Locations CASCADE;

CREATE TABLE public.Locations (
    Location_ID BIGSERIAL PRIMARY KEY,
    Location_Name VARCHAR NOT NULL,
    City VARCHAR NOT NULL,
    Type VARCHAR NOT NULL CHECK (Type IN ('Pod', 'Cabin')),
    Total_Units INT NOT NULL
);

CREATE TABLE public.Guests (
    Guest_ID BIGSERIAL PRIMARY KEY,
    Guest_Name VARCHAR NOT NULL,
    Registration_Date DATE
);

CREATE TABLE public.Bookings (
    Booking_ID BIGSERIAL PRIMARY KEY,
    Guest_ID BIGINT NOT NULL,
    Location_ID BIGINT NOT NULL,
    Booking_Date DATE,
    Check_In_Date DATE,
    Duration INT,
    Total_Price DECIMAL,
    CONSTRAINT fk_bookings_guest FOREIGN KEY (Guest_ID) REFERENCES public.Guests(Guest_ID),
    CONSTRAINT fk_bookings_location FOREIGN KEY (Location_ID) REFERENCES public.Locations(Location_ID)
);

CREATE TABLE public.Reviews (
    Review_ID BIGSERIAL PRIMARY KEY,
    Booking_ID BIGINT NOT NULL,
    Rating INT,
    Comment TEXT,
    Review_Date DATE,
    CONSTRAINT fk_reviews_booking FOREIGN KEY (Booking_ID) REFERENCES public.Bookings(Booking_ID)
);

INSERT INTO public.Locations (Location_Name, City, Type, Total_Units) VALUES
('Bobobox Pods Jakarta Pusat', 'Jakarta', 'Pod', 50),
('Bobobox Cabin Surabaya', 'Surabaya', 'Cabin', 120),
('Bobobox Pods Bali', 'Bali', 'Pod', 200),
('Bobobox Cabin Bandung', 'Bandung', 'Cabin', 25),
('Bobobox Pods Medan', 'Medan', 'Pod', 80),
('Bobobox Cabin Lombok', 'Lombok', 'Cabin', 35),
('Bobobox Pods Semarang', 'Semarang', 'Pod', 95),
('Bobobox Cabin Denpasar', 'Denpasar', 'Cabin', 150),
('Bobobox Pods Yogyakarta', 'Yogyakarta', 'Pod', 20),
('Bobobox Cabin Makassar', 'Makassar', 'Cabin', 60),
('Bobobox Pods Palembang', 'Palembang', 'Pod', 40),
('Bobobox Cabin Tangerang', 'Tangerang', 'Cabin', 100),
('Bobobox Pods Depok', 'Depok', 'Pod', 75),
('Bobobox Cabin Bogor', 'Bogor', 'Cabin', 30),
('Bobobox Pods Malang', 'Malang', 'Pod', 55),
('Bobobox Cabin Jakarta Selatan', 'Jakarta', 'Cabin', 45),
('Bobobox Pods Surabaya Timur', 'Surabaya', 'Pod', 110),
('Bobobox Cabin Bali Selatan', 'Bali', 'Cabin', 180),
('Bobobox Pods Bandung Utara', 'Bandung', 'Pod', 28),
('Bobobox Cabin Medan Timur', 'Medan', 'Cabin', 70),
('Bobobox Pods Lombok Barat', 'Lombok', 'Pod', 32),
('Bobobox Cabin Semarang Tengah', 'Semarang', 'Cabin', 88),
('Bobobox Pods Denpasar Utara', 'Denpasar', 'Pod', 140),
('Bobobox Cabin Yogyakarta Selatan', 'Yogyakarta', 'Cabin', 18),
('Bobobox Pods Makassar Pusat', 'Makassar', 'Pod', 65),
('Bobobox Cabin Palembang Ilir', 'Palembang', 'Cabin', 38),
('Bobobox Pods Tangerang Selatan', 'Tangerang', 'Pod', 92),
('Bobobox Cabin Depok Timur', 'Depok', 'Cabin', 68),
('Bobobox Pods Bogor Tengah', 'Bogor', 'Pod', 24),
('Bobobox Cabin Malang Kota', 'Malang', 'Cabin', 58),
('Bobobox Pods Jakarta Barat', 'Jakarta', 'Pod', 42),
('Bobobox Cabin Surabaya Pusat', 'Surabaya', 'Cabin', 105),
('Bobobox Pods Bali Utara', 'Bali', 'Pod', 195),
('Bobobox Cabin Bandung Selatan', 'Bandung', 'Cabin', 26),
('Bobobox Pods Medan Kota', 'Medan', 'Pod', 75),
('Bobobox Cabin Lombok Timur', 'Lombok', 'Cabin', 36),
('Bobobox Pods Semarang Barat', 'Semarang', 'Pod', 90),
('Bobobox Cabin Denpasar Selatan', 'Denpasar', 'Cabin', 145),
('Bobobox Pods Yogyakarta Utara', 'Yogyakarta', 'Pod', 22),
('Bobobox Cabin Makassar Timur', 'Makassar', 'Cabin', 62),
('Bobobox Pods Palembang Ulu', 'Palembang', 'Pod', 44),
('Bobobox Cabin Tangerang Kota', 'Tangerang', 'Cabin', 98),
('Bobobox Pods Depok Barat', 'Depok', 'Pod', 72),
('Bobobox Cabin Bogor Barat', 'Bogor', 'Cabin', 27),
('Bobobox Pods Malang Selatan', 'Malang', 'Pod', 52),
('Bobobox Cabin Jakarta Timur', 'Jakarta', 'Cabin', 48),
('Bobobox Pods Surabaya Barat', 'Surabaya', 'Pod', 115),
('Bobobox Cabin Bali Timur', 'Bali', 'Cabin', 175),
('Bobobox Pods Bandung Timur', 'Bandung', 'Pod', 29),
('Bobobox Cabin Medan Selatan', 'Medan', 'Cabin', 68);

INSERT INTO public.Locations (Location_Name, City, Type, Total_Units)
SELECT 
    'Bobobox ' || 
    (ARRAY['Pods', 'Cabin'])[floor(random() * 2 + 1)] || ' ' ||
    (ARRAY['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Bali', 'Lombok', 'Yogyakarta', 'Semarang'])[floor(random() * 8 + 1)] || ' ' ||
    generate_series,
    (ARRAY['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Bali', 'Lombok', 'Yogyakarta', 'Semarang'])[floor(random() * 8 + 1)],
    (ARRAY['Pod', 'Cabin'])[floor(random() * 2 + 1)],
    floor(random() * 190 + 10)::INT
FROM generate_series(51, 150);

INSERT INTO public.Guests (Guest_Name, Registration_Date) VALUES
('Budi Santoso', '2023-01-15'),
('Ani Wijaya', '2023-02-20'),
('John Smith', '2023-03-10'),
('Sarah Johnson', '2023-04-05'),
('Ahmad Rahman', '2023-05-12'),
('Siti Nurhaliza', '2023-06-18'),
('David Lee', '2023-07-22'),
('Maria Garcia', '2023-08-30'),
('Rizky Pratama', '2023-09-14'),
('Dewi Lestari', '2023-10-08'),
('Michael Chen', '2023-11-25'),
('Lisa Anderson', '2023-12-03'),
('Agus Susanto', '2024-01-17'),
('Rina Kartika', '2024-02-21'),
('Robert Brown', '2024-03-11'),
('Emma Wilson', '2024-04-06'),
('Hendra Gunawan', '2024-05-13'),
('Nina Marlina', '2024-06-19'),
('James Taylor', '2024-07-23'),
('Sophie Martin', '2024-08-31'),
('Bambang Suryadi', '2024-09-15'),
('Indah Permata', '2024-10-09'),
('Daniel Kim', '2024-11-01'),
('Jessica Liu', '2024-11-08'),
('Faisal Malik', '2023-01-20'),
('Laila Hassan', '2023-02-25'),
('Chris Evans', '2023-03-15'),
('Rachel Green', '2023-04-10'),
('Doni Setiawan', '2023-05-17'),
('Maya Sari', '2023-06-23');

INSERT INTO public.Guests (Guest_Name, Registration_Date)
SELECT 
    'Guest ' || generate_series,
    DATE '2020-01-01' + (random() * 1700)::INT
FROM generate_series(31, 200);

INSERT INTO public.Bookings (Guest_ID, Location_ID, Booking_Date, Check_In_Date, Duration, Total_Price) VALUES
(1, 1, '2024-01-10', '2024-01-15', 3, 450000),
(2, 3, '2024-01-12', '2024-01-20', 5, 1250000),
(3, 5, '2024-01-15', '2024-01-22', 2, 320000),
(4, 2, '2024-01-18', '2024-01-25', 4, 780000),
(5, 8, '2024-01-20', '2024-01-28', 7, 2100000),
(6, 10, '2024-01-22', '2024-02-01', 3, 540000),
(7, 12, '2024-01-25', '2024-02-05', 6, 1560000),
(8, 15, '2024-01-28', '2024-02-08', 4, 640000),
(9, 18, '2024-02-01', '2024-02-10', 5, 1350000),
(10, 20, '2024-02-03', '2024-02-12', 3, 480000),
(11, 22, '2024-02-05', '2024-02-15', 8, 2400000),
(12, 25, '2024-02-08', '2024-02-18', 2, 360000),
(13, 28, '2024-02-10', '2024-02-20', 5, 1150000),
(14, 30, '2024-02-12', '2024-02-22', 4, 720000),
(15, 32, '2024-02-15', '2024-02-25', 6, 1620000),
(16, 35, '2024-02-18', '2024-02-28', 3, 570000),
(17, 38, '2024-02-20', '2024-03-02', 7, 1960000),
(18, 40, '2024-02-22', '2024-03-05', 4, 680000),
(19, 42, '2024-02-25', '2024-03-08', 5, 1300000),
(20, 45, '2024-02-28', '2024-03-10', 3, 510000);

INSERT INTO public.Bookings (Guest_ID, Location_ID, Booking_Date, Check_In_Date, Duration, Total_Price)
SELECT 
    floor(random() * 200 + 1)::BIGINT AS guest_id,
    floor(random() * 150 + 1)::BIGINT AS location_id,
    check_in_date - floor(random() * 60 + 1)::INT AS booking_date,
    check_in_date,
    duration,
    (random() * 450000 + 150000)::DECIMAL * duration AS total_price
FROM (
    SELECT 
        DATE '2023-01-01' + (random() * 1040)::INT AS check_in_date,
        floor(random() * 13 + 1)::INT AS duration
    FROM generate_series(21, 500)
) AS generated_dates;

INSERT INTO public.Reviews (Booking_ID, Rating, Comment, Review_Date) VALUES
(1, 5, 'Pod sangat nyaman dan bersih!', '2024-01-18'),
(2, 4, 'Cabin luas, pelayanan memuaskan!', '2024-01-26'),
(3, 5, 'Lokasi strategis dan fasilitas lengkap.', '2024-01-25'),
(4, 3, 'Harga sebanding dengan kualitas.', '2024-01-30'),
(5, 5, 'Pasti akan kembali lagi!', '2024-02-05'),
(6, 4, 'Staff sangat ramah dan helpful.', '2024-02-05'),
(7, 5, 'Konsep pod sangat modern!', '2024-02-12'),
(8, 4, 'Cabin bersih, sangat puas!', '2024-02-13'),
(9, 5, 'Great experience with Bobobox!', '2024-02-16'),
(10, 3, 'Good value for money.', '2024-02-16'),
(11, 2, 'Perlu perbaikan AC di pod.', '2024-02-24'),
(12, 4, 'Pelayanan bisa ditingkatkan.', '2024-02-21'),
(13, 5, 'Fasilitas sesuai ekspektasi!', '2024-02-26'),
(14, 3, 'Harga cukup kompetitif.', '2024-02-27'),
(15, 5, 'Lokasi dekat stasiun.', '2024-03-04'),
(16, 4, 'AC dingin, tempat nyaman.', '2024-03-04'),
(17, 5, 'Wifi cepat untuk kerja!', '2024-03-10'),
(18, 4, 'Privacy di pod sangat bagus!', '2024-03-10'),
(19, 5, 'Very clean Bobobox!', '2024-03-14'),
(20, 4, 'Recommended untuk solo traveler!', '2024-03-14');

INSERT INTO public.Reviews (Booking_ID, Rating, Comment, Review_Date)
SELECT 
    b.Booking_ID,
    CASE 
        WHEN rand_val < 0.45 THEN 5
        WHEN rand_val < 0.80 THEN 4
        WHEN rand_val < 0.95 THEN 3
        WHEN rand_val < 0.98 THEN 2
        ELSE 1
    END AS rating,
    (ARRAY[
        'Pod sangat nyaman!',
        'Cabin luas dan bersih!',
        'Lokasi strategis.',
        'Harga terjangkau.',
        'Sangat recommended!',
        'Staff ramah.',
        'Konsep pod modern.',
        'Privacy terjaga.',
        'Great Bobobox experience!',
        'Value for money!'
    ])[floor(random() * 10 + 1)] AS comment,
    b.Check_In_Date + b.Duration + floor(random() * 7)::INT AS review_date
FROM (
    SELECT 
        Booking_ID, 
        Check_In_Date, 
        Duration,
        random() AS rand_val,
        ROW_NUMBER() OVER (ORDER BY random()) as rn
    FROM public.Bookings
) b
WHERE b.rn BETWEEN 21 AND 250;