# Finance Management App

Finance Management is a modern mobile application built with Flutter, designed to help you manage your personal finances smartly and securely. The app supports authentication, transaction management, analytics, notifications, category management, and more. Data is synchronized via Firebase, with push notifications and a beautiful, responsive UI. State management is handled with Bloc, and navigation uses GoRouter for smooth transitions.

---

## Screenshots

image.png

---

## APK & Demo Video

-  **WEB:** [Access here](http://biwofinance.web.app/)
-  **APK Download:** [Download here](https://bom.so/biwofinance)

---

## Features

-  Sign up and log in with email & password (Google, Facebook supported)
-  Manage income and expense transactions: add, edit, delete
-  Categorize transactions for better tracking
-  Financial analytics and statistics with charts
-  Receive reminders and push notifications for new transactions
-  Manage user profile, change password, and secure your account
-  Onboarding and splash screens for new users
-  Modern UI with light/dark theme support
-  Data synchronization with Firebase and push notifications via Firebase Messaging
-  Reusable UI widgets and Bloc-based state management

---

## Prerequisites

-  .env
-  android/app/google-services.json
-  firebase.json
-  firebase_options.dart

---

## Project Structure

```
lib/
├── main.dart                # App entry point
├── core/                    # Shared utilities, helpers, constants
├── data/
│   ├── model/               # Data models (User, Transaction, ...)
│   └── repositories/        # Data handling (API, Firebase, local)
├── presentation/
│   ├── screens/             # Main screens (login, home, transaction, ...)
│   ├── widgets/             # Reusable UI widgets
│   ├── bloc/                # Bloc state management
│   └── routes.dart          # Route and navigation definitions
```

---

## Notes

-  The app uses Bloc for global state management.
-  Feature-specific logic (transactions, analytics, notifications, etc.) is separated into dedicated blocs and repositories.
-  Navigation is handled by GoRouter for smooth and flexible routing.
-  User and transaction data are stored and synchronized via Firebase.

---

## Contribution & Development

-  Fork the repo and create a new branch for your feature or bugfix.
-  Submit a pull request with a clear description.
-  Suggestions and bug reports are welcome via Issues.

---
