package com.stakeplot.pfa

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log

private const val PREFS_NAME = "stakeplot_widget_prefs"
private const val PREFS_KEY_SET = "selected_options"
private const val ACTION_WIDGET_CLICK = "com.stakeplot.WIDGET_CLICK"
private const val ACTION_WIDGET_CLICKED = "com.stakeplot.WIDGET_CLICKED"
private const val ACTION_WIDGET_RESET = "com.stakeplot.WIDGET_RESET"
private const val RESET_DELAY_MS = 2 * 60 * 1000L // 3 minutes

class WidgetClickReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        try {
            when (intent.action) {
                ACTION_WIDGET_CLICK -> {
                    val clickedItem = intent.getStringExtra("clicked_item") ?: return
                    Log.d("WidgetClick", "Clicked: $clickedItem")

                    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    val current = prefs.getStringSet(PREFS_KEY_SET, emptySet())?.toMutableSet() ?: mutableSetOf()

                    // No-deselect: if already selected, ignore
                    if (current.contains(clickedItem)) {
                        Log.d("WidgetClick", "Already selected, ignoring: $clickedItem")
                        return
                    }

                    current.add(clickedItem)
                    prefs.edit().putStringSet(PREFS_KEY_SET, current).apply()
                    Log.d("WidgetClick", "Added selection. Now: $current")

                    // Optional backward-compatible broadcast
                    val notify = Intent(ACTION_WIDGET_CLICKED).apply {
                        putExtra("clicked_item", clickedItem)
                    }
                    context.sendBroadcast(notify)

                    // Force immediate widget update
                    forceWidgetUpdate(context)

                    // Schedule (or reschedule) reset
                    scheduleReset(context, RESET_DELAY_MS)
                }

                ACTION_WIDGET_RESET -> {
                    Log.d("WidgetClick", "Reset alarm fired: clearing selections")
                    val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    prefs.edit().remove(PREFS_KEY_SET).apply()
                    forceWidgetUpdate(context)
                }
            }
        } catch (e: Exception) {
            Log.e("WidgetClick", "Exception in receiver: ${e.message}", e)
        }
    }

    private fun forceWidgetUpdate(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context.packageName, ClickableWidget::class.java.name)
        val ids = appWidgetManager.getAppWidgetIds(thisWidget)
        if (ids.isNotEmpty()) {
            ClickableWidget().onUpdate(context, appWidgetManager, ids)
            Log.d("WidgetClick", "Forced update for ${ids.size} widget(s)")
        }
    }

    private fun scheduleReset(context: Context, delayMs: Long) {
        try {
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val resetIntent = Intent(context, WidgetClickReceiver::class.java).apply {
                action = ACTION_WIDGET_RESET
            }
            val pending = PendingIntent.getBroadcast(
                context,
                0xFEE1,
                resetIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val triggerAt = System.currentTimeMillis() + delayMs
            am.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pending)
            Log.d("WidgetClick", "Scheduled reset in ${delayMs}ms (at $triggerAt)")
        } catch (e: Exception) {
            Log.e("WidgetClick", "Failed to schedule reset: ${e.message}", e)
        }
    }
}
