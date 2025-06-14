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

### Monochromatic Color Palette
The app uses a premium monochromatic design language with carefully chosen shades:

- **Background Colors**:
  - Primary: #0A0A0A (Near black)
  - Secondary: #141414 (Cards)
  - Tertiary: #1F1F1F (Elevated surfaces)
  - Quaternary: #2A2A2A (Hover states)

- **Text Colors**:
  - Primary: #E5E5E5 (High emphasis)
  - Secondary: #999999 (Medium emphasis)
  - Tertiary: #666666 (Low emphasis)
  - Quaternary: #4D4D4D (Very low emphasis)

- **Border Colors**:
  - Subtle: #1F1F1F (Barely visible)
  - Default: #2A2A2A (Default borders)
  - Strong: #3A3A3A (Emphasized borders)

### Typography
- Uses Google Fonts Inter throughout
- Roboto Mono for account numbers
- Font weights: 300-700 for hierarchy
- No pure black/white for reduced eye strain

### UI Components

1. **Home Screen**:
   - Balance card with total balance display
   - Income/Expense summary card
   - Top 3 categories as buttons
   - List of 30 latest transactions with date headers

2. **Transactions List**:
   - Three filter rows: Type (Credit/Debit), Category, Recurring status
   - Transactions grouped by date with headers
   - Monochrome filter chips with selection states

3. **Visual Indicators**:
   - Income: Brighter text (#E5E5E5)
   - Expense: Dimmer text (#999999)
   - Tags use different surface colors for subtle differentiation

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

1. **Increased transaction limit**: Home screen now shows 30 transactions instead of 5
2. **Transaction list page**: Added with comprehensive filtering (type, category, recurring)
3. **Date headers**: Transactions grouped by date with "Today", "Yesterday", day names, or full dates
4. **Monochromatic redesign**: Removed all colors in favor of premium black/white design
5. **Filter improvements**: Category filter state now updates correctly with nullable handling