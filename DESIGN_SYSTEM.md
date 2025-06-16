# Design System Documentation

## Overview

This document outlines the design language and principles for the Expense Tracker app. The design follows a premium monochromatic aesthetic inspired by modern banking apps like Monzo, N26, and Revolut.

## Core Design Principles

### 1. **Minimalism First**
- Reduce cognitive load through simplicity
- Progressive disclosure - show only essential information first
- Clean layouts with generous whitespace
- No unnecessary decorative elements

### 2. **Premium Monochromatic Palette**
- No colors except shades of gray
- Subtle differentiation through carefully chosen gray values
- Reduced eye strain with no pure black/white

### 3. **Typography Hierarchy**
- Clear visual hierarchy through font weights and sizes
- Tabular figures for all numerical values
- Consistent letter spacing for improved readability

### 4. **Scannability**
- Transaction amounts must be easily scannable
- Fixed-width layouts for vertical alignment
- Consistent positioning of key information

## Color Palette

### Background Colors
```
bgPrimary:    #0A0A0A  // Near black - main background
bgSecondary:  #141414  // Cards and elevated surfaces
bgTertiary:   #1F1F1F  // Higher elevation
bgQuaternary: #2A2A2A  // Hover states
```

### Text Colors
```
textPrimary:    #E5E5E5  // High emphasis (main text)
textSecondary:  #999999  // Medium emphasis
textTertiary:   #666666  // Low emphasis (labels)
textQuaternary: #4D4D4D  // Very low emphasis
```

### Surface Colors
```
surface1: #141414  // Lowest elevation
surface2: #1F1F1F  // Medium elevation
surface3: #2A2A2A  // High elevation
```

### Semantic Colors (Monochrome)
```
positive:       #E5E5E5  // Income/credit (brighter)
negative:       #666666  // Expense/debit (dimmer)
positiveSubtle: #2A2A2A  // Positive backgrounds
negativeSubtle: #1A1A1A  // Negative backgrounds
```

### Border Colors
```
borderSubtle:  #1F1F1F  // Barely visible dividers
borderDefault: #2A2A2A  // Default borders
borderStrong:  #3A3A3A  // Emphasized borders
```

## Typography

### Font Families
- **Primary**: Inter (all UI text)
- **Monospace**: Roboto Mono (numbers, amounts, account numbers)

### Font Sizes
```
34px - Balance display (bold)
24px - Page headings (semi-bold)
20px - Section headings (bold)
18px - Large amounts (semi-bold)
16px - Body text, transaction descriptions (medium/semi-bold)
15px - Secondary text (regular)
14px - Labels, categories (regular)
13px - Date headers (semi-bold)
12px - Small labels, badges (medium/semi-bold)
11px - Micro text (semi-bold)
10px - Tiny badges (semi-bold)
```

### Font Weights
- 300 - Light (rarely used)
- 400 - Regular (body text, labels)
- 500 - Medium (important text)
- 600 - Semi-bold (headings, emphasis)
- 700 - Bold (primary headings only)

### Letter Spacing
- Headings: -0.5 to -0.3 (tighter)
- Body text: -0.2 to 0 (slightly tight to normal)
- Small caps/badges: 0.5 (wider)

## Component Design Patterns

### Transaction List Items

#### Layout Structure
```
[Type Indicator] [Description/Category] [Amount/Status]
     40px              Flexible              Fixed
```

#### Key Specifications
- **Min Height**: 72px for consistent vertical rhythm
- **Horizontal Padding**: 20px for alignment with content
- **Category Width**: 100px fixed (prevents misalignment)
- **Tabular Figures**: Required for all amounts

#### Visual Indicators
- **Credit**: "+" prefix, "IN" badge, brighter text (#E5E5E5)
- **Debit**: "-" prefix, "OUT" badge, standard text (#999999)
- **Recurring**: Small refresh icon (14px)

### Cards and Surfaces

#### Elevation System
- **Level 0**: Background (#0A0A0A)
- **Level 1**: Cards (#141414)
- **Level 2**: Elevated elements (#1F1F1F)
- **Level 3**: Modals, dropdowns (#2A2A2A)

#### Border Radius
- Small elements: 4-6px
- Medium elements: 8-10px
- Large cards: 12px
- Buttons/badges: 20px (pill-shaped)

### Interactive Elements

#### Hover States
- Background lightens by one level
- Subtle highlight: `bgQuaternary.withOpacity(0.3)`
- Splash color: `bgQuaternary.withOpacity(0.2)`

#### Touch Targets
- Minimum 44px height for mobile
- Full-width tap areas for list items
- Clear visual feedback on interaction

### Spacing System

#### Vertical Spacing
- **4px**: Between related elements (label/value)
- **8px**: Between sections within component
- **12px**: Between list items
- **16px**: Between distinct sections
- **24px**: Between major sections
- **32px**: Page-level spacing

#### Horizontal Spacing
- **8px**: Between inline elements
- **12px**: Between icon and text
- **16px**: Card padding
- **20px**: Screen edge padding

## Animation and Transitions

### Principles
- Subtle and functional only
- No decorative animations
- Fast and responsive (200-300ms)

### Common Transitions
- Opacity fades: 200ms ease-out
- Height changes: 300ms ease-in-out
- Color changes: 150ms ease-out

## Accessibility Considerations

### Contrast Ratios
- Primary text on background: 12.5:1
- Secondary text on background: 7:1
- Minimum contrast: 4.5:1

### Touch Targets
- Minimum 44x44px for all interactive elements
- Clear focus indicators for keyboard navigation
- Sufficient spacing between tappable elements

## Information Architecture

### Progressive Disclosure
1. **Primary**: Amount and merchant (always visible)
2. **Secondary**: Category and type (visible but de-emphasized)
3. **Tertiary**: Additional details on tap/expand

### Data Display Patterns
- **Amounts**: Always right-aligned with tabular figures
- **Dates**: Contextual formatting (Today, Yesterday, Monday, Jan 15)
- **Categories**: Fixed width to prevent layout shifts
- **Status**: Subtle badges rather than prominent labels

## Best Practices

### Do's
- ✅ Use consistent spacing throughout
- ✅ Maintain vertical alignment with fixed widths
- ✅ Use tabular figures for all numbers
- ✅ Keep interactions subtle and functional
- ✅ Test readability in both light and dark environments

### Don'ts
- ❌ Use pure black (#000000) or white (#FFFFFF)
- ❌ Add colors beyond the grayscale palette
- ❌ Use variable-width elements in lists
- ❌ Create decorative animations
- ❌ Overcrowd interfaces with information

## Implementation Notes

### Flutter-Specific Guidelines

#### Text Styling
```dart
GoogleFonts.inter(
  color: ColorConstants.textPrimary,
  fontSize: 16,
  fontWeight: FontWeight.w500,
  letterSpacing: -0.2,
)
```

#### Number Formatting
```dart
GoogleFonts.robotoMono(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  fontFeatures: const [FontFeature.tabularFigures()],
)
```

#### Consistent Padding
```dart
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
```

### Performance Considerations
- Minimize widget rebuilds in lists
- Use const constructors where possible
- Implement proper loading states
- Cache frequently accessed data (categories)

## Future Considerations

### Potential Enhancements
- Subtle gradients for premium feel (within grayscale)
- Micro-interactions for delight
- Advanced data visualization (maintaining monochrome)
- Haptic feedback for key actions

### Scalability
- Design system supports both mobile and tablet
- Components scale gracefully
- Typography remains readable at all sizes
- Touch targets adapt to device type

---

*This design system should be referenced for all UI decisions to maintain consistency throughout the application.*