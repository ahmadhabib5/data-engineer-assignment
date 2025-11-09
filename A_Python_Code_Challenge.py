# Import Library
import re
import pandas as pd

# Load Data
df = pd.read_csv('data/soal1.csv')
df.columns = [i.lower() for i in df.columns]
df.head()

# Print Data type
print("Data Type for data soal1")
print(df.dtypes)

# Calculate Stay_Duration_Hours
def clean_duration(row):
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
df['duration_string'] = df['duration_string'].apply(clean_duration)
print("Calculate Stay_Duration_Hours")
print(df.head())

# Standardize Guest_Type
print("\nStandardize Guest_Type")
def clean_guest_type(row):
    if re.search('new|first[\s-]time|baru', row, flags=re.I):
        return 'New'
    if re.search('returning|repeat|kembali', row, flags=re.I):
        return 'Returning'
    return row
print("Check the function, have the function worked and value only new & returnting: ", set(df['guest_type'].apply(clean_guest_type)) == {'New', 'Returning'})
df['guest_type'] = df['guest_type'].apply(clean_guest_type)
print(df.head())

# Filter Data
print("Filter Data")
df['check_in_date_temp'] = pd.to_datetime(df['check_in_date'], errors='coerce')
print("Missmatch date format",df[df['check_in_date_temp'].isna()])
# asumsi typo 2024-16-05 -> 2024-05-16
df.loc[df['check_in_date'] == '2024-16-05', 'check_in_date'] = '2024-05-16'
df['check_in_date_temp'] = pd.to_datetime(df['check_in_date'], errors='coerce')
print("Double Check after clean missmatch format", df[df['check_in_date_temp'].isna()])
df['check_in_date'] = pd.to_datetime(df['check_in_date'], errors='coerce')
df.drop(columns='check_in_date_temp', inplace=True)
df = df[df['check_in_date'] >= '2024-01-01']
print(df.head())

# Save cleaned data
print("Save cleaned data")
df.to_csv("data/cleaned_data_soal1.csv", index=False)