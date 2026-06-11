# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase Rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Play Core Rules - Fixes "Missing class com.google.android.play.core..."
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Measurement and Cloud Messaging warnings
-dontwarn com.google.android.gms.internal.measurement.**
-dontwarn com.google.android.gms.internal.cloudmessaging.**

# Image Cropper and common plugins
-dontwarn com.yalantis.ucrop.**
-keep class com.yalantis.ucrop.** { *; }
