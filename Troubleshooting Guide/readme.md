# 📘 Troubleshooting Guide: Running Flutter Apps on a Real Android Device

This guide helps resolve common issues when setting up Flutter to run directly on an Android phone.

---

## 1. Prerequisites Check

Before troubleshooting, confirm you have the required tools installed:

* **Java JDK 17 or higher** → Needed for Gradle & Android builds.
* **Android SDK** → Provides `adb` (Android Debug Bridge) & build tools.
* **Flutter SDK** → The actual framework.
* **USB Debugging enabled** → Allows your PC to communicate with the phone.
* **Phone drivers installed** (for Windows) → Required for the system to detect the device.

Run:

```powershell
flutter doctor
```

👉 This command highlights missing dependencies.

---

## 2. Common Problems & Fixes

### 🔹 Problem 1: Device Not Detected

**Symptoms:**

* `flutter devices` shows no device.
* `adb devices` output is empty.

**Fix:**

1. Enable **Developer Options** on phone → enable **USB Debugging**.
2. Run:

   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

   You should see your device listed.
3. If still not visible:

   * On **Windows**: Install your phone’s **USB driver** (Samsung, Xiaomi, etc.).
   * On **Linux/macOS**: Install `android-tools-adb`.

---

### 🔹 Problem 2: `adb` Not Found

**Symptoms:**

* Error: `'adb' is not recognized as an internal or external command`.

**Fix:**

* Add Android SDK tools to PATH.
  Example (Windows):

  ```
  C:\Users\<YourName>\AppData\Local\Android\Sdk\platform-tools
  ```
* Restart terminal and check:

  ```powershell
  adb --version
  ```

---

### 🔹 Problem 3: Java JDK Issues

**Symptoms:**

* Error: `Gradle requires Java 17 or higher`
* Error: `'java' is not recognized as a command`

**Fix:**

1. Install **Java JDK 17** (not just JRE).
2. Set environment variable:

   ```
   JAVA_HOME = C:\Program Files\Java\jdk-17
   ```
3. Add to PATH:

   ```
   %JAVA_HOME%\bin
   ```
4. Verify:

   ```powershell
   java -version
   ```

---

### 🔹 Problem 4: Gradle Build Fails

**Symptoms:**

* Errors about missing Android SDK / build tools.

**Fix:**

1. Open Android Studio → go to **SDK Manager**.
2. Install:

   * **Android SDK Platform (latest)**
   * **SDK Tools (build-tools, platform-tools)**
3. Set environment variable:

   ```
   ANDROID_HOME = C:\Users\<YourName>\AppData\Local\Android\Sdk
   ```
4. Add to PATH:

   ```
   %ANDROID_HOME%\platform-tools
   ```

---

### 🔹 Problem 5: “Device Unauthorized”

**Symptoms:**

* `adb devices` shows your phone but marked as *unauthorized*.

**Fix:**

1. Disconnect & reconnect USB.
2. On your phone → accept the **Allow USB Debugging** popup.
3. If not showing, reset RSA keys:

   ```powershell
   adb kill-server
   adb start-server
   adb devices
   ```

---

### 🔹 Problem 6: Flutter Doctor Still Complains

**Symptoms:**

* Even after installation, `flutter doctor` shows missing SDK or tools.

**Fix:**

1. Run:

   ```powershell
   flutter config --android-sdk "C:\Users\<YourName>\AppData\Local\Android\Sdk"
   flutter doctor --android-licenses
   ```
2. Accept all licenses with `y`.

---

## 3. Final Test

1. Connect phone → enable USB debugging.
2. Run:

   ```powershell
   flutter devices
   ```

   → Your device should be listed.
3. Start the app:

   ```powershell
   flutter run
   ```

These are some of the common issues which you might find troublesome if you aere doing this for the first time
