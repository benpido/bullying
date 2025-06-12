package com.example.bullying

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ComponentName
import android.content.pm.PackageManager

import io.flutter.embedding.android.FlutterActivity




class MainActivity : FlutterActivity() {
    private val CHANNEL = "bullying/icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "changeIcon") {
                val alias = call.argument<String>("alias") ?: "MainActivity"
                changeIcon(alias)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun changeIcon(alias: String) {
        val packageName = applicationContext.packageName
        val aliases = listOf(
            "MainActivity",
            "FinanceIcon",
            "CalendarIcon",
            "CalculatorIcon",
            "NotesIcon"
        )
        val pm = applicationContext.packageManager
        for (activity in aliases) {
            val state = if (activity == alias) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            val component = ComponentName(packageName, "$packageName.$activity")
            pm.setComponentEnabledSetting(component, state, PackageManager.DONT_KILL_APP)
        }
    }
}
