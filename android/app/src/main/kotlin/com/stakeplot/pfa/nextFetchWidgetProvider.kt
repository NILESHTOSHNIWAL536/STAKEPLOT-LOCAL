package com.stakeplot.pfa

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.util.Log
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import androidx.work.*
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.math.roundToInt

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

                val dateStr = HomeWidgetPlugin
                    .getData(context)
                    .getString("next_fetch_date", "") ?: ""

                Log.d(TAG, "Fetched next_fetch_date='$dateStr'")

                // ───────────────────────────────
                // CASE A → NO DATE (Option A)
                // ───────────────────────────────
                if (dateStr.isEmpty()) {
                    Log.d(TAG, "No date found → showing fallback text")

                    views.setTextViewText(R.id.next_fetch_title, "No Fetch Scheduled")
                    views.setTextViewText(R.id.next_fetch_countdown, "")
                    views.setTextViewText(R.id.next_fetch_timestamp, "")

                    // Hide ring graphic
                    views.setViewVisibility(R.id.next_fetch_ring, View.GONE)
                    views.setViewVisibility(R.id.next_fetch_status, View.GONE)

                    appWidgetManager.updateAppWidget(appWidgetId, views)
                    continue
                }

                // ───────────────────────────────
                // CASE B → VALID DATE → Normal UI
                // ───────────────────────────────
                val (countdownText, percent) = calculateCountdownAndPercent(dateStr)

                views.setTextViewText(R.id.next_fetch_title, "Next Fetch in")
                views.setTextViewText(R.id.next_fetch_countdown, countdownText)
                views.setTextViewText(R.id.next_fetch_timestamp, getDateLabel(dateStr))

                val ringBitmap = drawPie(
                    context,
                    sizeDp = 120,
                    percent = percent,
                    fillColor = "#4B4D73",
                    bgColor = "#E6E6E6"
                )

                views.setViewVisibility(R.id.next_fetch_ring, View.VISIBLE)
                views.setImageViewBitmap(R.id.next_fetch_ring, ringBitmap)

                // Tap → Open App
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("navigate_to_tab", "fetch")
                }

                val pendingIntent = android.app.PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    intent,
                    android.app.PendingIntent.FLAG_UPDATE_CURRENT or
                            android.app.PendingIntent.FLAG_IMMUTABLE
                )

                views.setOnClickPendingIntent(R.id.next_fetch_layout, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)

            } catch (e: Exception) {
                Log.e(TAG, "Widget update error: ${e.message}", e)
            }
        }

        // Smart refresh interval
        val interval = calculateSmartIntervalMinutes(context)
        scheduleWork(context, interval)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleWork(context, 15)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        WorkManager.getInstance(context).cancelUniqueWork("NextFetchWidgetWork")
    }

    // ─────────────────────────────────────────────
    // SMART WORKER SCHEDULING
    // ─────────────────────────────────────────────
    fun scheduleWork(context: Context, interval: Long) {
        try {
            val req = PeriodicWorkRequestBuilder<WidgetUpdateWorker>(
                interval, TimeUnit.MINUTES
            ).build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "NextFetchWidgetWork",
                    ExistingPeriodicWorkPolicy.UPDATE,
                    req
                )

            Log.d(TAG, "Scheduled update every $interval minutes")
        } catch (e: Exception) {
            Log.e(TAG, "scheduleWork error: ${e.message}")
        }
    }

    private fun calculateSmartIntervalMinutes(context: Context): Long {
        return try {
            val iso = HomeWidgetPlugin.getData(context)
                .getString("next_fetch_date", "") ?: ""

            if (iso.isEmpty()) return 15L

            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("UTC")

            val nextUTC = sdf.parse(iso) ?: return 15L

            // Backend sends 8AM UTC → we convert to IST by subtracting 5h30m
            val nextIST = Date(nextUTC.time - (5 * 60 + 30) * 60 * 1000)

            val diffMin = (nextIST.time - Date().time) / (1000 * 60)

            Log.d(TAG, "SmartInterval → diffMin = $diffMin")

            if (diffMin in 0..120) 5L else 15L

        } catch (e: Exception) {
            Log.e(TAG, "Interval calc error: ${e.message}")
            15L
        }
    }

    // ─────────────────────────────────────────────
    // COUNTDOWN + PERCENT
    // ─────────────────────────────────────────────
    private fun calculateCountdownAndPercent(dateStr: String): Pair<String, Int> {
        return try {
            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdf.timeZone = TimeZone.getTimeZone("UTC")

            val nextUTC = sdf.parse(dateStr) ?: return Pair("No Fetch Scheduled", 0)

            // Convert UTC → IST (backend uses Z)
            val nextIST = Date(nextUTC.time - (5 * 60 + 30) * 60 * 1000)

            val now = Date()

            if (nextIST.time <= now.time) return Pair("Overdue", 100)

            val diff = nextIST.time - now.time

            val hours = (diff / (1000 * 60 * 60)).toInt()
            val minutes = ((diff / (1000 * 60)) % 60).toInt()

            val countdown = if (hours > 0) "${hours}h : ${minutes}m" else "${minutes}m"

            // Percent calculation (1-day window)
            val prevDay = nextIST.time - 24L * 60 * 60 * 1000
            val elapsed = now.time - prevDay
            val percent = ((elapsed.toDouble() / (24 * 60 * 60 * 1000)) * 100)
                .coerceIn(0.0, 100.0)
                .roundToInt()

            Pair(countdown, percent)

        } catch (e: Exception) {
            Log.e(TAG, "Countdown error: ${e.message}")
            Pair("No Fetch Scheduled", 0)
        }
    }

    private fun getDateLabel(dateStr: String): String {
        return try {
            val sdfSrc = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            sdfSrc.timeZone = TimeZone.getTimeZone("UTC")

            val date = sdfSrc.parse(dateStr) ?: return ""
            val dateIST = Date(date.time - (5 * 60 + 30) * 60 * 1000)

            val sdfOut = SimpleDateFormat("dd MMM", Locale.getDefault())
            sdfOut.format(dateIST)
        } catch (e: Exception) {
            ""
        }
    }

    // ─────────────────────────────────────────────
    // PIE DRAWING
    // ─────────────────────────────────────────────
    private fun dpToPx(context: Context, dp: Int): Int =
        TypedValue
            .applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp.toFloat(), context.resources.displayMetrics)
            .toInt()

    private fun drawPie(
        context: Context,
        sizeDp: Int,
        percent: Int,
        fillColor: String,
        bgColor: String
    ): Bitmap {

        val size = dpToPx(context, sizeDp)
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)

        val rect = RectF(0f, 0f, size.toFloat(), size.toFloat())
        val center = size / 2f

        val bg = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor(bgColor)
            style = Paint.Style.FILL
        }

        val fill = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor(fillColor)
            style = Paint.Style.FILL
        }

        canvas.drawOval(rect, bg)

        if (percent > 0) {
            val sweep = 360f * percent / 100f
            val path = Path().apply {
                moveTo(center, center)
                arcTo(rect, -90f, sweep)
                close()
            }
            canvas.drawPath(path, fill)
        }

        return bmp
    }
}
