package com.stakeplot.adnan.dev

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class StakeplotWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("StakeplotWidget", "Updating ${appWidgetIds.size} widgets")
        for (appWidgetId in appWidgetIds) {
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_layout)
                val widgetData = HomeWidgetPlugin.getData(context)
                val totalSpending = widgetData.getString("total_spending", "₹0") ?: "₹0"
                val categories = widgetData.getString("categories", "None") ?: "None"
                val timestamp = widgetData.getString("timestamp", "01 Jan - 01 Jan") ?: "01 Jan - 01 Jan"

                // Set title, total, and timestamp
                views.setTextViewText(R.id.widget_title, "Expenses")
                views.setTextViewText(R.id.widget_total_spending, "Total: $totalSpending")
                views.setTextViewText(R.id.widget_timestamp, timestamp)

                // Split categories into two columns (up to 2 per column)
                val categoryList = categories.split("\n")
                val leftCategories = categoryList.take(2).joinToString("\n").ifEmpty { "None" }
                val rightCategories = categoryList.drop(2).take(2).joinToString("\n").ifEmpty { "None" }

                // Set left and right column TextViews
                views.setTextViewText(R.id.widget_categories_left, leftCategories)
                views.setTextViewText(R.id.widget_categories_right, rightCategories)

                Log.d("StakeplotWidget", "Data: total=$totalSpending, categories=$categories, time=$timestamp")

                // Set click intent
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_layout, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e("StakeplotWidget", "Update failed: ${e.message}")
            }
        }
    }
}