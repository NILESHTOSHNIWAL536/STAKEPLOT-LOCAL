package com.stakeplot.pfa

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.util.Log
import android.util.TypedValue
import android.widget.RemoteViews
import androidx.work.*
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.math.*

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

                val nextFetchDateStr = HomeWidgetPlugin.getData(context).getString("next_fetch_date", "") ?: ""

                val (countdownText, percentFinished) = if (nextFetchDateStr.isNotEmpty()) {
                    calculateCountdownAndPercent(nextFetchDateStr)
                } else {
                    calculateNext8AMCountdownAndPercent()
                }

                views.setTextViewText(R.id.next_fetch_title, "Next Fetch in")
                views.setTextViewText(R.id.next_fetch_countdown, countdownText)
                views.setTextViewText(R.id.next_fetch_timestamp, getCurrentDateRange(context))

                val pieBitmap = drawClassicPieBitmap(
                    context,
                    sizeInDp = 120,
                    percent = percentFinished,
                    filledColorHex = "#4B4D73",
                    backgroundColorHex = "#E6E6E6",
                    centerDot = true
                )
                views.setImageViewBitmap(R.id.next_fetch_ring, pieBitmap)

                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("navigate_to_tab", "fetch")
                }
                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    launchIntent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.next_fetch_layout, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Update failed: ${e.message}", e)
            }
        }

        // Smart scheduling (dynamic)
        val nextInterval = calculateSmartIntervalMinutes(context)
        scheduleWork(context, nextInterval)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        val initialInterval = calculateSmartIntervalMinutes(context)
        scheduleWork(context, initialInterval)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        WorkManager.getInstance(context).cancelUniqueWork("NextFetchWidgetWork")
    }

    // -------------------------------
    // Smart WorkManager scheduling
    // -------------------------------
    fun scheduleWork(context: Context, intervalMinutes: Long) {
        try {
            val workRequest = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                intervalMinutes, TimeUnit.MINUTES
            ).setConstraints(
                Constraints.Builder()
                    .setRequiresBatteryNotLow(false)
                    .build()
            ).build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                "NextFetchWidgetWork",
                ExistingPeriodicWorkPolicy.UPDATE,
                workRequest
            )

            Log.d(TAG, "Scheduled smart refresh every $intervalMinutes min")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to schedule WorkManager: ${e.message}", e)
        }
    }

    private fun calculateSmartIntervalMinutes(context: Context): Long {
        return try {
            val nextFetchDateStr = HomeWidgetPlugin.getData(context).getString("next_fetch_date", "") ?: ""
            if (nextFetchDateStr.isEmpty()) return 15L

            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("UTC")
            val nextFetchDate = sdf.parse(nextFetchDateStr) ?: return 15L

            val diffMinutes = (nextFetchDate.time - Date().time) / (1000 * 60)
            if (diffMinutes in 0..120) 5L else 15L
        } catch (e: Exception) {
            Log.e(TAG, "Smart interval error: ${e.message}")
            15L
        }
    }

    // -------------------------
    // Time + UI logic (same as before)
    // -------------------------
    private fun calculateCountdownAndPercent(nextFetchDateStr: String): Pair<String, Int> {
        try {
            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("UTC")
            val parsed = sdf.parse(nextFetchDateStr)
                ?: run {
                    val localSdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
                    localSdf.parse(nextFetchDateStr)
                }

            if (parsed == null) return Pair("Not Scheduled", 0)

            val now = Date()
            val next = parsed.time

            if (next <= now.time) return Pair("Overdue", 100)

            val dayMs = 24L * 60 * 60 * 1000
            var prev = next - dayMs
            while (prev > now.time) prev -= dayMs
            if (prev >= next) prev = next - dayMs

            val totalWindow = next - prev
            val remaining = next - now.time
            val elapsed = totalWindow - remaining

            val percent = when {
                totalWindow <= 0 -> 0
                elapsed <= 0 -> 0
                elapsed >= totalWindow -> 100
                else -> ((elapsed.toDouble() / totalWindow.toDouble()) * 100.0).roundToInt()
            }

            val countdownText = calculateDiff(next)
            return Pair(countdownText, percent)
        } catch (e: Exception) {
            Log.e(TAG, "Parse error: ${e.message}")
            return calculateNext8AMCountdownAndPercent()
        }
    }

    private fun calculateNext8AMCountdownAndPercent(): Pair<String, Int> {
        val calendar = Calendar.getInstance()
        val now = calendar.time
        calendar.set(Calendar.HOUR_OF_DAY, 8)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        if (now.after(calendar.time)) calendar.add(Calendar.DAY_OF_MONTH, 1)
        val next8 = calendar.time.time
        val dayMs = 24L * 60 * 60 * 1000
        val prev8 = next8 - dayMs

        val totalWindow = next8 - prev8
        val remaining = next8 - now.time
        val elapsed = totalWindow - remaining

        val percent = ((elapsed.toDouble() / totalWindow.toDouble()) * 100.0).roundToInt()
        val countdownText = calculateNext8AMCountdown()
        return Pair(countdownText, percent)
    }

    private fun calculateDiff(targetEpochMs: Long): String {
        val now = Date()
        val diff = targetEpochMs - now.time
        if (diff <= 0) return "Overdue"
        val hours = (diff / (1000 * 60 * 60)).toInt()
        val minutes = ((diff / (1000 * 60)) % 60).toInt()
        return if (hours > 0) "${hours}h : ${minutes}m" else "${minutes}m"
    }

    private fun calculateNext8AMCountdown(): String {
        val calendar = Calendar.getInstance()
        val now = calendar.time
        calendar.set(Calendar.HOUR_OF_DAY, 8)
        calendar.set(Calendar.MINUTE, 0)
        calendar.set(Calendar.SECOND, 0)
        calendar.set(Calendar.MILLISECOND, 0)
        if (now.after(calendar.time)) calendar.add(Calendar.DAY_OF_MONTH, 1)
        val diff = calendar.time.time - now.time
        val hours = (diff / (1000 * 60 * 60)).toInt()
        val minutes = ((diff / (1000 * 60)) % 60).toInt()
        return if (hours > 0) "${hours}h : ${minutes}m" else "${minutes}m"
    }

    private fun getCurrentDateRange(context: Context): String {
        val sdf = SimpleDateFormat("dd MMM", Locale.getDefault())
        val calendar = Calendar.getInstance()
        val today = sdf.format(calendar.time)
        calendar.add(Calendar.DAY_OF_MONTH, 1)
        val tomorrow = sdf.format(calendar.time)
        return "$today"
    }

    private fun dpToPx(context: Context, dp: Float): Int =
        TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, context.resources.displayMetrics).toInt()

    private fun drawClassicPieBitmap(
        context: Context,
        sizeInDp: Int,
        percent: Int,
        filledColorHex: String,
        backgroundColorHex: String,
        centerDot: Boolean
    ): Bitmap {
        val sizePx = dpToPx(context, sizeInDp.toFloat())
        val bmp = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

        val center = sizePx / 2f
        val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.parseColor(backgroundColorHex)
        }
        val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.parseColor(filledColorHex)
        }

        val fullRect = RectF(0f, 0f, sizePx.toFloat(), sizePx.toFloat())
        canvas.drawOval(fullRect, bgPaint)
        if (percent > 0) {
            val sweep = (360f * percent) / 100f
            val path = Path()
            path.moveTo(center, center)
            path.arcTo(fullRect, -90f, sweep, false)
            path.close()
            canvas.drawPath(path, fillPaint)
        }
        
        return bmp
    }
}
