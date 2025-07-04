#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

-keep class org.xmlpull.v1.** { *;}
 -dontwarn org.xmlpull.v1.**

#Firebase
-keep class com.google.firebase.** { *; }
-keep class com.firebase.** { *; }

#Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.app.richato.** { *; }