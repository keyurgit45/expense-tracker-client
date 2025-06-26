# Feature Specification: Smart Suggestion Card

## Overview
An intelligent, context-aware card that provides personalized financial insights and quick access to analytics features based on user's transaction data and behavioral patterns.

## User Experience

### Card Design
- **Position**: Between Income/Expense card and Transactions list
- **Margin**: 20px horizontal padding
- **Height**: Dynamic based on content (~120px)
- **Background**: Gradient from `surface1` to `surface2`
- **Border**: 1px subtle border with 16px radius

### Content Structure
```
[Icon] [Title]
       [Description]
─────────────────────
[Action Text]     [→]
```

## Suggestion Logic

### 1. Spending Alerts
**Trigger**: Projected monthly spending > 80% of income
```
Icon: Warning
Title: "Spending Alert"
Description: "You're on track to spend 85% of income"
Action: "View Analytics" → /analytics
```

### 2. Weekly Updates
**Trigger**: Always shown, updates weekly
```
Icon: Calendar
Title: "Week {N} Update"
Description: "You've spent ₹{amount} this month"
Action: "See Breakdown" → /analytics/weekly
```

### 3. Category Insights
**Trigger**: Based on top spending category
```
Icon: Category
Title: "Top Categories"
Description: "{Category} is your highest expense category"
Action: "Manage Categories" → /categories
```

### 4. Monthly Reports
**Trigger**: Day of month >= 25
```
Icon: Assessment
Title: "Monthly Report Ready"
Description: "Review your spending patterns for {Month}"
Action: "View Report" → /analytics/monthly
```

### 5. Budget Recommendations
**Trigger**: No active budgets
```
Icon: Wallet
Title: "Set a Budget"
Description: "Control spending with monthly budgets"
Action: "Create Budget" → /budgets/new
```

### 6. Savings Insights
**Trigger**: Income > Expenses
```
Icon: Savings
Title: "Savings Potential"
Description: "You could save ₹{amount} this month"
Action: "Start Saving" → /savings
```

## Rotation Mechanism

### Auto-Rotation
- **Interval**: 10 seconds
- **Animation**: Fade transition (500ms)
- **Sequence**: Cycles through available suggestions
- **Pause on Hover**: Stop rotation on user interaction

### Priority System
1. Urgent alerts (overspending)
2. Time-sensitive (monthly reports)
3. Actionable insights
4. General recommendations

## Visual Design

### Colors
- **Background**: Gradient (`surface1` → `surface2`)
- **Icons**: Contained in 40x40px rounded squares
- **Text**: Standard color hierarchy
- **Divider**: `borderSubtle` color

### Typography
- **Title**: Inter, 15px, FontWeight.w600
- **Description**: Inter, 13px, FontWeight.w400
- **Action**: Inter, 14px, FontWeight.w500

### Animations
- **Card Switch**: AnimatedSwitcher with fade
- **Tap Feedback**: InkWell ripple effect
- **Icon**: Subtle scale on tap

## Data Requirements

### From Account Summary
- `totalIncome`: Current month income
- `totalExpense`: Current month expenses
- `categoryBreakdown`: Top spending categories

### From Transactions
- `transactionCount`: Number of transactions
- `recurringTransactions`: List of recurring items
- `uncategorizedCount`: Transactions without categories

### Calculations
```dart
spendingRate = totalExpense / DateTime.now().day
projectedSpending = spendingRate * 30
savingsPotential = totalIncome - projectedSpending
```

## Technical Implementation

### State Management
```dart
class SmartSuggestionCard extends StatefulWidget {
  // Inputs from HomeCubit
  final double totalIncome;
  final double totalExpense;
  final int transactionCount;
  
  // Rotation state
  int _currentSuggestionIndex = 0;
  Timer? _rotationTimer;
}
```

### Navigation
```dart
onTap: () {
  // Track analytics event
  analytics.logEvent('suggestion_tapped', {
    'type': suggestion.title,
    'action': suggestion.actionText,
  });
  
  // Navigate to relevant screen
  context.push(suggestion.route);
}
```

## Analytics Tracking

### Events to Track
1. Suggestion impressions
2. Tap-through rates
3. Most engaged suggestion types
4. Time spent before interaction

## Benefits

1. **Personalized**: Content based on actual user data
2. **Actionable**: Each suggestion has clear next steps
3. **Educational**: Helps users understand their finances
4. **Engaging**: Fresh content keeps users interested
5. **Non-Intrusive**: Blends naturally with UI flow

## Future Enhancements

1. **Machine Learning**: Predict most relevant suggestions
2. **Notification Integration**: Push important insights
3. **Goal Tracking**: Show progress towards financial goals
4. **Comparative Insights**: Compare with previous months
5. **Social Features**: Anonymous comparisons with similar users