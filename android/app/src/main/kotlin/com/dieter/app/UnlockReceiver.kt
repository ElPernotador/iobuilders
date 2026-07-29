package com.dieter.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import java.util.Calendar

/**
 * Listens for ACTION_USER_PRESENT (screen unlock after first keyguard dismiss).
 * Fires the morning mission notification once per day after the configured minimum hour,
 * with a delay of morningDelayMinutes.
 *
 * Fallback: if this receiver is killed, the alarm-based scheduler in NotificationScheduler
 * handles rescheduling after boot.
 */
class UnlockReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_USER_PRESENT) return

        val prefs: SharedPreferences = context.getSharedPreferences("dieter", Context.MODE_PRIVATE)
        val today = todayDateString()
        val lastFired = prefs.getString("morning_fired_date", "")

        if (lastFired == today) return // already fired today

        val minHour = prefs.getInt("morning_min_hour", 8)
        val delayMinutes = prefs.getInt("morning_delay_minutes", 10)
        val enabled = prefs.getBoolean("morning_reminder_enabled", true)

        if (!enabled) return

        val now = Calendar.getInstance()
        if (now.get(Calendar.HOUR_OF_DAY) < minHour) return

        // Mark fired for today before scheduling to prevent duplicates
        prefs.edit().putString("morning_fired_date", today).apply()

        val delayMs = delayMinutes * 60 * 1000L
        Handler(Looper.getMainLooper()).postDelayed({
            NotificationScheduler.showMorningMission(context)
        }, delayMs)
    }

    private fun todayDateString(): String {
        val cal = Calendar.getInstance()
        return "${cal.get(Calendar.YEAR)}-${(cal.get(Calendar.MONTH)+1).toString().padStart(2,'0')}-${cal.get(Calendar.DAY_OF_MONTH).toString().padStart(2,'0')}"
    }
}
