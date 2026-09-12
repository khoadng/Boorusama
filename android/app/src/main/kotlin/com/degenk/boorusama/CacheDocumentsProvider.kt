package com.degenk.boorusama

import android.database.Cursor
import android.database.MatrixCursor
import android.os.CancellationSignal
import android.os.Bundle
import android.os.FileObserver
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.provider.DocumentsContract.Document
import android.provider.DocumentsContract.Root
import android.provider.DocumentsProvider
import android.webkit.MimeTypeMap
import android.util.Log
import java.io.File
import java.io.FileNotFoundException
import java.io.FileDescriptor
import java.io.PrintWriter
import java.net.URLConnection
import java.util.concurrent.Executors

/** Read-only access to completed media cache files, never other app storage. */
class CacheDocumentsProvider : DocumentsProvider() {
    private class Listing {
        var rows: List<Array<Any?>> = emptyList()
        var dirty = true
        var loading = false
        var error: Exception? = null
    }

    private val listings = mapOf("images" to Listing(), "videos" to Listing())
    private val scanner = Executors.newSingleThreadExecutor()
    private val observers = mutableMapOf<String, FileObserver>()
    private var cacheObserver: FileObserver? = null

    override fun onCreate(): Boolean {
        for (kind in listings.keys) watchDirectory(kind)
        cacheObserver = object : FileObserver(context!!.cacheDir.path, CREATE or MOVED_TO) {
            override fun onEvent(event: Int, path: String?) {
                val kind = when (path) {
                    "cacheimage" -> "images"
                    "cachevideo" -> "videos"
                    else -> return
                }
                watchDirectory(kind)
                invalidate(kind)
            }
        }.also { it.startWatching() }
        return true
    }

    private fun childrenUri(kind: String) = DocumentsContract.buildChildDocumentsUri(
        "${context!!.packageName}.cache.documents", kind,
    )

    @Synchronized
    private fun watchDirectory(kind: String) {
        observers.remove(kind)?.stopWatching()
        val directory = root(kind)
        if (!directory.isDirectory) return
        observers[kind] = object : FileObserver(
            directory.path, CLOSE_WRITE or DELETE or MOVED_FROM or MOVED_TO or DELETE_SELF or MOVE_SELF,
        ) {
            override fun onEvent(event: Int, path: String?) = invalidate(kind)
        }.also { it.startWatching() }
    }

    private fun invalidate(kind: String) {
        val listing = listings.getValue(kind)
        synchronized(listing) { listing.dirty = true }
        context!!.contentResolver.notifyChange(childrenUri(kind), null)
    }

    override fun shutdown() {
        cacheObserver?.stopWatching()
        synchronized(this) { observers.values.forEach { it.stopWatching() } }
        scanner.shutdownNow()
        super.shutdown()
    }

    override fun dump(fd: FileDescriptor, writer: PrintWriter, args: Array<out String>) {
        for (kind in listOf("images", "videos")) {
            val started = System.currentTimeMillis()
            try {
                queryChildDocuments(kind, null, sortOrder = null).use { cursor ->
                    val types = mutableMapOf<String, Int>()
                    while (cursor.moveToNext()) {
                        val type = cursor.getString(cursor.getColumnIndexOrThrow(Document.COLUMN_MIME_TYPE))
                        types[type] = (types[type] ?: 0) + 1
                    }
                    writer.println("$kind: rows=${cursor.count}, loading=${cursor.extras.getBoolean(DocumentsContract.EXTRA_LOADING)}, mimeTypes=$types, elapsedMs=${System.currentTimeMillis() - started}")
                }
            } catch (error: Exception) {
                writer.println("$kind: query failed")
                error.printStackTrace(writer)
            }
        }
    }

