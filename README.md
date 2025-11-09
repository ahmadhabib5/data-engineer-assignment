# A. Python Code Challenge
## 1. Load data
``` python
import re
import pandas as pd

df = pd.read_csv('data/soal1.csv') # read data
df.columns = [i.lower() for i in df.columns] # standardize column
print(df.head()) # Show top 5 rows 
``` 

## 2. Calculate Stay_Duration_Hours
``` python
def clean_duration(row):
    """Function to clean duration"""
    result = 0
    if re.search('week(?:s)*', row, flags=re.I):
        temp = re.findall("(\d+)\s*(?=week(?:s)*)", row, flags=re.I)[0]
        result += float(temp) * 7 * 24
    if re.search('day(?:s)*', row, flags=re.I):
        temp = re.findall("(\d+)\s*(?=day(?:s)*)", row, flags=re.I)[0]
        result += float(temp) * 24
    if re.search('hour(?:s)*', row, flags=re.I):
        temp = re.findall("(\d+)\s*(?=hour(?:s)*)", row, flags=re.I)[0]
        result += float(temp)
    return result
df['duration_string'] = df['duration_string'].apply(clean_duration) # apply for each row
print(df.head())
```

## 3. Standardize Guest_Type
```python
def clean_guest_type(row):
    """Function to clean guest type"""
    if re.search('new|first[\s-]time|baru', row, flags=re.I):
        return 'New'
    if re.search('returning|repeat|kembali', row, flags=re.I):
        return 'Returning'
    return row
print(set(df['guest_type'].apply(clean_guest_type)) == {'New', 'Returning'}) # Check the function, have the function worked and value only new & returnting
df['guest_type'] = df['guest_type'].apply(clean_guest_type) # apply the function
print(df.head())
```

## 4. Filter Data
```python
# create temp field for debug result after convert
df['check_in_date_temp'] = pd.to_datetime(df['check_in_date'], errors='coerce')
# Check, is there any null/nan value
print(df[df['check_in_date_temp'].isna()]) # Null/nan value indicate, there is any mismatch date format 
# this row have different format with another rows
# 46	1047	G7046	2024-16-05	4 days, 1 hour	LOC01	New_User	NaT
# Assume the value is a typo so we change 2024-16-05 -> 2024-05-16
df.loc[df['check_in_date'] == '2024-16-05', 'check_in_date'] = '2024-05-16'
# Double check
df['check_in_date_temp'] = pd.to_datetime(df['check_in_date'], errors='coerce')
print(df[df['check_in_date_temp'].isna()])
df['check_in_date'] = pd.to_datetime(df['check_in_date'], errors='coerce') # apply to main field/column
df.drop(columns='check_in_date_temp', inplace=True) # drop temp column
# Filter xxclude any records where the Check_In_Date is before the start of the
# current calendar year (Assume January 1, 2024, for this exercise).
df = df[df['check_in_date'] >= '2024-01-01']
print(df.head())
```

## 5. Save cleaned data
```python
print("Save cleaned data")
df.to_csv("data/cleaned_data_soal1.csv", index=False)
```

## 6. See & run entire python script
```bash
nano "A_Python_Code_Challenge.py"
python "A_Python_Code_Challenge.py"
```

# B. SQL Query Challenges
## 1. Provisioning database, table & sample data (dummy)
1. create docker compose file
```bash
cat <<EOF > docker-compose.yml
version: '1'

services:
  postgres:
    image: citusdata/citus:13.0
    container_name: bobobox_postgres
    environment:
      POSTGRES_USER: \${POSTGRES_USER}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
      POSTGRES_DB: \${POSTGRES_DB}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - ./init:/docker-entrypoint-initdb.d:ro
    networks:
      - shared-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    ports:
      - "5432:5432"

networks:
  shared-network:
EOF
```
2. Create ini script to create table & insert sample data
```bash
cat <<EOF > init/generate.yml
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
EOF
```

3. Run Container
```bash
docker compose up -d
```

## 2. Multi-Table Join Query
```sql
with rating_5 as (
	select r.rating, r.booking_id
	from reviews r
	where r.rating = 5
), -- CTE for prefilter only rating 5
pod as (
	select l.location_name, l.location_id
	from locations l
	where l.type = 'Pod'
), -- CTE for prefilter only pod
cte_bookings as (
	select 
		b.booking_id,
		b.location_id,
		b.guest_id,
		b.booking_date,
		b.total_price,
		check_in_date + duration AS check_out_date,
		LEAD(check_in_date + duration) OVER(partition by guest_id order by (check_in_date + duration) DESC) prev_checkout_date
	from bookings b
) -- CTE to enrich data with prev_checkout_date
select g.guest_name, l.location_name, b.booking_date, b.prev_checkout_date, b.total_price, r.rating from cte_bookings b
inner join rating_5 r 
	on r.booking_id = b.booking_id
INNER join pod l 
	on l.location_id = b.location_id
left join guests g
	on g.guest_id = b.guest_id
order by guest_name desc, check_out_date desc
```

## 3. Aggregation Query
```sql
with cte as (
	select l.city, COUNT(b.booking_id) AS total_booking, AVG(r.rating) as avg_rating from bookings b
	left join reviews r
		on r.booking_id = b.booking_id
	left join locations l 
		on l.location_id = b.location_id
	group by l.city
) select * from cte
where total_booking >= 10 and avg_rating >= 4;
```

# C. Data Analysis Challenges
## Data Insight
1. Load data
```python
# import library
import pandas as pd

# Load data
df = pd.read_csv('data/soal3.csv')
df.columns = [i.lower() for i in df.columns]
print(df.head())
# Filter only success transactions
success = df[df['status'] == 'Success']
```
2. simple EDA
```python
print(success.groupby('device_type').count()[['transaction_id']])
print(success.groupby('device_type').sum('amount_idr'))
print(success.groupby(['device_type', 'transaction_type']).count()[['transaction_id']])
```

