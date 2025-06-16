# Expense Tracker

A premium expense tracking application built with Flutter, featuring a sophisticated monochromatic design and intelligent transaction categorization.

## Introduction

Expense Tracker is a modern financial management app that helps users track their income and expenses with ease. Built with Flutter and powered by Supabase, it combines beautiful design with powerful functionality to provide insights into your spending habits.

## About This Project

This expense tracker goes beyond simple transaction logging. It features:

- **Clean Architecture**: Following domain-driven design principles for maintainability and scalability
- **Premium Monochromatic UI**: A carefully crafted dark theme using only shades of gray for a sophisticated, distraction-free experience
- **Intelligent Categorization**: ML-ready infrastructure with pgvector support for automatic transaction categorization
- **Real-time Updates**: Live transaction updates using Supabase real-time subscriptions
- **Performance Optimized**: Smart caching and efficient state management for smooth user experience

## Features

### Core Functionality
- 📊 **Dashboard Overview**: View your current month's balance, income, and expenses at a glance
- 💰 **Transaction Management**: Add, edit, and delete transactions with ease
- 🏷️ **Smart Categorization**: Automatic category suggestions based on transaction descriptions
- 📅 **Date-based Grouping**: Transactions organized by date with contextual headers (Today, Yesterday, etc.)
- 🔄 **Recurring Transactions**: Track and manage recurring payments and income

### User Experience
- 🌑 **Premium Dark Mode**: Exclusively designed dark theme optimized for reduced eye strain
- ⚡ **Lightning Fast**: Instant loading with shimmer effects and optimized data fetching
- 🎯 **Smart Filtering**: Filter transactions by type (Credit/Debit), category, and recurring status
- 📱 **Responsive Design**: Beautiful on all screen sizes with consistent 20px padding throughout

### Technical Features
- 🏗️ **Clean Architecture**: Separation of concerns with Domain, Data, and Presentation layers
- 🔄 **BLoC State Management**: Predictable state management using flutter_bloc
- 🗄️ **Supabase Backend**: PostgreSQL database with real-time capabilities
- 🤖 **ML-Ready**: Infrastructure prepared for machine learning with pgvector embeddings
- 💉 **Dependency Injection**: GetIt for clean dependency management
- 🚀 **Performance Optimized**: Category caching and efficient stream handling

### Design Highlights
- **Monochromatic Palette**: Carefully selected grayscale values from #0A0A0A to #E5E5E5
- **Typography System**: Inter for UI text, Roboto Mono for numbers with tabular figures
- **Consistent Spacing**: 72px minimum height for list items, 20px horizontal padding
- **Visual Hierarchy**: Clear differentiation between income (brighter) and expenses (dimmer)
- **Progressive Disclosure**: Show essential information first, details on demand

### Upcoming Features
- 📊 Advanced analytics and spending insights
- 🎯 Budget tracking and goals
- 📸 Receipt scanning and attachment
- 🌍 Multi-currency support
- 📱 Widgets for quick transaction entry
- 🔐 Biometric authentication

## Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: BLoC/Cubit pattern
- **Backend**: Supabase (PostgreSQL)
- **Architecture**: Clean Architecture with SOLID principles
- **Design**: Custom monochromatic design system
- **Localization**: Indian Rupees (₹) with en_IN formatting

## Getting Started

Refer to [CLAUDE.md](./CLAUDE.md) for detailed setup instructions and development guidelines.

## Design System

See [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) for comprehensive design documentation and UI guidelines.

---

Built with ❤️ using Flutter and Supabase
