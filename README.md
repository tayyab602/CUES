CUES - Campus Utility Exchange System 🏛️
CUES is a unified digital ecosystem designed for university campuses. It streamlines the process of recovering lost items and facilitates a secure student-to-student marketplace. Built with a focus on trust, privacy, and efficiency, CUES serves as the central hub for campus utility management.
✨ Features
🔍 Smart Lost & Found
•
Urgency-Driven UI: Visual indicators powered by the "Campus Beacon" design system (Safety Orange accents for high-priority items).
•
Instant Reporting: Easy forms for lost and found items with multi-image support.
•
Resolution Pipeline: One-tap resolution that automatically archives chats and cleans up cloud storage.
🛡️ Privacy-First Communication
•
Friend Request Firewall: Social peer-to-peer chats require a mutual friend request to expose real names.
•
Identity Interceptor: Anonymous chat sessions for lost items. Users are identified by their masked Campus ID (e.g., Anonymous 21-AU-CS) until they choose to connect.
•
Email Prefix Auth: Students can log in using only their campus username; the system automatically handles the institutional domain (@aack.au.edu.pk).
🛒 Campus Marketplace
•
Internal Trade: A localized marketplace for students to buy and sell books, electronics, and hostel essentials.
•
Media Optimization: Integrated image cropping (WhatsApp-style) to ensure perfect positioning and professional listings.
⚙️ Advanced Utility
•
Global Theme Switcher: Instant toggle between high-contrast Light and Dark modes.
•
Automatic Cleanup: A 30-day "Time-To-Live" (TTL) logic that hides expired posts to keep the feed fresh.
•
Storage Guard: Built-in 5MB limit and image compression to prevent data bloat.
🎨 Design System: "Campus Beacon"
The UI is built on Material Design 3, utilizing a technical palette designed for academic institutions:
•
Primary (Navy Blue - #1A365D): Represents trust, security, and official branding.
•
Tertiary (Safety Orange - #FF8A00): The "Beacon" used for urgent actions like reporting and notifications.
•
Secondary (Slate Gray): Provides stable neutral tones for descriptions and secondary text.
🚀 Tech Stack
•
Frontend: Flutter (Dart)
•
Backend: Firebase (Authentication, Firestore, Cloud Storage)
•
Networking: Dio API Client
•
Media: Image Picker & Image Cropper
🛠️ Installation & Setup
1.
Clone the Repository:
Shell Script
git clone https://github.com/YOUR_USERNAME/cues.git
cd cues
2.
Environment Configuration:
◦
Download your google-services.json from the Firebase Console.
◦
Place it in android/app/.
3.
Install Dependencies:
Shell Script
flutter pub get
4.
Run the Application:
Shell Script
flutter run
📦 Building for Production
Generate APK
Shell Script
flutter build apk --release
Generate App Bundle (AAB)
Shell Script
flutter build appbundle --release
🔒 Security Note
This repository uses a strict .gitignore policy. Sensitive files such as key.properties, upload-keystore.jks, and google-services.json are excluded to prevent API key exposure. If you are a contributor, please reach out to the project lead for the development configuration.
Project developed for Semester 4 - Mobile Computing (MC). Lead Developer: Tayyab Naveed Akhtar
