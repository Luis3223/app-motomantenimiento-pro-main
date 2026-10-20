package com.aistudio.motomantenimiento.motomantenimiento_pro

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "maintenance_alerts",
                "Avisos de mantenimiento",
                NotificationManager.IMPORTANCE_HIGH,
            )
            channel.description = "Recordatorios de aceite y avisos de Casa Racing"
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }
}
