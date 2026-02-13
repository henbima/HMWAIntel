# Spec 202: Revenue Dashboard — Design

## Architecture

```
/hmbi/revenue
  ├── Service Layer
  │    ├── getRevenueSummary(dateRange, storeCode?)
  │    └── getRevenueComparison(date, compareType)
  ├── Components
  │    ├── RevenueOverviewCards (today's totals)
  │    ├── RevenueByStoreChart (bar chart)
  │    ├── RevenueTrendChart (line chart, 30d)
  │    ├── ComparisonWidget (week/month delta)
  │    ├── PaymentBreakdown (pie/donut chart)
  │    ├── StoreSelector (dropdown)
  │    └── DateRangePicker (presets + custom)
  └── Hooks
       └── useRevenueDashboard(filters)
```

## Key Decisions

1. **Recharts** for charts — lightweight, React-native, good for dashboards
2. **Service functions** in `src/services/revenue.ts` — encapsulate Supabase queries
3. **Client-side filtering** for small datasets, server-side for large ranges
4. **Percentage comparison** — (current - previous) / previous x 100

## Chart Specifications

- **Bar chart:** horizontal bars, one per store, sorted by revenue descending
- **Line chart:** date on X axis, revenue on Y, with area fill
- **Comparison:** green arrow up / red arrow down with % change
- **Payment breakdown:** donut chart with legend
