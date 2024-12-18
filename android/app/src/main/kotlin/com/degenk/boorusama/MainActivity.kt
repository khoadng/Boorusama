package com.degenk.boorusama

import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "refreshGallery" -> {
                    val path: String? = call.argument("path")
                    result.success(refreshMedia(path))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun refreshMedia(path: String?): String {
        try {
            if (path == null) {
                throw IllegalArgumentException("Path cannot be null")
            }

            val file = File(path)
            if (!file.exists()) {
                throw FileNotFoundException("File does not exist: $path")
            }

            if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.Q) {
                applicationContext.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)))
            } else {
                MediaScannerConnection.scanFile(
                    applicationContext,
                    arrayOf(file.toString()),
                    arrayOf(file.name)
                ) { path, uri ->
                    Log.d("Media Scanner", "Scan completed: $path, URI: $uri")
                }
            }
            return "Success show image $path in Gallery"
        } catch (e: FileNotFoundException) {
            Log.e("Media Scanner", "File not found: ${e.message}")
            return "Error: ${e.message}"
        } catch (e: SecurityException) {
            Log.e("Media Scanner", "Security exception: ${e.message}")
            return "Error: ${e.message}"
        } catch (e: Exception) {
            Log.e("Media Scanner", "Unexpected error: ${e.message}")
            return "Error: ${e.message}"
        }
    }
}