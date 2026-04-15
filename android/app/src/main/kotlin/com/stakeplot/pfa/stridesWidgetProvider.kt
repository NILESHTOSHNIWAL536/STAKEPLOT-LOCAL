package com.stakeplot.pfa

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class StridesWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {

        val prefs = context.getSharedPreferences("stride_prefs", Context.MODE_PRIVATE)
        val streak = prefs.getInt("stride_count", 0)

        for (appWidgetId in appWidgetIds) {

            val views = RemoteViews(context.packageName, R.layout.strides_widgets_layout)

            // ✅ FIXED
            views.setTextViewText(R.id.strides_count, "$streak day")

            // ✅ WEEK STATUS
            val completedDays = listOf(true, true, false, false, false, false, false)

            val ids = listOf(
                R.id.day_mo,
                R.id.day_tu,
                R.id.day_we,
                R.id.day_th,
                R.id.day_fr,
                R.id.day_sa,
                R.id.day_su
            )

            for (i in ids.indices) {
                if (completedDays[i]) {
                    views.setInt(ids[i], "setBackgroundResource", R.drawable.circle_selected)
                } else {
                    views.setInt(ids[i], "setBackgroundResource", R.drawable.circle_unselected)
                }
            }

            // ✅ Click → open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.strides_widget, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        fun updateWidget(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, StridesWidgetProvider::class.java)
            )

            val intent = Intent(context, StridesWidgetProvider::class.java)
            intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)

            context.sendBroadcast(intent)
        }
    }
}