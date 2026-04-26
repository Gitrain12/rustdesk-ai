# RustDesk AI - ProGuard Rules
# Optimization and obfuscation rules for Android build

# Flutter specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# RustDesk specific
-keep class com.rustdesk.** { *; }
-keep class com.carriez.flutter_hbb.** { *; }

# WebRTC
-keep class org.webrtc.** { *; }

# Google WebRTC ProGuard
-keep class libc.** { *; }
-keep class org.webrtc.** { *; }

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.stream.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Flutter rust bridge
-keep class me.n快车.bridge.** { *; }

# General Android rules
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Encryption libraries
-keep class org.libsodium.** { *; }
-keep class org.signal.** { *; }

# Audio/Video codecs
-keep class org.webrtc.** { *; }
-keep class org.chromium.** { *; }

# Network security
-keepnames class * extends java.net.Socket
-keep class * implements java.io.Serializable { *; }

# Prevent stripping of ViewBinding classes
-keep class * implements androidx.viewbinding.ViewBinding {
    public static ** inflate(android.view.LayoutInflater);
    public static ** inflate(android.view.LayoutInflater, android.view.ViewGroup, boolean);
}

# Permissions
-keep class android.Manifest { *; }
-keep class android.Manifest$permission { *; }