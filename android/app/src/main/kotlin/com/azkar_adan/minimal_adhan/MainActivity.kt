package com.muslim.azkar.app

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// AudioServiceActivity لا FlutterActivity.
//
// حزمة audio_service تشترط أن يرث النشاط المضيف AudioServiceActivity: هي من
// تضع محرّك فلاتر في FlutterEngineCache تحت الاسم الذي تبحث عنه خدمة
// التشغيل الأمامية. مع FlutterActivity العادي ترمي AudioService.init
// استثناء PlatformException، فيلتقطه quran_library ويكمل بلا تكامل مع
// النظام — أي بلا مشغّل في مركز الإشعارات، والتلاوة تتوقف بمجرد إغلاق
// التطبيق لأن لا خدمة أمامية تُبقي العملية حيّة.
//
// AudioServiceActivity يرث FlutterActivity، فلا شيء آخر يتغيّر.
class MainActivity : AudioServiceActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // فحص إذن شاشة الأذان بلا فتح الإعدادات — الإضافة لا توفّر فحصًا
        // منفصلًا عن الطلب (AppPermissions.fullScreen).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "azkary/azan")
            .setMethodCallHandler { call, result ->
                if (call.method == "canUseFullScreenIntent") {
                    result.success(
                        if (Build.VERSION.SDK_INT >= 34) {
                            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                                .canUseFullScreenIntent()
                        } else true
                    )
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        applyAzanLockScreenFlags(intent)
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: Intent) {
        applyAzanLockScreenFlags(intent)
        super.onNewIntent(intent)
    }

    // إشعار الأذان (fullScreenIntent) يطلق هذا النشاط والشاشة مقفلة: نسمح
    // له بالظهور فوق القفل وإضاءة الشاشة — لإشعار الأذان وحده، لا لأي
    // فتح آخر، حتى لا يصبح التطبيق متاحًا بلا فك القفل.
    // الحمولة 'azan' = AzanAlarm.payload في lib/features/prayer/azan_alarm.dart
    private fun applyAzanLockScreenFlags(intent: Intent?) {
        val isAzan = intent?.action == "SELECT_NOTIFICATION" &&
            intent.getStringExtra("payload") == "azan"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(isAzan)
            setTurnScreenOn(isAzan)
        } else {
            @Suppress("DEPRECATION")
            val flags = WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
            if (isAzan) window.addFlags(flags) else window.clearFlags(flags)
        }
    }
}
