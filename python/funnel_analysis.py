"""
funnel_analysis.py

Computes conversion rates at each stage of the funnel
(sessions -> product views -> add to cart -> checkout -> purchase),
by month and overall, and highlights where the biggest drop-off is.
This is the Python equivalent of sql/funnel_analysis.sql, useful when
the analysis needs to feed a notebook or a scheduled report instead
of a BI tool.

Usage:
    python python/funnel_analysis.py
"""

import os
import pandas as pd

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")


def load_website():
    return pd.read_csv(os.path.join(DATA_DIR, "website_daily.csv"), parse_dates=["date"])


def funnel_summary(df: pd.DataFrame) -> pd.Series:
    totals = df[["sessions", "product_views", "add_to_cart", "checkout", "purchases", "revenue"]].sum()
    totals["cart_rate_pct"] = round(100 * totals["add_to_cart"] / totals["sessions"], 2)
    totals["checkout_completion_pct"] = round(100 * totals["checkout"] / totals["add_to_cart"], 2)
    totals["purchase_completion_pct"] = round(100 * totals["purchases"] / totals["checkout"], 2)
    totals["overall_conversion_pct"] = round(100 * totals["purchases"] / totals["sessions"], 2)
    totals["revenue_per_session"] = round(totals["revenue"] / totals["sessions"], 2)
    return totals


def monthly_funnel(df: pd.DataFrame) -> pd.DataFrame:
    monthly = df.copy()
    monthly["month"] = monthly["date"].dt.to_period("M").astype(str)
    agg = monthly.groupby("month")[["sessions", "add_to_cart", "checkout", "purchases", "revenue"]].sum()
    agg["conversion_rate_pct"] = round(100 * agg["purchases"] / agg["sessions"], 2)
    agg["checkout_completion_pct"] = round(100 * agg["checkout"] / agg["add_to_cart"], 2)
    return agg.reset_index()


def biggest_drop_off(summary: pd.Series) -> str:
    steps = {
        "sessions -> add_to_cart": 100 - 100 * summary["add_to_cart"] / summary["sessions"],
        "add_to_cart -> checkout": 100 - 100 * summary["checkout"] / summary["add_to_cart"],
        "checkout -> purchase": 100 - 100 * summary["purchases"] / summary["checkout"],
    }
    worst = max(steps, key=steps.get)
    return f"{worst} ({steps[worst]:.1f}% lost at this step)"


def main():
    website = load_website()
    summary = funnel_summary(website)
    print("=== Full-period funnel summary ===")
    print(summary)

    print("\n=== Monthly funnel ===")
    print(monthly_funnel(website).to_string(index=False))

    print("\n=== Biggest drop-off point ===")
    print(biggest_drop_off(summary))


if __name__ == "__main__":
    main()
