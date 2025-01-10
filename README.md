# malaysiasafe

1.This app was built using Android Studio, it is recommended to open this file using Android Studio. If you are well-versed in another IDE you can proceed with it.

# Instructions

1. Install Android Studio - https://developer.android.com/studio
2. Download Flutter & Dart SDK and set up the environment. This is crucial before open up the project. For full tutorial refer - https://www.youtube.com/watch?v=mMeQhLGD-og
3. After completion, download the code from GitHub - ZIP file.
4. Extract the file into OS (C:) as MalaysiaSafe or any other name you prefer.
5. Dont nest the project into a folder. For example the root of the folder should be like this - C:\malaysiasafe. Not like this - C:\malaysiasafe\malaysiasafe. The project
   will be open but there will be some errors running it.
6. After that, Open project in Android Studio and choose the folder where you extract it - C:\malaysiasafe.
7. Go to Firebase Console - https://console.firebase.google.com.
8. Log in with your email address.
9. I've already added you as a Editor, so you can access the Database I created.
10. Click the malaysiasafe project, go to Settings in left side bar, click Project Settings, scroll down to bottom, you'll se "Your Apps" section.
11. In there, download the "google-services.json" file.
12. Then insert the .json file into your opened Android Studio project directory. The .json file must be inside MalaysiaSafe(or your project name)/app. Don't insert anywhere else.
13. There will be existing .json file in there, there will be a pop-up box indicating to "Overwrite" the file. Click "Overwrite". This must be done so that you can connect with the database.
14. If you want to run the app using emulator in Android Studio, go to Device Manager to install any device but with API Level 34 - Upside Down Cake. I've used Pixel 4XL API 34.
15. If you do any changes to the code, make sure after every changes, type "flutter clean" then "flutter pub get" in the terminal to sync and refresh the build.
16. Use "flutter run" in the terminal or Start button at top right of the page to run the app.
17. If you want to use your own device to run like me, connect your device with USB, Enable USB Debugging, go to Device Manager Pair Wireless Debugging connect with QR/Code with Android Studio. The app
    will run in your phone.
18. If you followed all these steps correctly and orderly, you should run the app without any errors.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! GOOD LUCK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
