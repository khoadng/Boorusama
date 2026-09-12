package com.degenk.boorusama

import android.app.Activity
import android.content.Intent
import android.provider.DocumentsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class CacheDocumentsChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "cache_documents")

    fun register() {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "openCache") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val kind = call.argument<String>("kind")
            if (kind != "images" && kind != "videos") {
                result.error("invalid_cache", "Unknown cache", null)
                return@setMethodCallHandler
            }
            try {
                val images = call.argument<String>("imagesLabel")
                val videos = call.argument<String>("videosLabel")
                require(!images.isNullOrBlank() && !videos.isNullOrBlank()) {
                    "Localized cache labels are required"
                }
                // The system browser can query the provider without a Flutter engine.
                check(activity.getSharedPreferences("cache_documents", 0).edit()
                    .putString("images", images).putString("videos", videos).commit()) {
                    "Could not store cache labels"
                }
                activity.contentResolver.notifyChange(
                    DocumentsContract.buildRootsUri("${activity.packageName}.cache.documents"), null,
                )
                val uri = DocumentsContract.buildRootUri("${activity.packageName}.cache.documents", kind)
                activity.startActivity(Intent(Intent.ACTION_VIEW).apply {
                    setDataAndType(uri, DocumentsContract.Root.MIME_TYPE_ITEM)
                })
                result.success(null)
            } catch (error: Exception) {
                result.error("open_failed", error.message, null)
            }
        }
    }
}
