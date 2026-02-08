# Stripe правила
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }
-keep class com.stripe.android.pushProvisioning.** { *; }

# Flutter правила
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Общие
-keepattributes Signature,Annotation
-dontwarn com.stripe.**
-dontwarn com.reactnativestripesdk.**
