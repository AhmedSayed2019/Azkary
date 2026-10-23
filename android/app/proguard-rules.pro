# قواعد R8 للإصدار (minifyEnabled). Flutter يضيف قواعده تلقائيًا؛ هذه
# للإضافات التي تستعمل الانعكاس أو Gson.

# flutter_local_notifications: يسلسل الإشعارات المجدولة بـ Gson
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# android_alarm_manager_plus: يستدعي الخدمة والمستقبلات بالاسم
-keep class dev.fluttercommunity.plus.androidalarmmanager.** { *; }

# audio_service / just_audio (تلاوة المصحف في الخلفية)
-keep class com.ryanheise.** { *; }

# النشاط الرئيسي وقناة azkary/azan
-keep class com.muslim.azkar.app.** { *; }

# Firebase / Firestore
-keep class com.google.firebase.** { *; }
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-dontwarn com.google.firebase.**

# مكوّنات Play المؤجلة يشير إليها محرّك Flutter ولا نستخدمها
-dontwarn com.google.android.play.core.**
