# Methodology

## Data

All data in this repository is synthetic. It was generated with a Python
script (not included, to keep the repo focused on the analysis rather than
the generator) that builds internally consistent tables: order revenue
respects product pricing, channel revenue shares in `orders.csv` and
`website_daily.csv` line up with the shares implied in `seo_performance.csv`
and `google_ads.csv`, and every order references a real product and a real
customer. It is designed to behave like a real extract, including realistic
noise, seasonality and seven-day weekly patterns, so the analysis techniques
transfer directly to a production dataset.

No customer names, addresses, emails, prices from a real supplier contract,
or real business figures from any employer appear anywhere in this
repository. The store name "TrailHub Parts" is fictional.

## Tables

| Table | Grain | Rows | Notes |
|---|---|---|---|
| `products.csv` | 1 row per SKU | 150 | category, brand, price, cost, stock, OEM reference |
| `customers.csv` | 1 row per customer | 320 | country, device, B2B/B2C, repeat flag |
| `orders.csv` | 1 row per order | 650 | a representative sample of order-level detail, not the full year of transactions |
| `website_daily.csv` | 1 row per day | 365 | full-site funnel: sessions through purchase, and revenue |

`orders.csv` is a sample extract, not a reconciliation of `website_daily.csv`.
In a real analytics stack the two would come from different systems (order
management vs. web analytics) and rarely tie out to the last unit without
a dedicated reconciliation step — that mismatch is intentional and realistic,
not a bug.

## Approach

1. **Data quality first** (`python/data_cleaning.py`): missing values,
   duplicates, referential integrity between orders/products/customers,
   and an IQR-based outlier check on order revenue.
2. **Sales analysis** (`sql/sales_analysis.sql`, notebook section 2):
   revenue, margin, category mix, product concentration.
3. **Customer analysis** (`sql/customer_analysis.sql`): value by segment,
   country, device, a simple RFM view, and acquisition-channel quality.
4. **Funnel analysis** (`sql/funnel_analysis.sql`, `python/funnel_analysis.py`):
   conversion rate at each step, monthly trend, weekday vs. weekend behaviour,
   and where the biggest single drop-off sits.
5. **Acquisition analysis** (`sql/acquisition_analysis.sql`): channel mix,
   trend, and how channels perform across customer segments.
6. **Findings -> recommendations** (`docs/business_recommendations.md`):
   every recommendation is tied to a specific number from the analysis above,
   not a generic best practice.

## Tools

SQL written for SQLite/PostgreSQL-compatible syntax (window functions,
`strftime`/`NTILE`), runnable against the CSVs after loading them into any
relational database, or against an equivalent pandas pipeline (see the
`python/` scripts, which reproduce the same logic without a database).

## Limitations

- A synthetic dataset cannot fully reproduce the correlations of real
  customer behaviour (a real catalogue would show far more structure between
  compatibility/fitment, seasonality, and specific promotions).
- The dashboard mockups in `/dashboard` are SVG recreations of a Power BI
  layout, not exported `.pbix` screenshots — built this way so the concept
  is inspectable directly on GitHub without opening Power BI Desktop.
- Figures here are illustrative of method, not a claim about any real
  company's performance. Professional acquisition figures referenced in my
  profile README (campaign count, budget, ROAS) describe my actual work
  experience, not this dataset.
