package com.stakeplot.pfa  // Same package.

import android.content.BroadcastReceiver  // Base class for receiving broadcasts.
import android.content.Context
import android.content.Intent
import android.util.Log  // For logging.

class WidgetClickReceiver : BroadcastReceiver() {  // Matches the intent target.
    override fun onReceive(context: Context, intent: Intent) {  // Called when broadcast arrives.
        if (intent.action == "com.stakeplot.WIDGET_CLICK") {  // Filter: Only handle our custom action.
            val clickedItem = intent.getStringExtra("clicked_item") ?: "Unknown"  // Grab the extra data.
            Log.d("WidgetClick", "Widget item clicked: $clickedItem")  // Log it! Check via `adb logcat | grep WidgetClick`.
            // You can add more here later: e.g., analytics, SharedPrefs update, or even a silent API call.
        }
    }
}