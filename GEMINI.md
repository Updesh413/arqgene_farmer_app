# GEMINI.md

## Project Overview

This is a Flutter-based mobile application for farmers, named "Arqgene Farmer App". The application is designed to provide a localized experience with support for English, Hindi, and Tamil. It uses Firebase for phone number-based user authentication and Isar for local database storage. The core features appear to include user profile management and the ability to create listings, likely for agricultural products.

### Key Technologies:

*   **Framework:** Flutter
*   **Authentication:** Firebase Authentication (Phone OTP)
*   **Local Database:** Isar
*   **Localization:** `easy_localization` package with JSON translation files.
*   **Location:** `geolocator` and `geocoding` for location services.
*   **Image Handling:** `image_picker` for selecting images.

### Architecture:

The project follows a standard Flutter application structure:

*   `lib/main.dart`: The main entry point of the application. It handles the initial routing logic, directing users to the language selection screen on their first run, and then to the appropriate screen based on their authentication and profile completion status.
*   `lib/auth_service.dart`: A dedicated service for handling all Firebase phone authentication logic, including sending and verifying OTPs.
*   `lib/screens`: This directory holds all the UI screens of the application, such as `LoginScreen`, `HomeScreen`, `ProfileScreen`, and `CreateListingScreen`.
*   `lib/db`: This directory contains the Isar database service (`isar_service.dart`) and the database schemas (`schemas.dart`), which defines the structure of the local data.
*   `assets/translations`: This folder contains the JSON files for English, Hindi, and Tamil translations.

## Building and Running

### Prerequisites:

*   Flutter SDK installed.
*   An Android or iOS emulator/device.
*   A `google-services.json` file for Android and a corresponding `GoogleService-Info.plist` for iOS for Firebase integration.

### Commands:

*   **Get dependencies:**
    ```bash
    flutter pub get
    ```

*   **Run the app:**
    ```bash
    flutter run
    ```

*   **Build the app:**
    *   **Android:**
        ```bash
        flutter build apk --release
        ```
    *   **iOS:**
        ```bash
        flutter build ios --release
        ```

## Development Conventions

*   **State Management:** The project appears to use a combination of `StatefulWidget` and `StreamBuilder` for managing state, particularly for handling authentication state changes. `SharedPreferences` is used for storing simple key-value data like `isFirstRun` and `isProfileCompleted`.
*   **Localization:** The `easy_localization` package is used for internationalization. All strings should be added to the JSON files in `assets/translations` and accessed using the `tr()` extension method.
*   **Database:** Isar is used for the local database. The database schema is defined in `lib/db/schemas.dart`. Any changes to the schema will require running the build runner to generate the necessary code: `flutter pub run build_runner build`.
*   **Styling:** The app uses Material Design, with the primary theme color set to green.
