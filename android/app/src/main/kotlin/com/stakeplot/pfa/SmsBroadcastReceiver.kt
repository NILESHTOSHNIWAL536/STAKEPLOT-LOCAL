package com.stakeplot.pfa

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Status
import io.flutter.plugin.common.EventChannel

class SmsBroadcastReceiver : BroadcastReceiver() {

    var eventSink: EventChannel.EventSink? = null

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != SmsRetriever.SMS_RETRIEVED_ACTION) return
        val extras = intent.extras ?: return
        val status = extras[SmsRetriever.EXTRA_STATUS] as? Status ?: return

        when (status.statusCode) {
            CommonStatusCodes.SUCCESS -> {
                val message = extras.getString(SmsRetriever.EXTRA_SMS_MESSAGE) ?: return
                // Match exactly 6 consecutive digits (matches _otpCodeLength = 6)
                val otp = Regex("\\b(\\d{6})\\b").find(message)?.value ?: return
                eventSink?.success(otp)
            }
            CommonStatusCodes.TIMEOUT -> {
                eventSink?.error("TIMEOUT", "SMS retrieval timed out", null)
            }
        }
    }
}
