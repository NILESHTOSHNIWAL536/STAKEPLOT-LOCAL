package com.stakeplot.pfa

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

/**
 * Background worker that updates the NextFetchWidgetProvider.
 * Also dynamically adjusts update frequency based on remaining time.
 */
class WidgetUpdateWorker(
    private val ctx: Context,
    params: WorkerParameters
) : CoroutineWorker(ctx, params) {

    override suspend fun doWork(): Result {
        return try {
            Log.d("WidgetUpdateWorker", "Running periodic widget update")

            // Trigger widget update
            val appWidgetManager = AppWidgetManager.getInstance(ctx)
            val widget = ComponentName(ctx, NextFetchWidgetProvider::class.java)
            val ids = appWidgetManager.getAppWidgetIds(widget)
            if (ids.isNotEmpty()) {
                NextFetchWidgetProvider().onUpdate(ctx, appWidgetManager, ids)
                Log.d("WidgetUpdateWorker", "Updated ${ids.size} widget(s)")
            }

            // Recalculate remaining time and reschedule next job accordingly
            val nextInterval = getSmartIntervalMinutes(ctx)
            Log.d("WidgetUpdateWorker", "Rescheduling next update in $nextInterval min")

            NextFetchWidgetProvider().scheduleWork(ctx, nextInterval)

            Result.success()
        } catch (e: Exception) {
            Log.e("WidgetUpdateWorker", "Error updating widget: ${e.message}", e)
            Result.retry()
        }
    }

    /**
     * Determines smart refresh interval based on remaining time.
     * Returns minutes (5 min if <2h left, else 15 min).
     */
    private fun getSmartIntervalMinutes(context: Context): Long {
        return try {
            val nextFetchDateStr = HomeWidgetPlugin.getData(context).getString("next_fetch_date", "") ?: ""
            if (nextFetchDateStr.isEmpty()) return 15L

            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("UTC")
            val nextFetchDate = sdf.parse(nextFetchDateStr) ?: return 15L

            val diffMinutes = (nextFetchDate.time - Date().time) / (1000 * 60)
            return if (diffMinutes in 0..120) 5L else 15L  // 5 min if within 2h, else 15 min
        } catch (e: Exception) {
            Log.e("WidgetUpdateWorker", "Smart interval error: ${e.message}")
            15L
        }
    }
}
