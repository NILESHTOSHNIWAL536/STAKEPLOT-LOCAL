package com.stakeplot.pfa

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import org.json.JSONArray

private const val PREFS_NAME = "stakeplot_widget_prefs"
private const val PREFS_KEY_SET = "selected_options"
private const val PREFS_FRIENDS_JSON = "friend_list_json"
private const val ACTION_WIDGET_CLICK = "com.stakeplot.WIDGET_CLICK"

class ClickableWidget : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // Update UI on custom actions
        if (intent.action == "com.stakeplot.WIDGET_CLICKED" || intent.action == ACTION_WIDGET_CLICK || intent.action == "com.stakeplot.WIDGET_RESET") {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = android.content.ComponentName(context.packageName, ClickableWidget::class.java.name)
            val ids = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, ids)
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.clickable_widget_layout)
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

                // Read friend list JSON -> names list
                val friendJson = prefs.getString(PREFS_FRIENDS_JSON, "[]")
                val names = mutableListOf<String>()
                try {
                    val arr = JSONArray(friendJson)
                    for (i in 0 until arr.length()) names.add(arr.optString(i))
                } catch (e: Exception) {
                    Log.e("ClickableWidget", "parse friend json err: ${e.message}", e)
                }

                // Read selected set
                val selected = prefs.getStringSet(PREFS_KEY_SET, emptySet()) ?: emptySet()

                // Slot ids mapping
                val slotIds = listOf(R.id.click_text1, R.id.click_text2, R.id.click_text3, R.id.click_text4)

                // Labels - show up to 4 names; hide empty rows
                for (i in slotIds.indices) {
                    val id = slotIds[i]
                    if (i < names.size && names[i].isNotEmpty()) {
                        views.setTextViewText(id, names[i])
                        views.setViewVisibility(id, android.view.View.VISIBLE)
                    } else {
                        views.setTextViewText(id, "")
                        views.setViewVisibility(id, android.view.View.GONE)
                    }
                }

                // Reset visuals for all
                val defaultColor = 0xFF212121.toInt()
                val defaultSizeSp = 16f
                for (id in slotIds) {
                    views.setInt(id, "setBackgroundResource", android.R.color.transparent)
                    views.setTextColor(id, defaultColor)
                    views.setTextViewTextSize(id, android.util.TypedValue.COMPLEX_UNIT_SP, defaultSizeSp)
                }

                // Highlight selected (multiple allowed) - compare by friend name
                for (i in names.indices) {
                    val name = names[i]
                    if (selected.contains(name)) {
                        val id = slotIds[i]
                        views.setInt(id, "setBackgroundResource", R.drawable.widget_selected_bg)
                        views.setTextColor(id, 0xFFFFFFFF.toInt())
                        views.setTextViewTextSize(id, android.util.TypedValue.COMPLEX_UNIT_SP, 18f)
                    }
                }

                // Wire PendingIntents (clicks send friend name as clicked_item)
                for (i in slotIds.indices) {
                    val id = slotIds[i]
                    if (i < names.size && names[i].isNotEmpty()) {
                        val name = names[i]
                        val clickIntent = Intent(context, WidgetClickReceiver::class.java).apply {
                            action = ACTION_WIDGET_CLICK
                            putExtra("clicked_item", name)
                        }
                        val pending = PendingIntent.getBroadcast(
                            context,
                            appWidgetId * 10 + (i + 1),
                            clickIntent,
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        )
                        views.setOnClickPendingIntent(id, pending)
                    }
                }

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e("ClickableWidget", "onUpdate failed for widget $appWidgetId: ${e.message}", e)
            }
        }
    }
}
