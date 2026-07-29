package com.dieter.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences

/**
 * Restores scheduled reminders after device reboot.
 * flutter_local_notifications handles its own reschedule via the plugin's boot receiver,
 * but this ensures our native prefs-based unlock tracking is consistent.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON") return

        val prefs: SharedPreferences = context.getSharedPreferences("dieter", Context.MODE_PRIVATE)
        // Clear today's fired flag so the unlock receiver fires again if the user unlocks today after reboot
        prefs.edit().remove("morning_fired_date").apply()
    }
}
