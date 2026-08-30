
# CAMPUS QUICK SPLIT – STUDENT EXPENSE SHARING APP

Campus Quick Split is a Flutter-based expense-sharing application designed specifically for college students, hostel roommates, friends, trip groups, and small teams who regularly share expenses.

Managing shared expenses can often become confusing. One person may pay for food, another may pay for transportation, and someone else may purchase groceries or other common items. Remembering who paid, who owes money, and how much each person should contribute can become difficult when expenses are managed manually through notes, calculators, spreadsheets, or chat messages.

Campus Quick Split provides a simple and organized solution for managing these shared expenses. Users can create groups, add members, record shared expenses, automatically calculate balances, track who owes money, suggest settlements, record completed payments, analyze spending patterns, and maintain payment history.

The application aims to make shared expense management faster, simpler, more transparent, and student-friendly.

---

## The Problem Statement

Students frequently share expenses with friends, roommates, classmates, and hostel members.

For example:

- One student pays for food for the entire group.
- Another student pays for transportation.
- Someone purchases groceries for the hostel room.
- Friends share expenses during trips or events.
- Roommates contribute different amounts toward common expenses.
- Multiple people may contribute toward the same group expense.

Managing these expenses manually can create several problems:

- Forgetting who paid for an expense.
- Confusion about who owes money.
- Difficulty calculating individual shares.
- Incorrect manual calculations.
- Difficulty tracking previous payments.
- No organized record of group expenses.
- Difficulty settling balances between multiple people.
- Difficulty understanding overall spending patterns.

Campus Quick Split solves these problems by providing a centralized platform where users can manage group expenses, automatically calculate balances, record settlements, and analyze spending.

---

## Why Campus Quick Split?

Campus Quick Split is designed with students and small groups in mind.

Instead of manually calculating expenses using calculators, notes, spreadsheets, or chat messages, users can record expenses directly inside the application.

The application helps users:

- Create groups for roommates, friends, trips, or projects.
- Add multiple members to a group.
- Record shared expenses.
- Track who paid for each expense.
- Support multiple contributors or payers.
- Calculate balances automatically.
- Identify who owes money.
- Identify who should receive money.
- View suggested settlements.
- Record completed payments.
- Track payment history.
- Delete incorrect or unnecessary expenses.
- Analyze spending patterns.
- View expense categories and totals.
- Filter expenses and analyze spending information.

The main goal of the application is to reduce confusion and make shared expense management easier, faster, and more transparent.

---

## Technology Stack:

- Framework: Flutter
- Programming Language: Dart
- UI Design: Material Design / Material 3
- Local Database: Hive
- Local Storage Support: Hive Flutter
- State Management: Flutter application state management
- Navigation: NavigationBar and IndexedStack
- Theme Management: ThemeController
- Supported Platform: Android
- IDE: Android Studio / Visual Studio Code
- Version Control: Git and GitHub

Flutter is used to develop the complete Campus Quick Split mobile application. It provides a single codebase for building modern and responsive mobile applications.

Dart is used for developing the application logic, data models, expense management functionality, balance calculations, settlement calculations, payment tracking, and user interface components.

Material Design and Material 3 are used to create a clean, modern, and student-friendly user interface throughout the application.

Hive is used as a lightweight local database for storing important application data directly on the device. This helps preserve groups, members, expenses, balances, and settlement information even after the application is closed and reopened.

Hive Flutter provides Flutter integration for Hive and helps initialize and manage the local database inside the application.

The application uses navigation components such as NavigationBar to allow users to move easily between major sections of the application.

IndexedStack helps maintain screen states while switching between different sections of the application, providing smoother navigation and a better user experience.

ThemeController is used to manage the application's theme-related functionality.

Git and GitHub are used for version control, source code management, and project hosting.

---

## Libraries and Packages:

### Flutter
Flutter is the main framework used to develop the Campus Quick Split mobile application.
It provides:

- Cross-platform mobile application development.
- Responsive user interfaces.
- Modern Material Design components.
- Fast application development.
- A single codebase for application development.

### Dart

Dart is the programming language used to develop the application.
It is used for:

- Application logic.
- Data models.
- Expense management.
- Balance calculations.
- Settlement calculations.
- Payment tracking.
- Local data handling.
- User interface development.

### Hive

Hive is used as a lightweight and fast local database.
It helps store important application information directly on the user's device.
The application uses local storage for information such as:

- Groups.
- Members.
- Shared expenses.
- Payment records.
- Settlement information.
- Application data.

Using Hive allows important information to remain available even after the application is closed and reopened.

### Hive Flutter
Hive Flutter provides Flutter integration for the Hive database.
It helps initialize and manage Hive inside the Flutter application.
Example package:
hive_flutter

### Material 3

Material 3 is used to design the application's modern user interface.
It provides consistent Flutter components and helps maintain a clean design throughout the application.

Material 3 helps create:

- Modern buttons.
- Cards.
- Navigation components.
- Dialog boxes.
- Input fields.
- Theme-based user interfaces.
- Consistent application layouts.

### NavigationBar
The application uses NavigationBar to help users move between different major sections of the application.
This provides a simple and organized navigation experience.

### IndexedStack
IndexedStack helps maintain screen states while switching between different sections of the application.
This helps:

- Preserve the current screen state.
- Avoid unnecessary rebuilding of screens.
- Provide smoother navigation.
- Improve the overall user experience.

---

## Project Structure:

