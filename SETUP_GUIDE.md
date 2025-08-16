# 🚰 Water Bottle App - Firebase + Supabase Setup Guide

## 🎯 **What We've Built**

A **hybrid authentication system** that combines:
- **Firebase Authentication** for user login/signup
- **Supabase** for data storage (water fetching posts, user profiles)

## 📋 **Prerequisites**

- Flutter project with Firebase already configured
- Supabase project created
- Your Supabase credentials (already configured)

## 🔧 **Setup Steps**

### **Step 1: Database Setup**

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `SUPABASE_SETUP.sql`
4. Click **Run** to execute the SQL

This will create:
- `user_profiles` table (stores user information linked to Firebase UID)
- `water_fetch_posts` table (stores water fetching activities)
- Row Level Security (RLS) policies for data protection
- Indexes for better performance

### **Step 2: Test the Integration**

1. **Run your Flutter app**: `flutter run`
2. **Sign in with Firebase** (existing functionality)
3. **Create a water fetching post** - it will be stored in Supabase
4. **Verify/reject posts** - changes will be synced to Supabase

## 🔄 **How It Works**

### **Authentication Flow**
```
User signs in → Firebase Auth → Get Firebase UID → Create/Update Supabase profile
```

### **Data Flow**
```
Create Post → Supabase → Real-time sync → All users see updates
Verify/Reject → Supabase → Real-time sync → All users see changes
```

## 📱 **Features**

✅ **Firebase Authentication** - Login, signup, user management  
✅ **Supabase Data Storage** - Persistent water fetching posts  
✅ **Real-time Updates** - Posts appear immediately for all users  
✅ **User Profiles** - Automatically created after Firebase auth  
✅ **Post Verification** - Users can verify/reject each other's posts  
✅ **Points System** - Single mode (1.0 point) vs Together mode (0.5 points each)  

## 🗄️ **Database Schema**

### **user_profiles**
- `firebase_uid` - Links to Firebase user
- `display_name` - User's display name
- `photo_url` - Profile picture URL
- `email` - User's email

### **water_fetch_posts**
- `firebase_uid` - Who created the post
- `message` - Post content (default: "I have bought water")
- `fetch_type` - "Single" or "Together"
- `partner_user_id` - Partner for Together mode
- `points` - Points awarded (1.0 or 0.5)
- `verification_status` - pending/verified/rejected
- `verified_by` - Array of users who verified
- `rejected_by` - Array of users who rejected

## 🔒 **Security Features**

- **Row Level Security (RLS)** enabled on all tables
- Users can only modify their own data
- Public read access for posts and profiles
- Firebase UID validation for data integrity

## 🚀 **Next Steps**

1. **Test the app** - Create posts, verify/reject them
2. **Customize the UI** - Modify colors, layouts, etc.
3. **Add more features** - Leaderboards, achievements, etc.
4. **Deploy** - Build and release your app

## 🆘 **Troubleshooting**

### **Common Issues**

1. **"No Firebase user authenticated"**
   - Make sure user is signed in with Firebase first
   - Check Firebase configuration

2. **"Error creating/updating user profile"**
   - Verify Supabase connection
   - Check if tables exist and RLS is configured

3. **Posts not appearing**
   - Check Supabase logs for errors
   - Verify database permissions

### **Debug Mode**

Enable debug mode in `lib/config/supabase_config.dart`:
```dart
static const bool enableDebug = true;
```

## 📞 **Support**

If you encounter issues:
1. Check the console logs for error messages
2. Verify your Supabase credentials
3. Ensure the database tables are created correctly
4. Check RLS policies are active

---

**🎉 You now have a fully functional Firebase + Supabase hybrid app!**
