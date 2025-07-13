# Expense Tracker

A premium expense tracking application built with Flutter, featuring a sophisticated monochromatic design and intelligent transaction categorisation.

## Introduction

Expense Tracker is a modern financial management app that helps users track their income and expenses with ease. Built with Flutter and powered by Supabase, it combines beautiful design with powerful functionality to provide insights into your spending habits.

## About This Project

This expense tracker goes beyond simple transaction logging. It features:

- **Clean Architecture**: Following domain-driven design principles for maintainability and scalability
- **Premium Monochromatic UI**: A carefully crafted dark theme using only shades of grey for a sophisticated, distraction-free experience
- **Intelligent Categorisation**: ML-ready infrastructure with pgvector support for automatic transaction categorisation
- **Real-time Updates**: Live transaction updates using Supabase real-time subscriptions
- **Performance Optimised**: Smart caching and efficient state management for a smooth user experience

## Features

### Core Functionality
- 📊 **Dashboard Overview**: View your current month's balance, income, and expenses at a glance
- 💰 **Transaction Management**: Add, edit, and delete transactions with ease
- 🏷️ **Smart Categorisation**: Automatic category suggestions based on transaction descriptions
- 📅 **Date-based Grouping**: Transactions organised by date with contextual headers (Today, Yesterday, etc.)
- 🔄 **Recurring Transactions**: Track and manage recurring payments and income

### User Experience
- 🌑 **Premium Dark Mode**: Exclusively designed dark theme optimised for reduced eye strain
- ⚡ **Lightning Fast**: Instant loading with shimmer effects and optimised data fetching
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

## Screenshots

<div style="display: flex; gap: 8px; justify-content: center;">
  <img src="https://github.com/user-attachments/assets/af8899c1-4e58-406b-a5dc-1b666e6257f5" width="180" alt="Phone Screenshot 1">
  <img src="https://github.com/user-attachments/assets/3dcbaf76-8847-492f-84a0-a68decf1a4be" width="180" alt="Phone Screenshot 2">
  <img src="https://github.com/user-attachments/assets/07186e2a-00d3-40a5-8578-6bafee4c2b44" width="180" alt="Phone Screenshot 3">
  <img src="https://github.com/user-attachments/assets/2b21f653-336f-4289-8ae0-3b12c4bcef68" width="180" alt="Phone Screenshot 4">
</div>

<br>
Built with ❤️ using Cursor Pro
