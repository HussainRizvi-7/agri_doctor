# Flutter
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.**  { *; }

# TensorFlow Lite GPU Delegate
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Firebase (common)
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

-dontwarn com.google.firebase.**
-dontwarn org.tensorflow.lite.**