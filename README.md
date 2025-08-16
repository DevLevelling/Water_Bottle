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
- **Single Mode**: Individual water fetching (1.0 points)
- **Together Mode**: Collaborative water fetching (0.5 points each)
- **Real-time posting** with custom messages
- **User selection** for collaborative activities
- **Activity history** with timestamps

### 🏆 Points & Verification System
- **Point-based scoring** system
- **Verification status** (pending, verified, rejected)
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

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project
2. Enable Authentication with Email/Password
3. Enable reCAPTCHA Enterprise
4. Download `google-services.json`
5. Add SHA-1 fingerprint for your app

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

## 📱 Usage Guide

### Getting Started
1. **Launch the app** - You'll see the welcome screen
2. **Create an account** - Sign up with email and full name
3. **Start tracking** - Post your first water fetching activity

### Creating Activities
1. **Choose mode**: Single (1.0 points) or Together (0.5 points each)
2. **For Together mode**: Select a partner from the dropdown
3. **Write a message** describing your activity
4. **Post activity** - It will appear in your feed

### Understanding Points
- **Single Mode**: You get 1.0 points when verified
- **Together Mode**: Both you and your partner get 0.5 points each
- **Total points**: Sum of all verified activities
- **Verification**: Activities start as "pending" until verified

### Navigation
- **Home Tab**: View and create activities
- **Leaderboard Tab**: See user rankings
- **Profile Tab**: View your stats and logout

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
- `points`: Points awarded (0.5 for Together, 1.0 for Single)
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
