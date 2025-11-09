# Import Library
import pandas as pd
import matplotlib.pyplot as plt
# Load Data
df = pd.read_csv('data/soal3.csv')
df.columns = [i.lower() for i in df.columns]
df.head()
# Check unique of device
print("Check unique of device:", set(df['device_type']))
# Check unique of status
print("Check unique of status:", set(df['status']))

# Filter only success transactions
success = df[df['status'] == 'Success']
print("success transactions:\n", success.head())

print("Num transactions:\n", success.groupby('device_type').count()[['transaction_id']])

print("Sum of amount:\n", success.groupby('device_type').sum('amount_idr'))

print("Transactions by Device and Type:\n", success.groupby(['device_type', 'transaction_type']).count()[['transaction_id']])

print("Higher location:\n", success.groupby(['device_type', 'location_id']).count()[['transaction_id']])

print("amount_idr type: ", df['amount_idr'].dtype)

df['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)

plt.title("Boxplot of Amount (All Transactions)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_all.png", bbox_inches='tight', dpi=300)

deposit = df[df['transaction_type'] == 'Deposit']
fee = df[df['transaction_type'] == 'Fee']
withdrawal = df[df['transaction_type'] == 'Withdrawal']  

deposit['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)
plt.title("Boxplot of Deposit Amount (IDR)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_deposit.png", bbox_inches='tight', dpi=300)

fee['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)
plt.title("Boxplot of Fee Amount (IDR)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_fee.png", bbox_inches='tight', dpi=300)

withdrawal['amount_idr'].plot.box(vert=False, figsize=(8,3), grid=True)
plt.title("Boxplot of Withdrawal Amount (IDR)")
plt.xlabel("Amount (IDR)")
plt.savefig("images/boxplot_withdrawal.png", bbox_inches='tight', dpi=300)

# Anomaly Detection
deposit = df[df['transaction_type'] == 'Deposit']
fee = df[df['transaction_type'] == 'Fee']
withdrawal = df[df['transaction_type'] == 'Withdrawal']

def get_outlier(dataframe):
    q1 = dataframe['amount_idr'].quantile(0.25)
    q3 = dataframe['amount_idr'].quantile(0.75)
    iqr = q3 - q1
    batas_bawah = q1 - 1.5 * iqr
    batas_atas  = q3 + 1.5 * iqr

    outliers = dataframe[(dataframe['amount_idr'] < batas_bawah) | (dataframe['amount_idr'] > batas_atas)]

    return outliers[['transaction_id','amount_idr']]

out_deposit = get_outlier(deposit)
out_fee = get_outlier(fee)
out_withdrawal = get_outlier(withdrawal)

set_deposit = set(out_deposit['transaction_id'])
set_fee = set(out_fee['transaction_id'])
set_withdrawal = set(out_withdrawal['transaction_id'])

out_per_type = pd.concat([out_deposit, out_fee, out_withdrawal], ignore_index=True)

df['is_anomaly'] = df['transaction_id'].apply(
    lambda x: True if x in set(out_per_type['transaction_id']) else False
)

print("Transaction id detected as an anomaly:\n", df[df['is_anomaly']])
