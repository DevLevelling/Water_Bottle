# 💧 Water Bottle - Water Fetching Tracker

A Flutter-based mobile application that helps users track their water fetching activities, compete with friends, and maintain a sustainable water consumption habit.

## 🌟 Features

### 🔐 Authentication System
- **Firebase Authentication** with persistent login
- **Email/Password** registration and login
- **Automatic profile creation** in Supabase
- **Seamless navigation** after login/signup
- **Secure logout** functionality

### 💧 Water Fetching Activities
- **Single Mode**: Individual water fetching with bottle selection (1 bottle = 0.5 pts, 2 bottles = 1.0 pt)
- **Together Mode**: Collaborative fetching with fair split (1 bottle = 0.25 pts each, 2 bottles = 0.5 pts each)
- **Bottle selector**: Choose 1 or 2 bottles per post
- **Real-time posting** with custom messages
- **User selection** for collaborative activities
- **Owner delete**: Post owners can delete their post until it’s verified
- **Activity history** with timestamps

### 🏆 Points & Verification System
- **Point-based scoring** with per-user points stored on each post
- **Verification status** (pending, verified, rejected)
- **Decision locking**: once you verify or reject a post, you cannot change it
- **Leaderboard rankings** based on total points
- **User profiles** with point summaries
- **Activity verification** workflow

### 👥 Social Features
- **User profiles** with activity history
- **Leaderboard** showing top performers
- **Collaborative activities** with partner selection
- **Real-time updates** across the app

