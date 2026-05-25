package com.stakeplot.pfa

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.appwidget.AppWidgetManager
import androidx.activity.result.IntentSenderRequest
import androidx.activity.result.contract.ActivityResultContracts
import com.google.android.gms.auth.api.identity.GetPhoneNumberHintIntentRequest
import com.google.android.gms.auth.api.identity.Identity
import com.google.android.gms.auth.api.phone.SmsRetriever
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterFragmentActivity() {

    // Channels
    private val NAV_CHANNEL = "com.stakeplot.pfa/navigation"
    private val ICON_CHANNEL = "com.stakeplot.pfa/app_icon"
    private val PHONE_HINT_CHANNEL = "com.stakeplot.pfa/phone_hint"
    private val SMS_OTP_CHANNEL = "com.stakeplot.pfa/sms_otp"

    // Phone hint state
    private var phoneHintResult: MethodChannel.Result? = null
    private val phoneHintLauncher = registerForActivityResult(
        ActivityResultContracts.StartIntentSenderForResult()
    ) { result ->
        if (result.resultCode == RESULT_OK) {
            try {
                val raw = Identity.getSignInClient(this).getPhoneNumberFromIntent(result.data)
                // Strip country code, keep last 10 digits for Indian numbers
                val normalized = raw.replace(Regex("[^0-9]"), "").takeLast(10)
                phoneHintResult?.success(normalized)
            } catch (e: Exception) {
                Log.e("PhoneHint", "Parse error: ${e.message}")
                phoneHintResult?.error("PARSE_ERROR", e.message, null)
            }
        } else {
            phoneHintResult?.success(null) // User dismissed picker
        }
        phoneHintResult = null
    }

    // SMS OTP state
    private val smsReceiver = SmsBroadcastReceiver()
    private var smsReceiverRegistered = false

    // Widget prefs keys
    private val WIDGET_PREFS = "stakeplot_widget_prefs"
    private val WIDGET_FRIENDS_KEY = "friend_list_json"
    private val WIDGET_SELECTED_KEY = "selected_options"

    // Full alias names as declared in AndroidManifest.xml
    private val ICON_COMPONENTS = listOf(
        "com.stakeplot.pfa.IconDefault",
        "com.stakeplot.pfa.Icon1",
        "com.stakeplot.pfa.Icon2",
        "com.stakeplot.pfa.Icon3"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // -------------------------
        // Navigation / Widget channel (merged your methods)
        // -------------------------
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NAV_CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d("MainActivity", "NAV channel called: ${call.method}")
                try {
                    when (call.method) {
                        "getInitialRoute" -> {
                            val navigateToTab = intent?.getStringExtra("navigate_to_tab")
                            Log.d("MainActivity", "getInitialRoute: navigate_to_tab=$navigateToTab")
                            if (navigateToTab != null) {
                                result.success(mapOf("navigate_to_tab" to navigateToTab))
                            } else {
                                result.success(null)
                            }
                        }

                        // Returns JSON array string of selected items (or "[]")
                        "getLastWidgetSelection" -> {
                            val prefs = applicationContext.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
                            val selectedSet = prefs.getStringSet(WIDGET_SELECTED_KEY, emptySet()) ?: emptySet()
                            val arr = JSONArray()
                            selectedSet.forEach { arr.put(it) }
                            val jsonStr = arr.toString()
                            Log.d("MainActivity", "getLastWidgetSelection -> $jsonStr")
                            result.success(jsonStr)
                        }

                        // Accepts List<String> (from Dart) or a JSON string; stores friend list and updates widget
                        "setWidgetFriends" -> {
                            val args = call.arguments
                            val jsonString: String = when (args) {
                                is String -> args
                                is List<*> -> {
                                    val arr = JSONArray()
                                    args.forEach { arr.put(it) }
                                    arr.toString()
                                }
                                else -> "[]"
                            }

                            val prefs = applicationContext.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
                            prefs.edit().putString(WIDGET_FRIENDS_KEY, jsonString).apply()
                            Log.d("MainActivity", "setWidgetFriends stored: $jsonString")

                            // Force widget update so the labels change immediately
                            try {
                                val appWidgetManager = AppWidgetManager.getInstance(applicationContext)
                                val thisWidget = ComponentName(applicationContext.packageName, ClickableWidget::class.java.name)
                                val ids = appWidgetManager.getAppWidgetIds(thisWidget)
                                if (ids.isNotEmpty()) {
                                    ClickableWidget().onUpdate(applicationContext, appWidgetManager, ids)
                                    Log.d("MainActivity", "Forced widget update for ${ids.size} instance(s)")
                                } else {
                                    Log.d("MainActivity", "No widget instances to update")
                                }
                            } catch (e: Exception) {
                                Log.e("MainActivity", "Error forcing widget update: ${e.message}", e)
                            }

                            result.success(true)
                        }

                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    Log.e("MainActivity", "MethodChannel handler error: ${e.message}", e)
                    result.error("ERROR", e.message, null)
                }
            }

        // -------------------------
        // Phone Number Hint channel
        // Uses Google Identity Services — no permissions needed, Play Store safe
        // -------------------------
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHONE_HINT_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "requestPhoneHint") {
                    phoneHintResult = result
                    requestPhoneNumberHint()
                } else {
                    result.notImplemented()
                }
            }

        // -------------------------
        // SMS OTP autofill channel (SMS Retriever API — no READ_SMS permission)
        // -------------------------
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_OTP_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    smsReceiver.eventSink = events
                    startSmsRetriever()
                }
                override fun onCancel(arguments: Any?) {
                    smsReceiver.eventSink = null
                    if (smsReceiverRegistered) {
                        try { unregisterReceiver(smsReceiver) } catch (_: Exception) {}
                        smsReceiverRegistered = false
                    }
                }
            })

        // -------------------------
        // Icon change channel (friend's code)
        // -------------------------
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ICON_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    if (call.method == "changeIcon") {
                        val aliasShort = call.argument<String>("alias") ?: "IconDefault"
                        val fullAlias = "com.stakeplot.pfa.$aliasShort"
                        Log.d("MainActivity", "Requested icon: $fullAlias")
                        val success = changeAppIcon(fullAlias)
                        result.success(success)
                    } else {
                        result.notImplemented()
                    }
                } catch (e: Exception) {
                    Log.e("ICON", "Icon channel error: ${e.message}", e)
                    result.error("ERROR", e.message, null)
                }
            }
    }

    private fun requestPhoneNumberHint() {
        val request = GetPhoneNumberHintIntentRequest.builder().build()
        Identity.getSignInClient(this)
            .getPhoneNumberHintIntent(request)
            .addOnSuccessListener { pendingIntent ->
                try {
                    phoneHintLauncher.launch(
                        IntentSenderRequest.Builder(pendingIntent.intentSender).build()
                    )
                } catch (e: Exception) {
                    Log.e("PhoneHint", "Launch failed: ${e.message}")
                    phoneHintResult?.error("LAUNCH_FAILED", e.message, null)
                    phoneHintResult = null
                }
            }
            .addOnFailureListener { e ->
                Log.e("PhoneHint", "Hint unavailable: ${e.message}")
                phoneHintResult?.error("UNAVAILABLE", e.message, null)
                phoneHintResult = null
            }
    }

    @Suppress("UnspecifiedRegisterReceiverFlag")
    private fun startSmsRetriever() {
        SmsRetriever.getClient(this).startSmsRetriever()
            .addOnSuccessListener {
                if (!smsReceiverRegistered) {
                    registerReceiver(
                        smsReceiver,
                        IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION),
                        SmsRetriever.SEND_PERMISSION,
                        null
                    )
                    smsReceiverRegistered = true
                    Log.d("SmsRetriever", "Started — waiting for OTP SMS (5 min window)")
                }
            }
            .addOnFailureListener { e ->
                Log.e("SmsRetriever", "Failed to start: ${e.message}")
            }
    }

    // Toggle aliases: disable all, enable chosen
    private fun changeAppIcon(fullAlias: String): Boolean {
        val pm = packageManager
        try {
            if (!ICON_COMPONENTS.contains(fullAlias)) {
                Log.e("ICON", "Alias not allowed: $fullAlias")
                return false
            }

            // Disable all aliases
            ICON_COMPONENTS.forEach { comp ->
                try {
                    val compName = ComponentName(packageName, comp)
                    pm.setComponentEnabledSetting(
                        compName,
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                } catch (e: Exception) {
                    Log.w("ICON", "Could not disable $comp: ${e.message}")
                }
            }

            // Enable the chosen alias
            val target = ComponentName(packageName, fullAlias)
            pm.setComponentEnabledSetting(
                target,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            Log.d("ICON", "Switched icon to: $fullAlias")
            return true
        } catch (e: Exception) {
            Log.e("ICON", "Error switching icon: ${e.message}", e)
            return false
        }
    }

    // Lifecycle + intent handling (merged)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        Log.d("MainActivity", "onCreate: Intent extras=${intent?.extras?.toString()}")
        val navigateToTab = intent?.getStringExtra("navigate_to_tab")
        if (navigateToTab != null) {
            Log.d("MainActivity", "Received navigate_to_tab: $navigateToTab")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, NAV_CHANNEL).invokeMethod("navigateToTab", mapOf("tab" to navigateToTab))
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        Log.d("MainActivity", "onNewIntent: Intent extras=${intent.extras?.toString()}")

        // navigate_to_tab handling (preserve original behavior)
        intent.getStringExtra("navigate_to_tab")?.let { tab ->
            Log.d("MainActivity", "New intent navigate_to_tab: $tab")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                // Use navigateToTab with tab map
                MethodChannel(messenger, NAV_CHANNEL).invokeMethod("navigateToTab", mapOf("tab" to tab))
                // Also keep backward-compatible call your friend used (if needed)
                // MethodChannel(messenger, NAV_CHANNEL).invokeMethod("navigateToFinance", null)
            }
        }

        // clicked_option handling (your original widget click)
        intent.getStringExtra("clicked_option")?.let { clicked ->
            Log.d("MainActivity", "New intent clicked_option: $clicked")
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, NAV_CHANNEL).invokeMethod("widgetClicked", mapOf("option" to clicked))
            }
        }
    }
}
