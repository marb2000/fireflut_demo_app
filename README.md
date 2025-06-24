# 🔥 Fireflutt Mobile Demo

A demo Flutter application showcasing the integration of Vertex AI in Firebase (Gemini) with a mobile service provider app concept. This sample app demonstrates how to build modern mobile applications using Flutter, Firebase, and AI capabilities via Gemini 2.0.

![Fireflut Mobile Banner](assets/provider-logo.png)

## 🎯 Purpose

This demo app serves as a reference implementation to demonstrate:
- Integration of Vertex AI in Firebase with Flutter
- Implementation of Gemini AI for chat and recommendations
- MVVM architecture in Flutter
- Modern UI/UX patterns for mobile service apps
- Voice input processing in Flutter

> ⚠️ **Note**: This is a demo application and should not be used in production. It uses mock data and simplified implementations for demonstration purposes.

## ✨ Demo Features

- **AI Chat Demo**: Integration with Gemini AI for customer support scenarios
- **Voice Input**: Example implementation of voice recording and processing
- **Usage Dashboard**: Sample UI for displaying mobile usage statistics
- **Mock Billing**: Demonstration of billing interface and payment tracking
- **Settings Management**: Example of user settings and profile management

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Firebase account and project setup
- Billing enabled on Firebase project (required for Vertex AI)
- VS Code with Flutter plugins

### Firebase and Vertex AI Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable Vertex AI in the Firebase Console:
   - Go to Build with Gemini and select Vertex AI in Firebase 
   - Follow the setup wizard
   - Enable required APIs

   

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/fireflut-mobile-demo.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your `google-services.json` to `android/app/`
   - Add your `GoogleService-Info.plist` to `ios/Runner/`

4. Run the demo:
```bash
flutter run
```

## 🏗️ Project Structure
Fireflutt Mobile follows the MVVM (Model-View-ViewModel) architecture pattern:

```
lib/
├── models/           # Data models and entities
├── views/            # UI screens and components
├── view_models/      # Business logic and state management
├── services/         # API services (Gemini, voice, location)
├── data_services/    # Data access layer
├── utils/            # Helper utilities
├── themes/           # UI theming and styling
└── widgets/          # Reusable UI components
```

## 🛠️ Technologies Used

- **Frontend**: Flutter
- **Backend Serverless Services**: Firebase
- **AI Integration**: Vertex AI i Firebase (Gemini)
- **Voice Processing**: Record Plugin and Gemini 2.0
- **Mock Data**: Local JSON assets

## 📱 Demo Screens

- Home Dashboard
- Chat Interface with Gemini AI
- Usage Statistics
- Billing Interface
- Settings and Profile


## 📄 License

This demo project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## ⚠️ Disclaimer

This is a demonstration app intended for learning purposes. It includes:
- Mock data for demonstration
- Simplified implementations
- Basic error handling
- Limited security measures

Do not use this code in production without proper security review and implementation of proper error handling, data validation, and security measures.

## 🤝 Contributing

Feel free to fork this project, submit PRs, and report issues. Please remember this is a demo project, so keep modifications aligned with the educational/demonstration purpose.

---
Created for demonstration and learning purposes.
