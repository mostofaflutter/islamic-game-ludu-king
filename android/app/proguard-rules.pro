# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Mobile Ads (AdMob) Rules
-keep public class com.google.android.gms.ads.** {
    public *;
}
-keep public class com.google.ads.** {
    public *;
}

# AdMob Mediation
-keep class com.google.ads.mediation.** {
    *;
}
-keep class * extends com.google.android.gms.ads.mediation.MediationAdapter {
    *;
}
-keep class * extends com.google.android.gms.ads.mediation.customevent.CustomEvent {
    *;
}

# Google Play Services
-keep class com.google.android.gms.common.** { *; }
-keep interface com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Google Mobile Ads Flutter Plugin
-keep class io.flutter.plugins.googlemobileads.** { *; }

# Preserve WebView interfaces for Ads
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
}
-keepclassmembers class * extends android.webkit.WebChromeClient {
    public void *(android.webkit.WebView, java.lang.String);
}

# Attributes needed for reflection, annotations, and debugging
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes Exceptions
-keepattributes EnclosingMethod
-keepattributes SourceFile,LineNumberTable

# AudioPlayers Plugin
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

# Flutter TTS Plugin
-keep class com.tundralabs.fluttertts.** { *; }
-dontwarn com.tundralabs.fluttertts.**

# Share Plus Plugin
-keep class dev.fluttercommunity.plus.share.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**

# Suppress benign warnings
-dontwarn com.google.android.gms.**
-dontwarn com.google.ads.**
-dontwarn io.flutter.plugins.googlemobileads.**
-dontwarn android.webkit.**
