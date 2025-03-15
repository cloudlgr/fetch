import pandas as pd
import json

# Step 1: Ingest the data from a JSON file
with open('data.json', 'r') as file:
    data = json.load(file)

# Step 2: Normalize the receipts into a DataFrame
receipt_df = pd.json_normalize(
    data,
    record_path=None,
    meta=[
        ["_id", "$oid"],
        "bonusPointsEarned",
        "bonusPointsEarnedReason",
        "rewardsReceiptStatus",
        "totalSpent",
        "userId",
        "createDate.$date",
        "dateScanned.$date",
        "finishedDate.$date",
        "modifyDate.$date",
        "pointsAwardedDate.$date",
        "pointsEarned",
        "purchaseDate.$date",
        "purchasedItemCount",
    ]
)

# Step 3: Normalize the items into a separate DataFrame
items_df = pd.json_normalize(
    data,
    record_path="rewardsReceiptItemList",
    meta=[
        ["_id", "$oid"]
    ]
)

# Step 4: Rename columns for both DataFrames
# Rename columns for receipts
receipt_df.rename(
    columns={
        "_id.$oid": "receipt_id",
        "createDate.$date": "createDate",
        "dateScanned.$date": "dateScanned",
        "finishedDate.$date": "finishedDate",
        "modifyDate.$date": "modifyDate",
        "pointsAwardedDate.$date": "pointsAwardedDate",
        "purchaseDate.$date": "purchaseDate",
    },
    inplace=True
)

# Rename columns for items
items_df.rename(columns={"_id.$oid": "receipt_id"}, inplace=True)


# Display the resulting DataFrames
print("Receipt Table:")
print(receipt_df)

print("\nItems Table:")
print(items_df)



# Step 5: Check for and identify data quality issues

# Issue 1: Missing or incomplete values
print("Missing values in receipt_df:")
print(receipt_df.isnull().sum())

print("\nMissing values in items_df:")
print(items_df.isnull().sum())

# Issue 2: Data type inconsistencies
# Check the data types
print("\nData types in receipt_df:")
print(receipt_df.dtypes)

print("\nData types in items_df:")
print(items_df.dtypes)

# Convert numeric fields to appropriate types in both DataFrames
receipt_df["totalSpent"] = pd.to_numeric(receipt_df["totalSpent"], errors="coerce")
receipt_df["pointsEarned"] = pd.to_numeric(receipt_df["pointsEarned"], errors="coerce")
receipt_df["purchasedItemCount"] = pd.to_numeric(receipt_df["purchasedItemCount"], errors="coerce")
items_df["finalPrice"] = pd.to_numeric(items_df["finalPrice"], errors="coerce")
items_df["itemPrice"] = pd.to_numeric(items_df["itemPrice"], errors="coerce")
items_df["quantityPurchased"] = pd.to_numeric(items_df["quantityPurchased"], errors="coerce")

# Issue 3: Duplicates
# Check for duplicate entries in both DataFrames
print("\nDuplicate rows in receipt_df:")
print(receipt_df.duplicated(subset=["receipt_id"]).sum())

print("\nDuplicate rows in items_df:")
print(items_df.duplicated(subset=["receipt_id", "barcode"]).sum())

