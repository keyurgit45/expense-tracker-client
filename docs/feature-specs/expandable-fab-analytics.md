# Feature Specification: Expandable FAB with Analytics Menu

## Overview
An expandable Floating Action Button (FAB) that provides quick access to analytics and other key features through a radial menu design.

## User Experience

### Closed State
- **Position**: Bottom-right corner, 16px from edges
- **Appearance**: Circular FAB with dashboard icon
- **Color**: `ColorConstants.surface3` (#2A2A2A)
- **Size**: Standard FAB size (56x56px)
- **Elevation**: 4dp with subtle shadow

### Interaction
1. **Tap to Expand**: Single tap reveals menu items with smooth animation
2. **Animation**: 
   - FAB icon rotates 45° to become close (×) icon
   - Menu items slide up in staggered animation
   - Semi-transparent backdrop fades in
3. **Tap to Close**: Tap FAB again or backdrop to close

### Expanded State
- **Backdrop**: Black overlay with 50% opacity
- **Menu Items**: Mini FABs arranged vertically with labels
- **Spacing**: 12px between items
- **Label Animation**: Labels fade in after FABs appear

## Menu Structure

### Primary Actions (Top to Bottom)
1. **Analytics** 
   - Icon: `Icons.analytics`
   - Route: `/analytics`
   - Description: View spending insights and trends

2. **Categories**
   - Icon: `Icons.category`
   - Route: `/categories`
   - Description: Manage transaction categories

## Visual Design

### Colors
- **FAB Background**: `ColorConstants.surface3` (#2A2A2A)
- **Mini FAB Background**: `ColorConstants.surface2` (#1F1F1F)
- **Icons**: `ColorConstants.textPrimary` (#E5E5E5)
- **Labels**: White text on dark rounded background
- **Backdrop**: `Colors.black.withOpacity(0.5)`

### Typography
- **Labels**: Inter, 14px, FontWeight.w500

### Animations
- **Duration**: 250ms
- **Curve**: `Curves.easeOutCubic`
- **Stagger**: 50ms between items
- **Rotation**: FAB icon rotates smoothly

## Technical Implementation

### State Management
```dart
- _isExpanded: bool // Track menu state
- AnimationController for smooth transitions
- Individual animations for each menu item
```

### Accessibility
- All buttons have semantic labels
- Sufficient touch targets (48x48px minimum)
- High contrast for visibility
- Keyboard navigation support

### Navigation
```dart
onTap: () {
  _toggle(); // Close menu
  context.push(route); // Navigate
}
```

## Benefits
1. **Always Accessible**: Available on main screen without scrolling
2. **Non-Intrusive**: Doesn't take space when closed
3. **Scalable**: Easy to add/remove menu items
4. **Familiar Pattern**: Users recognize FAB functionality
5. **Premium Feel**: Smooth animations and elegant design

## Future Enhancements
- Badge notifications on menu items
- Long-press for quick actions
- Customizable menu items based on user preferences
- Gesture support (swipe up to expand)