    override fun queryRoots(projection: Array<out String>?): Cursor {
        val cursor = MatrixCursor(projection ?: ROOT_COLUMNS)
        if (!labels.contains("images") || !labels.contains("videos")) return cursor
        for (kind in listOf("images", "videos")) {
            cursor.addRow(cursor.columnNames.map { column ->
                when (column) {
                    Root.COLUMN_ROOT_ID, Root.COLUMN_DOCUMENT_ID -> kind
                    Root.COLUMN_TITLE -> context!!.getString(R.string.app_name)
                    Root.COLUMN_SUMMARY -> label(kind)
                    Root.COLUMN_ICON -> R.mipmap.ic_launcher
                    Root.COLUMN_FLAGS -> Root.FLAG_LOCAL_ONLY or Root.FLAG_SUPPORTS_IS_CHILD
                    Root.COLUMN_MIME_TYPES -> if (kind == "images") "image/*" else "video/*"
                    else -> null
                }
            }.toTypedArray())
        }
        return cursor
    }

    override fun queryDocument(documentId: String, projection: Array<out String>?): Cursor =
        MatrixCursor(projection ?: DOCUMENT_COLUMNS).apply { addDocument(documentId) }

    override fun queryChildDocuments(
        parentDocumentId: String,
        projection: Array<out String>?,
        sortOrder: String?,
    ): Cursor {
        val listing = listings[parentDocumentId] ?: throw FileNotFoundException("Unknown cache")
        synchronized(listing) {
            if (listing.dirty && !listing.loading) {
                listing.dirty = false
                listing.loading = true
                listing.error = null
                scanner.execute { scan(parentDocumentId, listing) }
            }
            listing.error?.let { throw FileNotFoundException(it.message) }
            return MatrixCursor(projection ?: DOCUMENT_COLUMNS).apply {
                for (row in listing.rows) {
                    addRow(columnNames.map { name ->
                        DOCUMENT_COLUMNS.indexOf(name).takeIf { it >= 0 }?.let { row[it] }
                    }.toTypedArray())
                }
                extras = Bundle().apply { putBoolean(DocumentsContract.EXTRA_LOADING, listing.loading) }
                setNotificationUri(context!!.contentResolver, childrenUri(parentDocumentId))
            }
        }
    }

    private fun scan(kind: String, listing: Listing) {
        val started = System.currentTimeMillis()
        try {
            val directory = root(kind)
            val files = directory.listFiles()
            if (files == null && directory.exists()) throw FileNotFoundException("Cannot list cache directory")
            val rows = ArrayList<Array<Any?>>()
            for (file in files.orEmpty()) {
                if (Thread.currentThread().isInterrupted) return
                if (!CACHE_FILENAME.matches(file.name) || !file.isFile) continue
                try {
                    rows.add(documentValues("$kind/${file.name}"))
                } catch (_: FileNotFoundException) {
                    // Eviction can race a directory listing.
                }
            }
            synchronized(listing) { listing.rows = rows }
            Log.d("CacheDocuments", "$kind: scanned ${rows.size} files in ${System.currentTimeMillis() - started}ms")
        } catch (error: Exception) {
            synchronized(listing) { listing.error = error }
            Log.e("CacheDocuments", "Cache listing failed", error)
        } finally {
            synchronized(listing) { listing.loading = false }
            context!!.contentResolver.notifyChange(childrenUri(kind), null)
        }
    }

    override fun getDocumentType(documentId: String): String =
        if (!documentId.contains('/')) {
            root(documentId)
            Document.MIME_TYPE_DIR
        } else {
            mimeType(resolveFile(documentId))
        }

    override fun isChildDocument(parentDocumentId: String, documentId: String): Boolean {
        root(parentDocumentId)
        if (!documentId.startsWith("$parentDocumentId/")) return false
        return try {
            resolveFile(documentId)
            true
        } catch (_: FileNotFoundException) {
            false
        }
    }

    override fun openDocument(
        documentId: String,
        mode: String,
        signal: CancellationSignal?,
    ): ParcelFileDescriptor {
        if (mode != "r") throw FileNotFoundException("Cache is read-only")
        signal?.throwIfCanceled()
        return ParcelFileDescriptor.open(resolveFile(documentId), ParcelFileDescriptor.MODE_READ_ONLY)
    }

