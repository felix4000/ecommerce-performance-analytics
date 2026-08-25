# Business Recommendations

Each recommendation below is tied to a specific number produced by the SQL
and Python in this repo, not a generic best practice. Source query/notebook
cell is noted for each one.

---

### 1. Mobile drives more traffic than desktop but converts at less than half the rate

**Finding.** Mobile sessions (377K) outnumber desktop (298K) over the period,
but mobile converts at 3.13% versus 6.60% on desktop, and mobile checkout
completion (cart -> checkout started) is 51.7% versus 69.1% on desktop.
*(source: `data/website_sessions_by_segment.csv`, aggregated by device — see
`customer-conversion-analytics` repo for the full breakdown)*

**Business impact.** If mobile converted at even 80% of the desktop rate
(5.3% instead of 3.13%), the same 377K mobile sessions would produce roughly
7,800 additional purchases over the period at the current AOV, without
spending a euro more on acquisition.

**Recommendation.** Audit the mobile checkout flow specifically (not the
mobile site in general) — form length, payment method visibility, and
autofill/keyboard behaviour on the cart-to-checkout step, since that is
where the gap opens up, not earlier in the funnel.

**Expected outcome.** Closing even half the conversion gap between mobile
and desktop would be the single largest lever in this dataset, larger than
any acquisition-channel change, because it converts existing traffic instead
of buying more of it.

---

### 2. The biggest funnel drop-off happens before add-to-cart, not at checkout

**Finding.** 90.1% of sessions never add a product to cart. Once someone
starts checkout, 67.7% complete the purchase — checkout itself is not the
weak point. *(source: `sql/funnel_analysis.sql` query 4, `notebooks/01_...` section 3)*

**Business impact.** Effort spent optimising checkout UX has a much smaller
ceiling than effort spent on product findability and product-page relevance,
because checkout is already converting well relative to the traffic that
reaches it.

**Recommendation.** Prioritise search/filter relevance, product-page content
(fitment/compatibility clarity, images, stock visibility) and internal
linking from category to product pages over further checkout redesign work.

**Expected outcome.** A conservative 1-point improvement in the
sessions-to-cart rate (from 9.9% to 10.9%) would add roughly 2,800 add-to-cart
events over the period, flowing through the existing checkout completion
rate.

---

### 3. Revenue is concentrated in a small share of the catalogue

**Finding.** The top 10% of SKUs by revenue (15 of 150 products) account for
30.6% of total revenue in the order sample. *(source: `sql/sales_analysis.sql`
query 4)*

**Business impact.** SEO, merchandising, and stock-availability effort
spread evenly across 150 SKUs is diluted; a shortlist-based approach on the
top revenue drivers would touch the SKUs that actually move the P&L.

**Recommendation.** Build a standing "top 20 by revenue" watchlist (query 3
in `sql/sales_analysis.sql`) reviewed monthly, and route stock-risk
alerts (query 6, demand-to-stock ratio) specifically for that list first.

**Expected outcome.** Fewer stockouts on the SKUs that matter most for
revenue, and SEO/content effort concentrated where it has the largest
addressable upside.

---

### 4. Organic search is the largest channel, and referral has the highest conversion rate

**Finding.** Organic search leads on both volume and revenue share (36% of
revenue). Referral traffic, while the smallest channel by volume, converts
highest per session (4.82%) of any channel. *(source: `sql/acquisition_analysis.sql`,
`data/website_sessions_by_segment.csv`)*

**Business impact.** The channel mix is healthy (not overly dependent on paid),
but referral is under-invested relative to how well it converts.

**Recommendation.** Identify the specific referral sources driving that
conversion rate (partner sites, comparison engines, forums) and formalise
whichever ones are working — most referral traffic is undirected until
someone looks at where it actually comes from.

**Expected outcome.** Referral is unlikely to become a top-3 channel by
volume, but a deliberate push could meaningfully lift its contribution given
its conversion efficiency, at a lower incremental cost than paid search.

---

## About the confidential figures

The campaign scale figures in my GitHub profile README (30+ campaigns,
7 languages, ~€20K monthly budget, ~19x average ROAS) describe my actual
professional experience managing paid acquisition, not this synthetic
dataset. They are not recalculated from any file in this repository.
