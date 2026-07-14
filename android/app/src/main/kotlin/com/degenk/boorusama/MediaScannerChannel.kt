package com.degenk.boorusama

import android.content.Context
import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException

class MediaScannerChannel(
    private val context: Context,
    messenger: BinaryMessenger,
) {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    fun register() {
        channel.setMethodCallHandler { call, result ->
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
                context.sendBroadcast(
                    Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)),
                )
            } else {
                MediaScannerConnection.scanFile(
                    context,
                    arrayOf(file.toString()),
                    arrayOf(file.name),
                ) { scannedPath, uri ->
                    Log.d(TAG, "Scan completed: $scannedPath, URI: $uri")
                }
            }

            return "Success show image $path in Gallery"
        } catch (e: FileNotFoundException) {
            Log.e(TAG, "File not found: ${e.message}")
            return "Error: ${e.message}"
        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception: ${e.message}")
            return "Error: ${e.message}"
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error: ${e.message}")
            return "Error: ${e.message}"
        }
    }

    companion object {
        private const val CHANNEL_NAME = "media_scanner"
        private const val TAG = "Media Scanner"
    }
}
