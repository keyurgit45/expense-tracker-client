# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an expense tracker Flutter application with advanced ML-powered transaction categorization using Supabase and pgvector embeddings.

## Commands

### Development
```bash
flutter run                    # Run the app on connected device/emulator
flutter run -d chrome         # Run on Chrome web browser
flutter run -d macos          # Run on macOS desktop
```

### Build
```bash
flutter build apk             # Build Android APK
flutter build ios             # Build iOS app
flutter build web             # Build web app
flutter build macos           # Build macOS app
flutter build windows         # Build Windows app
```

### Testing & Quality
```bash
flutter test                  # Run all tests
flutter test test/widget_test.dart  # Run specific test file
flutter analyze               # Run static analysis
dart format .                 # Format code
```

### Dependencies
```bash
flutter pub get               # Install dependencies
flutter pub upgrade           # Upgrade dependencies
```

## Architecture

### Clean Architecture Structure
The project follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/                      # Core functionality shared across features
│   ├── constants/            # App-wide constants
│   ├── errors/              # Error handling (failures, exceptions)
│   ├── usecases/            # Base use case classes
│   ├── utils/               # Utility classes (formatters, converters)
│   └── widgets/             # Reusable widgets
├── config/                   # App configuration
│   ├── routes/              # Navigation setup (GoRouter)
│   ├── theme/               # Theme configuration
│   ├── injection.dart       # Dependency injection setup
│   └── supabase_config.dart # Supabase configuration
└── features/                 # Feature modules
    ├── transactions/        # Transactions management
    ├── categories/          # Categories management
    ├── analytics/           # Analytics and reports
    └── settings/           # App settings
```

Each feature follows the same structure:
- **data/**: Implementation layer (datasources, models, repositories)
- **domain/**: Business logic layer (entities, repositories, use cases)
- **presentation/**: UI layer (bloc/cubit, pages, widgets)

### State Management
- Uses BLoC pattern with flutter_bloc for state management
- Cubits for simpler state management scenarios
- BLoCs for complex business logic

### Dependency Injection
- Uses GetIt for dependency injection
- Manual registration in configureDependencies()

### Database Schema (Supabase with pgvector)
The app uses sophisticated ML embeddings for transaction categorization:
- **transactions**: Core transaction data (amount, merchant, date, category)
- **categories**: Hierarchical category structure with parent-child relationships
- **transaction_embeddings**: 384-dimensional vectors for ML-based categorization
- **tags**: Flexible tagging system
- **transaction_tags**: Many-to-many relationship for transaction tags

### ML Features
- Uses all-MiniLM-L6-v2 model (384 dimensions)
- Similarity search for automatic transaction categorization
- Confidence scoring for category predictions
- PostgreSQL functions for finding similar transactions

### Code Generation
Currently not using code generation. All models and dependencies are manually written.

### Environment Setup
1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Edit `.env` and add your Supabase credentials:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

3. Run the app:
```bash
flutter run
```

## Design System

**See [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) for comprehensive design documentation.**

### Quick Reference
- **Design Philosophy**: Premium monochromatic aesthetic inspired by modern banking apps
- **Color Palette**: Carefully chosen grayscale values (#0A0A0A to #E5E5E5)
- **Typography**: Inter for UI, Roboto Mono for numbers with tabular figures
- **Layout**: Fixed-width elements for perfect alignment, 72px minimum height for list items
- **Spacing**: 20px horizontal padding, consistent vertical rhythm

### Key UI Patterns
1. **Transaction Lists**: 
   - Minimal design with fixed 100px category width
   - Clear credit/debit indicators (IN/OUT badges)
   - Subtle dividers between date sections
   
2. **Home Screen**:
   - Personalized greetings that change based on time/context
   - Current month transactions only
   - Top 3 categories based on usage

3. **Visual Language**:
   - Progressive disclosure (show essential info first)
   - Subtle interactions (no decorative animations)
   - Optimized for debit-heavy transaction lists

## Key Development Notes

1. The project follows clean architecture with clear separation between data, domain, and presentation layers
2. State management uses BLoC pattern - create cubits for simple state, blocs for complex logic
3. All dependency injection is handled through GetIt
4. No authentication - the app works locally without user accounts
5. Database schema:
   - Transaction type derived from amount sign (positive = income, negative = expense)
   - Categories table has name field only (no icon/color in DB)
   - Transaction tags derived from description analysis
6. Uses Supabase PostgreSQL (pgvector extension not currently utilized)
7. Currency: Indian Rupees (₹) with en_IN locale formatting
8. Dark mode only - no light theme support
9. Premium monochromatic design - no colors except shades of gray
10. As you write new code, always update documentation

## Recent Updates

1. **Category System**: 
   - Categories now properly loaded from Supabase with joins
   - Category service with caching for optimal performance
   - Categories preloaded at app startup

2. **Transaction List Redesign**:
   - New minimal design with perfect vertical alignment
   - Fixed-width categories (100px) to prevent UI shifting
   - Clear credit/debit indicators with IN/OUT badges
   - Removed variable-width tags in favor of consistent layout

3. **Homepage Improvements**:
   - Shows current month transactions only
   - Personalized greetings (replaces account number)
   - Dynamic greeting messages based on time/context
   - "This month" label instead of "Latest"

4. **Performance Optimizations**:
   - Stream watching uses cached categories (no DB calls)
   - Synchronous operations for better performance
   - Reduced database queries through smart caching

5. **Design System Documentation**:
   - Comprehensive design language documented in DESIGN_SYSTEM.md
   - Clear guidelines for maintaining UI consistency
   - Typography, spacing, and color specifications