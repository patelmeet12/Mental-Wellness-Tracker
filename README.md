# MindMate AI — Mental Wellness Tracker

A comprehensive Flutter web application designed to support student mental wellness through AI-powered insights, mood tracking, and guided mindfulness exercises.

## 🏗️ Architecture

Built following **Clean Architecture** with clear separation of concerns:
- **Presentation Layer** — Flutter widgets, Riverpod providers, screens
- **Domain Layer** — Entities, repository interfaces (framework-independent)
- **Data Layer** — Repository implementations, models, local persistence

## ✨ Features

- **Onboarding** — Student profile setup with exam date & stress trigger identification
- **Dashboard** — Real-time wellness metrics, mood tracking & exam countdown
- **AI Journal** — Mood-tagged journal entries with Google Gemini AI analysis
- **Mindfulness** — Breathing exercises & guided mindfulness sessions
- **AI Coach** — Conversational wellness coaching powered by Gemini API
- **Analytics** — Mood trends, stress charts & trigger pattern insights

## 🔧 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart SDK ^3.8.1) |
| State Management | flutter_riverpod |
| Navigation | go_router |
| AI / LLM | google_generative_ai (Gemini) |
| Charts | fl_chart |
| Persistence | shared_preferences |
| Typography | google_fonts |

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Build for web
flutter build web
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── errors/          # Failure types
│   ├── localization/    # AppLocalizations
│   ├── navigation/      # GoRouter configuration
│   ├── providers/       # Core Riverpod providers
│   ├── services/        # Gemini & Storage services
│   ├── theme/           # AppColors, AppSpacing, AppTheme
│   └── widgets/         # Shared reusable widgets
└── features/
    ├── analytics/       # Mood & stress analytics
    ├── coach/           # AI coaching chat
    ├── dashboard/       # Home dashboard
    ├── journal/         # Mood journal
    ├── mindfulness/     # Breathing & mindfulness
    └── onboarding/      # User onboarding flow
```
