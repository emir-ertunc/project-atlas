package app.projectatlas.personal.workout

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import app.projectatlas.personal.MainActivity
import app.projectatlas.personal.R
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.max

internal class RestTimerNotificationBridge(
    private val activity: Activity,
    binaryMessenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private data class RestNotificationPayload(
        val endsAtEpochMillis: Long,
        val title: String,
        val body: String,
    )

    private val channel = MethodChannel(binaryMessenger, RestNotificationContract.METHOD_CHANNEL)
    private val handler = Handler(Looper.getMainLooper())
    private var scheduledRunnable: Runnable? = null
    private var pendingPermissionPayload: RestNotificationPayload? = null
    private var pendingPermissionResult: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scheduleRestTimerNotification" -> scheduleFromCall(call, result)
            "cancelRestTimerNotification" -> {
                cancelCurrentNotification()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun detach() {
        channel.setMethodCallHandler(null)
        pendingPermissionResult?.success(status("failed", "Notification request cancelled."))
        pendingPermissionPayload = null
        pendingPermissionResult = null
        cancelCurrentNotification()
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != REST_NOTIFICATION_PERMISSION_REQUEST) {
            return false
        }

        val payload = pendingPermissionPayload
        val result = pendingPermissionResult
        pendingPermissionPayload = null
        pendingPermissionResult = null

        if (payload == null || result == null) {
            return true
        }

        val granted = grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        if (granted) {
            schedulePayload(payload, result)
        } else {
            result.success(status("permissionDenied"))
        }
        return true
    }

    private fun scheduleFromCall(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null) {
            result.success(status("failed", "Missing notification arguments."))
            return
        }

        val endsAtEpochMillis = (arguments["endsAtEpochMillis"] as? Number)?.toLong()
        val title = arguments["title"] as? String
        val body = arguments["body"] as? String
        if (endsAtEpochMillis == null || title == null || body == null) {
            result.success(status("failed", "Invalid notification arguments."))
            return
        }

        schedulePayload(
            RestNotificationPayload(
                endsAtEpochMillis = endsAtEpochMillis,
                title = title,
                body = body,
            ),
            result,
        )
    }

    private fun schedulePayload(
        payload: RestNotificationPayload,
        result: MethodChannel.Result,
    ) {
        cancelCurrentNotification()
        if (!hasNotificationPermission()) {
            requestNotificationPermission(payload, result)
            return
        }

        createNotificationChannel()
        val delayMillis = max(0L, payload.endsAtEpochMillis - System.currentTimeMillis())
        val runnable = Runnable {
            scheduledRunnable = null
            showNotification(payload)
        }
        scheduledRunnable = runnable
        handler.postDelayed(runnable, delayMillis)
        result.success(status("scheduled"))
    }

    private fun requestNotificationPermission(
        payload: RestNotificationPayload,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(status("permissionDenied"))
            return
        }

        pendingPermissionResult?.success(status("failed", "Notification request replaced."))
        pendingPermissionPayload = payload
        pendingPermissionResult = result
        activity.requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            REST_NOTIFICATION_PERMISSION_REQUEST,
        )
    }

    private fun hasNotificationPermission(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager = notificationManager()
        val existingChannel = notificationManager.getNotificationChannel(REST_CHANNEL_ID)
        if (existingChannel != null) {
            return
        }

        val channel = NotificationChannel(
            REST_CHANNEL_ID,
            "Rest timer",
            NotificationManager.IMPORTANCE_HIGH,
        )
        notificationManager.createNotificationChannel(channel)
    }

    private fun showNotification(payload: RestNotificationPayload) {
        if (!hasNotificationPermission()) {
            return
        }

        val contentIntent = Intent(activity, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            activity,
            REST_NOTIFICATION_ID,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(activity, REST_CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(activity)
        }

        val notification = builder
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(payload.title)
            .setContentText(payload.body)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setPriority(Notification.PRIORITY_HIGH)
            .build()
        notificationManager().notify(REST_NOTIFICATION_ID, notification)
    }

    private fun cancelCurrentNotification() {
        scheduledRunnable?.let { handler.removeCallbacks(it) }
        scheduledRunnable = null
        notificationManager().cancel(REST_NOTIFICATION_ID)
    }

    private fun notificationManager(): NotificationManager {
        return activity.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    private fun status(name: String, message: String? = null): Map<String, String> {
        return if (message == null) {
            mapOf("status" to name)
        } else {
            mapOf("status" to name, "message" to message)
        }
    }

    companion object {
        private const val REST_CHANNEL_ID = "project_atlas_rest_timer"
        private const val REST_NOTIFICATION_ID = 405
        private const val REST_NOTIFICATION_PERMISSION_REQUEST = 4405
    }
}
