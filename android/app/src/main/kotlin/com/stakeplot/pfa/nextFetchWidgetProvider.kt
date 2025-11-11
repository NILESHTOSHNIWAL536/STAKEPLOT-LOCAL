package com.stakeplot.pfa

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*
import java.util.TimeZone  // Add this import for explicit TZ

class NextFetchWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "NextFetchWidget"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "Updating ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.next_fetch_widget_layout)
                
                // Try to get nextFetchDate from shared prefs (set via Flutter home_widget plugin)
                val nextFetchDateStr = HomeWidgetPlugin.getData(context).getString("next_fetch_date", "") ?: ""
                val countdown = if (nextFetchDateStr.isNotEmpty()) {
                    calculateCountdown(nextFetchDateStr)
                } else {
                    // Fallback: Calculate to next 8 AM if no date provided
                    calculateNext8AMCountdown()
                }

                // Set title and countdown
                views.setTextViewText(R.id.next_fetch_title, "Next Fetch")
                views.setTextViewText(R.id.next_fetch_countdown, countdown)
                views.setTextViewText(R.id.next_fetch_timestamp, getCurrentDateRange(context)) // Pass context

                Log.d(TAG, "Countdown: $countdown, nextFetchDate: $nextFetchDateStr")

                // Set click intent to open app (e.g., to fetch screen)
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("navigate_to_tab", "fetch") // Optional: Navigate to fetch tab
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    appWidgetId, // Unique per widget instance
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.next_fetch_layout, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Update failed: ${e.message}")
            }
        }
    }

    private fun calculateCountdown(nextFetchDateStr: String): String {
        try {
            // Single robust parse for ISO with Z (UTC): Explicitly set TZ to UTC to avoid local bias
            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US) // US locale for consistency
            sdf.timeZone = TimeZone.getTimeZone("UTC") // Force UTC parsing for 'Z'
            val nextFetchDate = sdf.parse(nextFetchDateStr)
            if (nextFetchDate == null) {
                // Fallback to non-Z formats (assume local time)
                val localSdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
                val localDate = localSdf.parse(nextFetchDateStr)
                if (localDate != null) {
                    return calculateDiff(localDate.time) // Use as local epoch
                }
                return "Not Scheduled"
            }

            return calculateDiff(nextFetchDate.time) // UTC epoch diff
        } catch (e: Exception) {
            Log.e(TAG, "Parse error: ${e.message} for string: $nextFetchDateStr")
            return calculateNext8AMCountdown()
        }
    }

    // Helper: Calculate diff from epoch ms (handles both UTC and local)
    private fun calculateDiff(targetEpochMs: Long): String {
        val now = Date() // Current epoch (UTC ms)
        val diff = targetEpochMs - now.time
        if (diff <= 0) return "Overdue"

        val hours = (diff / (1000 * 60 * 60)).toInt()
        val minutes = ((diff / (1000 * 60)) % 60).toInt()
        return if (hours > 0) {
            "${hours}:${minutes.toString().padStart(2, '0')}"
        } else {
            "${minutes} min"
        }
    }

    private fun calculateNext8AMCountdown(): String {  // Changed from 9 AM to 8 AM
        val calendar = Calendar.getInstance()
        val now = calendar.time
        calendar.set(Calendar.HOUR_OF_DAY, 8)  // Now 8 AM
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)

        if (now.after(calendar.time)) {
            calendar.add(Calendar.DAY_OF_MONTH, 1)
        }

        val diff = calendar.time.time - now.time
        val hours = (diff / (1000 * 60 * 60)).toInt()
        val minutes = ((diff / (1000 * 60)) % 60).toInt()

        return if (hours > 0) {
            "${hours}:${minutes.toString().padStart(2, '0')}"
        } else {
            "${minutes} min"
        }
    }

    // Optional: Update getCurrentDateRange() to show actual next fetch day if date is set
    private fun getCurrentDateRange(context: Context): String {
        val widgetData = HomeWidgetPlugin.getData(context)  // Now with context param
        val nextFetchDateStr = widgetData.getString("next_fetch_date", "") ?: ""
        if (nextFetchDateStr.isNotEmpty()) {
            try {
                val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
                sdf.timeZone = TimeZone.getTimeZone("UTC") // Same fix
                val nextDate = sdf.parse(nextFetchDateStr) ?: return "Today"
                val displaySdf = SimpleDateFormat("dd MMM", Locale.getDefault())
                return displaySdf.format(nextDate)  // e.g., "14 Nov" (local display)
            } catch (e: Exception) {
                Log.e(TAG, "Timestamp parse error: ${e.message}")
                // Fallback
            }
        }
        // Original fallback
        val sdf = SimpleDateFormat("dd MMM", Locale.getDefault())
        val calendar = Calendar.getInstance()
        val today = sdf.format(calendar.time)
        calendar.add(Calendar.DAY_OF_MONTH, 1)
        val tomorrow = sdf.format(calendar.time)
        return "$today - $tomorrow"
    }
}