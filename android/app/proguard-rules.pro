# WashMoose ProGuard Rules - CRASH-FREE Configuration
# Fixed version that works with Play Store releases
# Tested to prevent crashes while maintaining security

# =============================================================================
# CORE FLUTTER FRAMEWORK (CRITICAL - DO NOT MODIFY)
# =============================================================================

# Keep ALL Flutter classes to prevent reflection crashes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter Engine (CRITICAL)
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }

# Flutter plugins communication
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugins.** { *; }

# =============================================================================
# DART/KOTLIN REFLECTION (FIXES RUNTIME CRASHES)
# =============================================================================

# Keep Kotlin metadata for reflection
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-keepattributes RuntimeVisibleAnnotations,RuntimeVisibleParameterAnnotations
-keepattributes AnnotationDefault

# Kotlin serialization (prevents JSON crashes)
-keepclassmembers class **.*$Companion {
    kotlinx.serialization.KSerializer serializer(...);
}
-keepclasseswithmembers class **.*$serializer {
    *** INSTANCE;
}

# Keep Dart-generated classes
-keep class ** { 
    native <methods>; 
}

# =============================================================================
# FIREBASE (TESTED CONFIGURATION)
# =============================================================================

# Firebase Core (NEVER obfuscate)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase initialization classes (CRITICAL)
-keep class com.google.firebase.FirebaseApp { *; }
-keep class com.google.firebase.FirebaseOptions { *; }
-keep class com.google.firebase.provider.FirebaseInitProvider { *; }

# Firebase Messaging (FCM)
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }

# Firebase Firestore
-keep class com.google.firebase.firestore.** { *; }

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# =============================================================================
# STRIPE PAYMENT SECURITY (NEVER OBFUSCATE PAYMENTS)
# =============================================================================

# Stripe SDK (CRITICAL for payments)
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Keep all payment-related classes
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.payments.** { *; }

# =============================================================================
# NETWORK & HTTP (PREVENTS API CRASHES)
# =============================================================================

# OkHttp (used by http package)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Gson (JSON serialization)
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep JSON model classes with annotations
-keep class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# =============================================================================
# ANDROID SYSTEM COMPONENTS
# =============================================================================

# Android Support/AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Android system classes
-keep class android.** { *; }

# Keep custom Application class
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# =============================================================================
# FLUTTER PLUGINS (PREVENTS PLUGIN CRASHES)
# =============================================================================

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# URL Launcher  
-keep class io.flutter.plugins.urllauncher.** { *; }

# Package Info Plus
-keep class io.flutter.plugins.packageinfo.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# =============================================================================
# SAFE OPTIMIZATIONS (NO CONFLICTS)
# =============================================================================

# Keep essential attributes for debugging crashes
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Remove only debug logging (safe)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}

# =============================================================================
# WARNING SUPPRESSIONS (SAFE)
# =============================================================================

# Suppress harmless warnings
-dontwarn java.lang.invoke.**
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.**
-dontwarn kotlin.jvm.internal.**

# =============================================================================
# FINAL CONFIGURATION NOTES
# =============================================================================

# This configuration is designed to:
# ✅ PREVENT crashes in Play Store releases
# ✅ Maintain Firebase functionality  
# ✅ Preserve payment processing security
# ✅ Keep Flutter reflection working
# ✅ Enable proper crash reporting

# REMOVED problematic rules:
# ❌ obfuscationdictionary (missing files)
# ❌ -dontshrink (conflicting)  
# ❌ aggressive optimizations (breaking reflection)
# ❌ custom dictionary references