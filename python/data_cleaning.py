"""
data_cleaning.py

Loads the raw synthetic datasets, checks for the usual data quality
problems (missing values, duplicates, outliers, referential integrity
between orders/products/customers) and writes cleaned versions to
data/processed/. This mirrors the first step of any real analysis:
you don't trust a dataset until you've checked it.

Usage:
    python python/data_cleaning.py
"""

import os
import pandas as pd
import numpy as np

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
RAW = DATA_DIR
PROCESSED = os.path.join(DATA_DIR, "processed")


def load_raw():
    products = pd.read_csv(os.path.join(RAW, "products.csv"))
    customers = pd.read_csv(os.path.join(RAW, "customers.csv"))
    orders = pd.read_csv(os.path.join(RAW, "orders.csv"), parse_dates=["order_date"])
    website = pd.read_csv(os.path.join(RAW, "website_daily.csv"), parse_dates=["date"])
    return products, customers, orders, website


def report_quality(name, df):
    print(f"\n--- {name} ---")
    print("rows:", len(df))
    print("missing values per column:\n", df.isna().sum()[df.isna().sum() > 0])
    print("duplicate rows:", df.duplicated().sum())


def check_referential_integrity(orders, products, customers):
    orphan_products = orders.loc[~orders["product_id"].isin(products["product_id"])]
    orphan_customers = orders.loc[~orders["customer_id"].isin(customers["customer_id"])]
    print("\n--- referential integrity ---")
    print("orders referencing unknown product_id:", len(orphan_products))
    print("orders referencing unknown customer_id:", len(orphan_customers))
    return orphan_products, orphan_customers


def flag_outliers(orders):
    """Flag order revenue values more than 3 std deviations from the mean
    per product category, rather than a single global threshold."""
    merged = orders.copy()
    q1, q3 = merged["revenue"].quantile([0.25, 0.75])
    iqr = q3 - q1
    lower, upper = q1 - 1.5 * iqr, q3 + 1.5 * iqr
    outliers = merged[(merged["revenue"] < lower) | (merged["revenue"] > upper)]
    print("\n--- outlier check (IQR method on order revenue) ---")
    print(f"bounds: [{lower:.2f}, {upper:.2f}]")
    print("flagged rows:", len(outliers))
    return outliers


def clean_orders(orders):
    before = len(orders)
    orders = orders.drop_duplicates(subset=["order_id"])
    orders = orders[orders["quantity"] > 0]
    orders = orders[orders["revenue"] > 0]
    after = len(orders)
    print(f"\norders cleaned: {before} -> {after} rows ({before - after} dropped)")
    return orders


def main():
    products, customers, orders, website = load_raw()

    for name, df in [("products", products), ("customers", customers),
                      ("orders", orders), ("website_daily", website)]:
        report_quality(name, df)

    check_referential_integrity(orders, products, customers)
    flag_outliers(orders)
    orders_clean = clean_orders(orders)

    os.makedirs(PROCESSED, exist_ok=True)
    products.to_csv(os.path.join(PROCESSED, "products_clean.csv"), index=False)
    customers.to_csv(os.path.join(PROCESSED, "customers_clean.csv"), index=False)
    orders_clean.to_csv(os.path.join(PROCESSED, "orders_clean.csv"), index=False)
    website.to_csv(os.path.join(PROCESSED, "website_daily_clean.csv"), index=False)
    print("\nClean files written to data/processed/")


if __name__ == "__main__":
    main()