    private fun root(kind: String): File {
        val folder = when (kind) {
            "images" -> "cacheimage"
            "videos" -> "cachevideo"
            else -> throw FileNotFoundException("Unknown cache")
        }
        val expected = File(context!!.cacheDir.canonicalFile, folder)
        if (expected.canonicalFile != expected) throw FileNotFoundException("Invalid cache directory")
        return expected
    }

    private fun resolveFile(id: String): File {
        val kind = id.substringBefore('/')
        val name = id.substringAfter('/', "")
        if (!CACHE_FILENAME.matches(name)) throw FileNotFoundException("Invalid cache document")
        val directory = root(kind)
        val file = File(directory, name)
        if (file.canonicalFile != file || !file.isFile) {
            throw FileNotFoundException("Cache document unavailable")
        }
        return file
    }

    private fun MatrixCursor.addDocument(id: String) {
        val values = documentValues(id)
        addRow(columnNames.map { name ->
            DOCUMENT_COLUMNS.indexOf(name).takeIf { it >= 0 }?.let { values[it] }
        }.toTypedArray())
    }

    private fun documentValues(id: String): Array<Any?> {
        val isRoot = !id.contains('/')
        val file = if (isRoot) root(id) else resolveFile(id)
        val mime = if (isRoot) Document.MIME_TYPE_DIR else mimeType(file)
        val extension = MimeTypeMap.getSingleton().getExtensionFromMimeType(mime)
        val name = if (isRoot) label(id) else if (file.extension.isEmpty() && extension != null) {
            "${file.name}.$extension"
        } else file.name
        return arrayOf(id, name, mime, 0, if (isRoot) null else file.length(), file.lastModified())
    }

    private val labels get() = context!!.getSharedPreferences("cache_documents", 0)

    private fun label(kind: String): String = labels.getString(kind, null)
        ?: throw FileNotFoundException("Cache labels not initialized")

    private fun mimeType(file: File): String {
        MimeTypeMap.getSingleton().getMimeTypeFromExtension(file.extension.lowercase())?.let { return it }
        return file.inputStream().buffered().use { stream ->
            val header = ByteArray(32)
            stream.mark(header.size)
            val length = stream.read(header)
            stream.reset()
            when {
                length >= 3 && header[0] == 0xff.toByte() && header[1] == 0xd8.toByte() && header[2] == 0xff.toByte() -> "image/jpeg"
                length >= 12 && String(header, 4, 4, Charsets.US_ASCII) == "ftyp" -> {
                    when (String(header, 8, 4, Charsets.US_ASCII)) {
                        "avif", "avis" -> "image/avif"
                        "heic", "heix", "mif1" -> "image/heif"
                        "qt  " -> "video/quicktime"
                        else -> "video/mp4"
                    }
                }
                length >= 4 && header.take(4) == listOf(0x1a.toByte(), 0x45.toByte(), 0xdf.toByte(), 0xa3.toByte()) -> "video/webm"
                length >= 12 && String(header, 8, 4, Charsets.US_ASCII) == "WEBP" -> "image/webp"
                else -> URLConnection.guessContentTypeFromStream(stream) ?: "application/octet-stream"
            }
        }
    }

    companion object {
        private val CACHE_FILENAME = Regex("[a-fA-F0-9]{32}([a-fA-F0-9]{32})?")
        private val ROOT_COLUMNS = arrayOf(Root.COLUMN_ROOT_ID, Root.COLUMN_DOCUMENT_ID,
            Root.COLUMN_TITLE, Root.COLUMN_SUMMARY, Root.COLUMN_ICON, Root.COLUMN_FLAGS, Root.COLUMN_MIME_TYPES)
        private val DOCUMENT_COLUMNS = arrayOf(Document.COLUMN_DOCUMENT_ID, Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_MIME_TYPE, Document.COLUMN_FLAGS, Document.COLUMN_SIZE, Document.COLUMN_LAST_MODIFIED)
    }
}
