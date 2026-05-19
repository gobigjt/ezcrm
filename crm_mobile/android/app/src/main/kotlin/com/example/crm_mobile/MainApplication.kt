package com.redonix.ezcrm

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "ezcrm_push",
                "EzCRM Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "EzCRM push notifications"
                enableVibration(true)
                enableLights(true)
            }
            getSystemService(NotificationManager::class.java)
                ?.createNotificationChannel(channel)
        }
    }
}
