# Spec 202: Revenue Dashboard — Requirements

**Status:** Completed
**Phase:** 1.1 (Core Dashboards)
**Complexity:** Medium
**Assignable to:** Sonnet / Junior dev
**Depends on:** Spec 201 (App Skeleton), Spec 102 (Sync running)
**Page:** `/hmbi/revenue`

## Overview

The primary dashboard Hendra will use daily. Shows revenue metrics across all stores with comparison capabilities.

## User Stories

- As Hendra, I want to see today's revenue across all stores at a glance
- As Hendra, I want to compare this week vs last week to spot trends
- As Hendra, I want to drill into a specific store's revenue details
- As Hendra, I want to see revenue breakdown by payment method

## Key Requirements

- Revenue overview cards: today's revenue, transaction count, avg basket
- Revenue by store bar chart (all stores side by side)
- Revenue trend line chart (last 30 days, selectable range)
- Comparison widget (this week vs last week, this month vs last month)
- Store selector dropdown (all stores or specific store)
- Date range picker (preset: today, 7d, 30d, 90d, custom)
- Payment method breakdown (cash vs card vs voucher vs points)
- Mobile-responsive layout (cards stack vertically)

## Data Source

`hmbi.daily_sales_summary`

## Acceptance Criteria

- [x] Dashboard loads efficiently with 30 days of data
- [x] All stores visible with correct revenue numbers
- [x] Comparison shows correct delta (% change)
- [x] Date range picker works, chart updates
- [x] Store selector filters data correctly
- [x] Mobile layout is usable on phone screen
- [x] Empty state shown if no data for selected range
