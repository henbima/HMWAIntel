# Spec 202: Revenue Dashboard — Tasks

**Status:** Completed

### Phase 1: Service Layer

#### - [x] Task 1.1: Create revenue service functions
**Delegate to:** Sonnet
**File:** `src/modules/revenue/services/revenueService.ts`

**Acceptance Criteria:**
- [x] getRevenueSummary(dateRange, storeCode?) returns aggregated data
- [x] getRevenueComparison(date, compareType) returns current vs previous period

**Commit:** `feat(202): create revenue service functions`

### Phase 2: Components

#### - [x] Task 2.1: Build revenue overview cards
**Delegate to:** Sonnet
**File:** `src/modules/revenue/components/RevenueOverviewCards.tsx`

**Acceptance Criteria:**
- [x] Shows today's revenue, transaction count, avg basket value
- [x] Shows delta vs yesterday

**Commit:** `feat(202): build revenue overview cards`

#### - [x] Task 2.2: Build revenue by store bar chart
**Delegate to:** Sonnet
**File:** `src/modules/revenue/components/RevenueByStoreChart.tsx`

**Acceptance Criteria:**
- [x] All stores displayed side by side
- [x] Sorted by revenue descending

**Commit:** `feat(202): build revenue by store chart`

#### - [x] Task 2.3: Build revenue trend line chart
**Delegate to:** Sonnet
**File:** `src/modules/revenue/components/RevenueTrendChart.tsx`

**Acceptance Criteria:**
- [x] Last 30 days by default
- [x] Updates with date range picker

**Commit:** `feat(202): build revenue trend chart`

#### - [x] Task 2.4: Build comparison widget
**Delegate to:** Sonnet
**File:** `src/modules/revenue/components/ComparisonWidget.tsx`

**Acceptance Criteria:**
- [x] This week vs last week
- [x] This month vs last month
- [x] Shows % change with color coding

**Commit:** `feat(202): build comparison widget`

#### - [x] Task 2.5: Build payment method breakdown
**Delegate to:** Sonnet
**File:** `src/modules/revenue/components/PaymentBreakdown.tsx`

**Acceptance Criteria:**
- [x] Donut chart: cash, card, voucher, points
- [x] Updates with store/date filters

**Commit:** `feat(202): build payment breakdown chart`

### Phase 3: Filters & Integration

#### - [x] Task 3.1: Add store selector and date range picker
**Delegate to:** Sonnet
**File:** `src/shared/components/StoreSelector.tsx` & `src/shared/components/DateRangePicker.tsx`

**Acceptance Criteria:**
- [x] Store selector with "All stores" + individual stores
- [x] Date range presets: today, 7d, 30d, 90d, custom

**Commit:** `feat(202): add store and date filters`

#### - [x] Task 3.2: Assemble revenue dashboard page
**Delegate to:** Sonnet
**File:** `src/modules/revenue/components/RevenueDashboard.tsx`

**Acceptance Criteria:**
- [x] All components wired up with shared filters
- [x] Mobile-responsive layout
- [x] Empty state for no data
- [x] Loads efficiently

**Commit:** `feat(202): assemble revenue dashboard page`

## Completion Checklist
- [x] Dashboard loads efficiently
- [x] All stores visible with correct numbers
- [x] Comparison shows correct % change
- [x] Filters work correctly
- [x] Mobile layout usable
