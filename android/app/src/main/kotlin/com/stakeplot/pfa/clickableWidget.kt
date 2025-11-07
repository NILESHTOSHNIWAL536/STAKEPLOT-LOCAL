package com.stakeplot.pfa  // Your app's package—keep this matching.

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews  // For building the widget's UI remotely (can't use full Views in widgets).

class ClickableWidget : AppWidgetProvider() {  // Name matches your manifest receiver.
    override fun onUpdate(
        context: Context,  // The app context (gives access to resources like layouts).
        appWidgetManager: AppWidgetManager,  // Manages all widgets on the device.
        appWidgetIds: IntArray  // Array of IDs for each instance of this widget (user can add multiples).
    ) {
        Log.d("ClickableWidget", "Updating ${appWidgetIds.size} widgets")  // Debug log: How many widgets to refresh.

        for (appWidgetId in appWidgetIds) {  // Loop per widget instance.
            try {
                Log.d("ClickableWidget", "Creating RemoteViews for widget ID: $appWidgetId")
                val views = RemoteViews(context.packageName, R.layout.clickable_widget_layout)  // Load your XML layout.

                // Set static texts for the 4 clickable items. (Easy to swap with dynamic data from SharedPrefs later.)
                views.setTextViewText(R.id.click_text1, "Option 1")
                views.setTextViewText(R.id.click_text2, "Option 2")
                views.setTextViewText(R.id.click_text3, "Option 3")
                views.setTextViewText(R.id.click_text4, "Option 4")

                // Create PendingIntents for each clickable TextView.
                // Each intent broadcasts to WidgetClickReceiver with a unique extra (no app launch!).
                val clickIntent1 = Intent(context, WidgetClickReceiver::class.java).apply {
                    action = "com.stakeplot.WIDGET_CLICK"  // Custom action to filter in the receiver.
                    putExtra("clicked_item", "Option 1")  // Data passed: What was clicked.
                }
                val pendingIntent1 = PendingIntent.getBroadcast(  // Broadcast instead of Activity (for logging only).
                    context,
                    appWidgetId * 10 + 1, // Unique request code per widget/instance/click (avoids conflicts).
                    clickIntent1,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE  // Standard flags for security/efficiency.
                )
                views.setOnClickPendingIntent(R.id.click_text1, pendingIntent1)  // Wire the click to this intent.

                // Repeat for the other 3 (same pattern, just change extra and request code).
                val clickIntent2 = Intent(context, WidgetClickReceiver::class.java).apply {
                    action = "com.stakeplot.WIDGET_CLICK"
                    putExtra("clicked_item", "Option 2")
                }
                val pendingIntent2 = PendingIntent.getBroadcast(
                    context,
                    appWidgetId * 10 + 2,
                    clickIntent2,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.click_text2, pendingIntent2)

                val clickIntent3 = Intent(context, WidgetClickReceiver::class.java).apply {
                    action = "com.stakeplot.WIDGET_CLICK"
                    putExtra("clicked_item", "Option 3")
                }
                val pendingIntent3 = PendingIntent.getBroadcast(
                    context,
                    appWidgetId * 10 + 3,
                    clickIntent3,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.click_text3, pendingIntent3)

                val clickIntent4 = Intent(context, WidgetClickReceiver::class.java).apply {
                    action = "com.stakeplot.WIDGET_CLICK"
                    putExtra("clicked_item", "Option 4")
                }
                val pendingIntent4 = PendingIntent.getBroadcast(
                    context,
                    appWidgetId * 10 + 4,
                    clickIntent4,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.click_text4, pendingIntent4)

                Log.d("ClickableWidget", "Updating widget ID: $appWidgetId")
                appWidgetManager.updateAppWidget(appWidgetId, views)  // Push the updated UI to the home screen.
            } catch (e: Exception) {  // Error handling: Show "Error" texts if something breaks.
                Log.e("ClickableWidget", "Update failed for widget ID: $appWidgetId, error: ${e.message}", e)
                val views = RemoteViews(context.packageName, R.layout.clickable_widget_layout)
                views.setTextViewText(R.id.click_text1, "Error")
                views.setTextViewText(R.id.click_text2, "Error")
                views.setTextViewText(R.id.click_text3, "Error")
                views.setTextViewText(R.id.click_text4, "Error")
                appWidgetManager.updateAppWidget(appWidgetId, views)
            }
        }
    }
}