The Campus Quick Split project follows a structured Flutter application architecture to keep the code organized, maintainable, and easy to understand.
```text
CAMPUS_QUICK_SPLIT/
│
├── android/
│   └── Android-specific configuration files
│
├── ios/
│   └── iOS-specific configuration files
│
├── lib/
│   │
│   ├── main.dart
│   │   └── Application entry point
│   │
│   ├── models/
│   │   └── Data models for groups, members,
│   │       expenses, balances, and settlements
│   │
│   ├── screens/
│   │   └── Application screens and user interfaces
│   │
│   ├── services/
│   │   └── Business logic and local data handling
│   │
│   ├── controllers/
│   │   └── Application state and theme management
│   │
│   └── widgets/
│       └── Reusable user interface components
│
├── test/
│   └── Unit and widget tests
│
├── assets/
│   └── Application assets and resources
│
├── screenshots/
│   └── Application screenshots
│
├── pubspec.yaml
│   └── Flutter dependencies and project configuration
│
└── README.md
    └── Project documentation
```
---

## Setup and Installation Guide


### 1. Prerequisites

Ensure the following tools and SDKs are installed on your development machine before setting up the project:

- **Git:** [Download Git](https://git-scm.com/downloads) (Required to clone the repository)
- **Flutter SDK:** [Install Flutter](https://docs.flutter.dev/get-started/install) (Ensure the latest stable release of Flutter is installed)[cite: 1]
- **Android Studio:** [Download Android Studio](https://developer.android.com/studio)
  - Install **Android SDK Platform 35** (or higher)
  - Install **Android SDK Build-Tools**
  - Install **Android SDK Platform-Tools**
  - Configure an **Android Virtual Device (AVD)** for emulator testing
- **Java Development Kit (JDK 17):** Recommended OpenJDK 17 or Eclipse Temurin JDK 17

After installation, verify that your Flutter environment, toolchains, and connected devices are properly configured:

```bash
flutter doctor
```

### 2. Clone the Repository


Clone the project repository to your local directory using Git:

```bash
git clone [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT.git](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT.git)
cd CAMPUS_QUICK-_SPLIT
```

### 3. Install Dependencies
Fetch and resolve all the required Flutter packages and libraries defined in `pubspec.yaml`:

Bash
```
flutter pub get
```

### 4. Check Connected Devices
Verify that your physical device or emulator is detected by Flutter:

Bash
```
flutter devices
```

### 5. Run the Application
Execute the command to launch the app in debug mode:

Bash
```
flutter run
```

-   **Physical Android Device:**
    
    1.  Connect your Android phone to your computer via USB.
    2.  Enable **Developer Options** and turn on **USB Debugging**.
    3.  Verify the device using `flutter devices` and execute `flutter run`.
    
-   **Android Emulator:**
    
    1.  Open **Android Studio** and navigate to **Device Manager**.
    2.  Start an existing Android Virtual Device (AVD).
    3.  Run `flutter run` in your terminal.
        

## Screenshots


- **Home Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/HOME_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/HOME_SCREEN.jpeg)

- **Group Details Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/GROUP_DETAILS_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/GROUP_DETAILS_SCREEN.jpeg)

- **Add Group Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ADD_GROUP_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ADD_GROUP_SCREEN.jpeg)

- **Add Member Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ADD_MEMBER_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ADD_MEMBER_SCREEN.jpeg)

- **Add Expense Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ADD_EXPENSE_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ADD_EXPENSE_SCREEN.jpeg)

- **Split Options Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/SPLIT_OPTIONS_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/SPLIT_OPTIONS_SCREEN.jpeg)

- **Multi Payer Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/MULTI_PAYER_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/MULTI_PAYER_SCREEN.jpeg)

- **Settle Up Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/SETTLE_UP_PAGE.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/SETTLE_UP_PAGE.jpeg)

- **Payment History Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/PAYMENT_HISTORY_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/PAYMENT_HISTORY_SCREEN.jpeg)

- **Delete Expense Dialog:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/DELETE_EXPENSE.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/DELETE_EXPENSE.jpeg)

- **Analytics Overview Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ANALYTICS_SCREEN2.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ANALYTICS_SCREEN2.jpeg)

- **Analytics Spending Breakdown Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ANALYTICS_SCREEN3.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/ANALYTICS_SCREEN3.jpeg)

- **Settings Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/SETTINGS_PAGE_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/SETTINGS_PAGE_SCREEN.jpeg)

- **Storage Management Screen:**
  [https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/STORAGE_MANAGEMENT_SCREEN.jpeg](https://github.com/Reneshb24/CAMPUS_QUICK-_SPLIT/blob/main/screenshots/STORAGE_MANAGEMENT_SCREEN.jpeg)
    
## Future Improvements

-   **Receipt OCR Integration:** Automated extraction of line items and bill totals from printed mess and grocery receipts using on-device ML.
-   **Direct UPI Intent Deep-Linking:** Automatically open installed UPI payment apps (GPay, PhonePe, Paytm) pre-filled with the exact payee UPI ID and settlement balance.
-   **Encrypted Local Peer-to-Peer Sync:** Multi-device synchronization over local Wi-Fi or Bluetooth without relying on external cloud infrastructure.
-   **PDF & CSV Statement Exports:** One-click generation of itemized expense reports for hostel records and project funding submissions.
    

## Author

**Renesh B** – [GitHub Profile](https://www.google.com/search?q=https://github.com/Reneshb24)
