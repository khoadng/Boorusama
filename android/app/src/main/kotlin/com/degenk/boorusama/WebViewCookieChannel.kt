package com.degenk.boorusama

import android.net.Uri
import android.webkit.CookieManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Reads the cookies the Android WebView would send to a URL.
 *
 * CookieManager only exposes them as a Cookie request header, so each cookie
 * is reported as host-only for the URL's host with no other attributes.
 */
class WebViewCookieChannel(messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)

    fun register() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getCookies" -> {
                    val url: String? = call.argument("url")
                    val host = url?.let { Uri.parse(it).host }
                    if (url == null || host.isNullOrEmpty()) {
                        result.error("INVALID_ARGUMENTS", "Invalid arguments for getCookies", null)
                    } else {
                        result.success(cookies(url, host))
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun cookies(url: String, host: String): List<Map<String, Any>> {
        val header = CookieManager.getInstance().getCookie(url) ?: return emptyList()
        return header.split(";").mapNotNull { part ->
            val separator = part.indexOf('=')
            if (separator <= 0) return@mapNotNull null
            mapOf(
                "name" to part.substring(0, separator).trim(),
                "value" to part.substring(separator + 1).trim(),
                "domain" to host,
                "path" to "/",
            )
        }
    }

    companion object {
        private const val CHANNEL_NAME = "webview_cookies"
    }
}
