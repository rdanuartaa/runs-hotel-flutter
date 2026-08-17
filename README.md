<div align="center">
  <img src="assets/icons/logorunhotel.png" alt="Runs Hotel Logo" width="120" />
  <h1>Runs Hotel App</h1>
  <p>A comprehensive, feature-rich hotel booking application built with Flutter, Supabase, and Midtrans.</p>
</div>

---

## 🌟 Overview

**Runs Hotel** is a modern mobile application designed to provide a seamless hotel booking experience. It leverages the power of Flutter for a beautiful cross-platform UI, Supabase for robust backend and real-time database capabilities, and Midtrans for secure payment processing. 

## ✨ Key Features

- **🔐 Authentication**: Secure user authentication including Google Sign-In, powered by Supabase.
- **🏨 Search & Browse**: Discover hotels, view room details, and check availability with a smooth UI.
- **📍 Real-time Geolocation & Maps**: Integration with `geolocator` and `flutter_map` for real-time location tracking and interactive map views.
- **💳 Secure Payments**: End-to-end payment processing via **Midtrans** (integrated via Supabase Edge Functions & WebView).
- **🎫 E-Tickets & Invoices**: Automatic PDF generation for booking confirmations and e-tickets, complete with printing support.
- **📷 QR Scanner**: Built-in QR code scanning capabilities for ticket validation and fast check-ins.
- **🔔 Push Notifications**: Stay updated with booking statuses and promotions via Firebase Cloud Messaging (FCM).
- **🎨 Modern UI/UX**: Crafted with beautiful animations (`flutter_animate`), responsive layouts, and skeleton loaders (`shimmer`).

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.11.0)
- **State Management**: [BLoC](https://bloclibrary.dev/) (`flutter_bloc`)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Backend / Database**: [Supabase](https://supabase.com/) (`supabase_flutter`)
- **Payment Gateway**: [Midtrans](https://midtrans.com/)
- **Push Notifications**: [Firebase](https://firebase.google.com/) (`firebase_messaging`)
- **Local Storage / Config**: `flutter_dotenv`, `json_annotation`

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.11.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- An active [Supabase](https://supabase.com/) project
- An active [Midtrans](https://midtrans.com/) merchant account
- A [Firebase](https://firebase.google.com/) project (for push notifications)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/runs-hotel.git
   cd runs-hotel/hotel_booking
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory based on your project keys:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   MIDTRANS_SERVER_KEY=your_midtrans_server_key
   MIDTRANS_CLIENT_KEY=your_midtrans_client_key
   ```
   *(Note: Ensure you also configure `.env.firebase` and `firebase.json` for FCM services).*

4. **Code Generation** (for BLoC, JSON Serialization, etc.)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## 📂 Project Structure

```text
lib/
├── core/             # Core utilities, constants, theme, and network setup
├── data/             # Repositories, models, and API services (Supabase calls)
├── logic/            # BLoC/Cubit state management logic
├── presentation/     # UI layers, screens, widgets, and routing
└── main.dart         # Entry point of the application
supabase/
├── functions/        # Supabase Edge Functions (e.g., Midtrans webhook)
└── supabase_schema.sql # Database schema definitions
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! 
Feel free to check [issues page](https://github.com/your-username/runs-hotel/issues).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