### 🎨 User Interface
- **Modern Material Design 3** interface
- **Responsive layout** for different screen sizes
- **Intuitive navigation** with tab-based structure
- **Beautiful animations** and transitions
- **Custom color scheme** (#42AAF0 primary)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.0 or higher)
- Android Studio / VS Code
- Android SDK (API level 23+)
- Firebase project
- Supabase project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd water_bottle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Add your `google-services.json` to `android/app/`
   - Update Firebase configuration in `lib/firebase_options.dart`
   - Enable Email/Password authentication in Firebase Console
   - Add SHA-1 fingerprint for reCAPTCHA

4. **Configure Supabase**
   - Update Supabase credentials in `lib/config/supabase_config.dart`
   - Run the SQL setup script in `SUPABASE_SETUP.sql`

5. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── auth_wrapper.dart         # Authentication routing
├── intro_page.dart          # Welcome/onboarding screen
├── login_page.dart          # User login
├── signup_page.dart         # User registration
├── home_page.dart           # Main activity feed
├── profile_page.dart        # User profile & settings
├── leaderboard_page.dart    # User rankings
├── auth_test.dart           # Authentication testing
├── firebase_options.dart    # Firebase configuration
├── config/
│   └── supabase_config.dart # Supabase configuration
└── services/
    ├── firebase_auth_service.dart    # Authentication logic
    ├── supabase_data_service.dart    # Database operations
    └── notification_service.dart     # Push notifications
```

## 🔧 Configuration (Firebase & Supabase)

**⚠️ Security Note:** This repository no longer commits Firebase credentials or config files for security reasons. All credentials must be provided at build/run time.

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication with Email/Password
3. Enable reCAPTCHA Enterprise
4. Download `google-services.json` (keep it local, do not commit to repo)
5. Add SHA-1 fingerprint for your app

**For development/building, provide Firebase configuration via Dart defines:**

```bash
flutter run \
  --dart-define=FIREBASE_API_KEY=your_api_key_here \
  --dart-define=FIREBASE_APP_ID=your_app_id_here \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket \
  --dart-define=FIREBASE_AUTH_DOMAIN=your_auth_domain
```

**For release builds:**

```bash
flutter build apk \
  --dart-define=FIREBASE_API_KEY=your_api_key_here \
  --dart-define=FIREBASE_APP_ID=your_app_id_here \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket \
  --dart-define=FIREBASE_AUTH_DOMAIN=your_auth_domain
```

### Supabase Setup
1. Create a new Supabase project
2. Run the database setup script:
   ```sql
   -- Create user_profiles table
   CREATE TABLE user_profiles (
     id SERIAL PRIMARY KEY,
     firebase_uid TEXT UNIQUE NOT NULL,
     display_name TEXT NOT NULL,
     email TEXT NOT NULL,
     photo_url TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Create water_fetch_posts table
   CREATE TABLE water_fetch_posts (
     id SERIAL PRIMARY KEY,
     firebase_uid TEXT NOT NULL,
     message TEXT NOT NULL,
     fetch_type TEXT NOT NULL DEFAULT 'Single',
     partner_user_id TEXT,
     points DECIMAL(3,1) NOT NULL,
     verification_status TEXT DEFAULT 'pending',
     verified_by TEXT[] DEFAULT '{}',
     rejected_by TEXT[] DEFAULT '{}',
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Enable Row Level Security
   ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
   ALTER TABLE water_fetch_posts ENABLE ROW LEVEL SECURITY;

   -- Create policies
   CREATE POLICY "Users can view all profiles" ON user_profiles
     FOR SELECT USING (true);

   CREATE POLICY "Users can update own profile" ON user_profiles
     FOR UPDATE USING (auth.uid()::text = firebase_uid);

   CREATE POLICY "Users can insert own profile" ON user_profiles
     FOR INSERT WITH CHECK (auth.uid()::text = firebase_uid);

   CREATE POLICY "Users can view all posts" ON water_fetch_posts
     FOR SELECT USING (true);

   CREATE POLICY "Users can insert own posts" ON water_fetch_posts
     FOR INSERT WITH CHECK (auth.uid()::text = firebase_uid);
   ```

**For development/building, also provide Supabase configuration via Dart defines:**

```bash
flutter run \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key \
  --dart-define=FIREBASE_API_KEY=your_api_key_here \
  --dart-define=FIREBASE_APP_ID=your_app_id_here \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_STORAGE_BUCKET=your_storage_bucket \
  --dart-define=FIREBASE_AUTH_DOMAIN=your_auth_domain
```

### Platform-Specific Configuration

**Android:** Do not commit `android/app/google-services.json`. Instead, keep a local copy or use CI to place it during builds. An example template is provided as `google-services.json.example`.

**iOS/macOS:** Do not commit `GoogleService-Info.plist`. Keep a local copy or inject during CI. You may create `GoogleService-Info.plist.example` similarly.

### Security Recommendations
- **Rotate any keys** that were previously committed, as they should be considered compromised.
- Enable GitHub secret scanning and push protection in repository settings.
- Use environment variables or CI/CD secrets for production deployments.

## 📱 Usage Guide

### Getting Started
1. **Launch the app** - You'll see the welcome screen
2. **Create an account** - Sign up with email and full name
3. **Start tracking** - Post your first water fetching activity

### Creating Activities
1. **Choose mode**: Single or Together
2. **Choose bottles**: 1 bottle or 2 bottles (affects points)
3. **For Together mode**: Select a partner from the dropdown
4. **Write a message** describing your activity
5. **Post activity** - It will appear in your feed

### Understanding Points
- **Single Mode**: 1 bottle → 0.5 points; 2 bottles → 1.0 point
- **Together Mode**: 1 bottle → 0.25 points each; 2 bottles → 0.5 points each
- **Totals**: Together total = per-user points × 2 (poster + partner)
- **Verification**: Activities start as "pending" until verified
- **Owner delete**: You can delete your own post until it’s verified
- **Decision locking**: After you verify/reject a post, your decision is locked

### Navigation
- **Home Tab**: View and create activities
- **Leaderboard Tab**: See user rankings
- **Profile Tab**: View your stats and logout

## 🔄 Process & Working Method

### End-to-end flow
- **Post creation**
  - Choose mode (Single/Together), pick bottles (1 or 2), write a message, and for Together select a partner.
  - The app computes per-user points and saves a post in Supabase with these values:
    - Single: 1 bottle → 0.5, 2 bottles → 1.0
    - Together: 1 bottle → 0.25 each, 2 bottles → 0.5 each
  - Fields stored: `message`, `fetch_type`, `partner_user_id` (partner display name), `points` (per-user), `firebase_uid` (owner), `verification_status`, `verified_by`, `rejected_by`.
  - A notification is sent to all other users announcing the new post.

- **Home feed & actions**
  - Each post shows status (pending/verified/rejected), message, and points. Together posts show “points each”.
  - The post owner never sees verify/reject; they see a Delete button (only while the post is not verified).
  - Other users can verify or reject exactly once; after deciding, the controls are hidden for them (decision locking).

- **Verification / Rejection**
  - Verify updates Supabase: sets `verification_status` to `verified`, adds the verifier to `verified_by`, removes them from `rejected_by` if present, and notifies the owner.
  - Reject updates Supabase similarly (`rejected_by`) and notifies the owner.

- **Points aggregation**
  - The `points` column stores per-user points for the post.
  - Leaderboard/Profile totals:
    - For posts you created (poster): sum your posts’ `points` where `verification_status = verified`.
    - For Together posts where you are the partner: sum the post `points` (also per-user) where `partner_user_id = your name` and `verification_status = verified`.
  - Daily totals shown in the UI treat Together posts as `points * 2` to reflect both users’ contributions.

- **Delete behavior**
  - Owners can delete their own posts until the post is verified. Deleting removes the row from Supabase and the item from the feed.

- **Notifications & permissions**
  - The app requests notification permission at startup (Android 13+ and iOS) using `permission_handler`.
  - Android uses `POST_NOTIFICATIONS`. iOS includes `NSUserNotificationUsageDescription` in `Info.plist`.
  - Notifications are created in the `notifications` table and fetched per user.

### Data model guarantees
- Per-user points are stored directly on each post (`water_fetch_posts.points`).
- Together posts store the partner’s display name in `partner_user_id` for easy partner lookup.
- Row Level Security (RLS) ensures users can only insert/update their own data.

## 🛠️ Development

### Building the App
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### Code Analysis
```bash
# Run Flutter analyzer
flutter analyze

# Check for errors only
flutter analyze --no-fatal-infos | findstr "error"
```

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🔒 Security Features

- **Firebase Authentication** with secure token management
- **Row Level Security** in Supabase database
- **User isolation** - users can only modify their own data
- **Input validation** and sanitization
- **Secure API endpoints** with proper authentication

## 📊 Database Schema

### User Profiles
- `firebase_uid`: Unique Firebase user identifier
- `display_name`: User's display name
- `email`: User's email address
- `photo_url`: Profile picture URL
- `created_at`: Account creation timestamp
- `updated_at`: Last update timestamp

### Water Fetch Posts
- `id`: Unique post identifier
- `firebase_uid`: Post creator's Firebase UID
- `message`: Activity description
- `fetch_type`: 'Single' or 'Together'
- `partner_user_id`: Partner's display name (for Together mode)
- `points`: Per-user points stored for the post
  - Single: 0.5 (1 bottle) or 1.0 (2 bottles)
  - Together: 0.25 (1 bottle) or 0.5 (2 bottles) per user
- `verification_status`: 'pending', 'verified', or 'rejected'
- `verified_by`: Array of user IDs who verified
- `rejected_by`: Array of user IDs who rejected
- `created_at`: Post creation timestamp

## 🚀 Deployment

### Android Release
1. **Generate keystore**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing** in `android/app/build.gradle.kts`
3. **Build release APK**
   ```bash
   flutter build apk --release
   ```

4. **Upload to Google Play Store**

### Web Deployment
```bash
flutter build web
flutter deploy
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for authentication services
- **Supabase** for database infrastructure
- **Material Design** for UI components

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](issues) page
2. Create a new issue with detailed description
3. Include device information and error logs

## 🔄 Version History

- **v1.0.0**: Initial release with core functionality
- **v1.1.0**: Added Together mode and improved navigation
- **v1.2.0**: Enhanced authentication flow and bug fixes

---

**Made with ❤️ using Flutter**

*Track your water fetching, compete with friends, and stay hydrated!*