3. Result
a. Based on two metrics (transaction count & sum amount) mobile has more transaction than web
b. Customer prefer to use mobile device to do transaction
```markdown
### Num transactions
            transaction_id
device_type                
Mobile                   59
Web                      31

## Sum of amount
             amount_idr
device_type            
Mobile          7947500
Web             4657000
```
c. Mobile apps charge more fees from customer than web apps
```markdown
### Transactions by Device and Type
                              transaction_id
device_type transaction_type                
Mobile      Deposit                       32
            Fee                           13
            Withdrawal                    14
Web         Deposit                       17
            Fee                            5
            Withdrawal                     9
```

## Anomaly Detection
### Box Plot

1. Without Filter  
Menampilkan distribusi keseluruhan nilai `amount_idr`.

```python
import matplotlib.pyplot as plt

df['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)

plt.title("Boxplot of Amount (All Transactions)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_all.png", bbox_inches='tight', dpi=300)
plt.show()
```
2. Filter By transaction_type
```python
import matplotlib.pyplot as plt

deposit = df[df['transaction_type'] == 'Deposit']
fee = df[df['transaction_type'] == 'Fee']
withdrawal = df[df['transaction_type'] == 'Withdrawal']  

deposit['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)
plt.title("Boxplot of Deposit Amount (IDR)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_deposit.png", bbox_inches='tight', dpi=300)
plt.show()

fee['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)
plt.title("Boxplot of Fee Amount (IDR)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_fee.png", bbox_inches='tight', dpi=300)
plt.show()

withdrawal['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)
plt.title("Boxplot of Withdrawal Amount (IDR)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_withdrawal.png", bbox_inches='tight', dpi=300)
plt.show()
```

### IQR
```python
def get_outlier(dataframe):
    q1 = dataframe['amount_idr'].quantile(0.25)
    q3 = dataframe['amount_idr'].quantile(0.75)
    iqr = q3 - q1
    batas_bawah = q1 - 1.5 * iqr
    batas_atas  = q3 + 1.5 * iqr

    outliers = dataframe[(dataframe['amount_idr'] < batas_bawah) | (dataframe['amount_idr'] > batas_atas)]

    print("(outliers)")
    return outliers[['transaction_id','amount_idr']]

out_deposit = get_outlier(deposit)
out_fee = get_outlier(fee)
out_withdrawal = get_outlier(withdrawal)

set_deposit = set(out_deposit['transaction_id'])
set_fee = set(out_fee['transaction_id'])
set_withdrawal = set(out_withdrawal['transaction_id'])

out_per_type = pd.concat([out_deposit, out_fee, out_withdrawal], ignore_index=True)
print(out_per_type)

df['is_anomaly'] = df['transaction_id'].apply(
    lambda x: True if x in set(out_per_type['transaction_id']) else False
)

print(df[df['is_anomaly']])
```

### Result
1. First use boxplot for check, there is any outlier from data
2. Second Identified outlier based on each transaction-type.
2. Use IQR method to get which row that identify as outlier

# D. Database Design
```sql
CREATE TABLE locations (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    address TEXT,
    total_units INT NOT NULL CHECK (total_units > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE units (
    id VARCHAR(15) PRIMARY KEY,
    location_id VARCHAR(10) NOT NULL,
    unit_number VARCHAR(10) NOT NULL,
    unit_type VARCHAR(20) NOT NULL CHECK (unit_type IN ('Pod', 'Cabin')),
    floor_number INT,
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Maintenance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_unit_location FOREIGN KEY (location_id) REFERENCES locations(id),
    CONSTRAINT uk_location_unit UNIQUE (location_id, unit_number)
);


CREATE TABLE sensors (
    id VARCHAR(20) PRIMARY KEY,
    unit_id VARCHAR(15) NOT NULL,
    sensor_type VARCHAR(30) NOT NULL CHECK (sensor_type IN ('Temperature', 'Humidity', 'Occupancy', 'Air Quality')),
    manufacturer VARCHAR(50),
    model VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive', 'Faulty', 'Maintenance')),
    installation_date DATE NOT NULL,
    last_calibration_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sensor_unit FOREIGN KEY (unit_id) REFERENCES units(id)
);


CREATE TABLE engineers (
    id VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    specialization VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Active' CHECK (status IN ('Active', 'Inactive')),
    hire_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE maintenance_records (
    id BIGSERIAL PRIMARY KEY,
    sensor_id VARCHAR(20) NOT NULL,
    engineer_id VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('Routine', 'Repair', 'Calibration', 'Replacement', 'Emergency')),
    description TEXT NOT NULL,
    duration_hours DECIMAL(4,2),
    cost DECIMAL(10,2),
    next_maintenance_date DATE,
    status VARCHAR(20) DEFAULT 'Completed' CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_maint_sensor FOREIGN KEY (sensor_id) REFERENCES sensors(id),
    CONSTRAINT fk_maint_engineer FOREIGN KEY (engineer_id) REFERENCES engineers(id)
);


CREATE INDEX idx_units_location ON units(location_id);
CREATE INDEX idx_sensors_unit ON sensors(unit_id);
CREATE INDEX idx_sensors_type ON sensors(sensor_type);
CREATE INDEX idx_sensors_status ON sensors(status);
CREATE INDEX idx_maint_sensor ON maintenance_records(sensor_id);
CREATE INDEX idx_maint_engineer ON maintenance_records(engineer_id);
CREATE INDEX idx_maint_date ON maintenance_records(date);
```

# E. Run docker image
```bash
docker build -t assignment_python . && docker run --rm assignment_python
```