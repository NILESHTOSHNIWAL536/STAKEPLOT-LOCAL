package com.stakeplot.adnan.dev

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import android.content.SharedPreferences

class PayableWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("PayableWidget", "Updating ${appWidgetIds.size} widgets")
        val prefs: SharedPreferences = context.getSharedPreferences("widget_prefs", Context.MODE_PRIVATE)

        for (appWidgetId in appWidgetIds) {
            try {
                Log.d("PayableWidget", "Creating RemoteViews for widget ID: $appWidgetId")
                val views = RemoteViews(context.packageName, R.layout.payable_widget_layout)
                val widgetData = try {
                    HomeWidgetPlugin.getData(context)
                } catch (e: Exception) {
                    Log.e("PayableWidget", "Failed to get widget data", e)
                    null
                }

                // Use widgetData if available, otherwise fall back to SharedPreferences
                val toReceive = widgetData?.getString("to_receive", null)
                    ?: prefs.getString("to_receive", "None: ₹0") ?: "None: ₹0"
                val toPay = widgetData?.getString("to_pay", null)
                    ?: prefs.getString("to_pay", "None: ₹0") ?: "None: ₹0"

                Log.d("PayableWidget", "Setting data: toReceive=$toReceive, toPay=$toPay")
                views.setTextViewText(R.id.to_receive_title, "To Receive")
                views.setTextViewText(R.id.to_receive_text, toReceive)
                views.setTextViewText(R.id.to_pay_title, "To Pay")
                views.setTextViewText(R.id.to_pay_text, toPay)

                Log.d("PayableWidget", "Setting PendingIntent for widget ID: $appWidgetId")
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    putExtra("navigate_to_tab", "finance")
                }
                  val pendingIntent = PendingIntent.getActivity(
                    context,
                    appWidgetId, // Unique request code per widget
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.payable_widget_layout, pendingIntent)

                Log.d("PayableWidget", "Updating widget ID: $appWidgetId")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e("PayableWidget", "Update failed for widget ID: $appWidgetId, error: ${e.message}", e)
                val views = RemoteViews(context.packageName, R.layout.payable_widget_layout)
                views.setTextViewText(R.id.to_receive_title, "To Receive")
                views.setTextViewText(R.id.to_receive_text, "Error")
                views.setTextViewText(R.id.to_pay_title, "To Pay")
                views.setTextViewText(R.id.to_pay_text, "Error")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}