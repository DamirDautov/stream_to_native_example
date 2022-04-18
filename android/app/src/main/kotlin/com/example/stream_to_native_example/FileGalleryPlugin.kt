package com.example.stream_to_native_example

import android.annotation.SuppressLint
import android.content.ContentValues
import android.content.Context
import android.provider.MediaStore
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class FileGalleryPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
  private var channel: MethodChannel? = null
  private lateinit var context: Context

  companion object {
    private const val sChannelName = "com.example.stream_to_native_example/gallery_saver"
    private const val appName = "Folder name"
  }

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(binding.binaryMessenger, sChannelName)
    context = binding.applicationContext
    channel!!.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setMethodCallHandler(null)
    channel = null
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "saveBytesToFile" -> {
        val bytes = call.argument<ByteArray>("bytes")
        val fileName = call.argument<String>("fileName")
        if (bytes != null && fileName != null) {
          save(result, fileName, bytes)
        }
      }
      else -> result.notImplemented()
    }
  }

  @SuppressLint("NewApi")
  private fun save(
    result: Result,
    fileName: String,
    bytes: ByteArray
  ) {
    val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI

    val relativePath: String = listOf("Download", appName).joinToString("/")
    val name = listOf(relativePath, fileName).joinToString("/")

    val values = ContentValues().apply {
      put(MediaStore.Downloads.DISPLAY_NAME, name)
      put(MediaStore.Downloads.RELATIVE_PATH, relativePath)
      put(MediaStore.Downloads.IS_PENDING, 1)
    }

    val resolver = context.contentResolver
    val uri = resolver.insert(collection, values)

    uri?.let {
      resolver.openOutputStream(uri)?.use { outputStream ->
        outputStream.write(bytes)
      }

      values.clear()
      values.put(MediaStore.Downloads.IS_PENDING, 0)
      resolver.update(uri, values, null, null)
      result.success("")
    }
      ?: result.error(
        "MediaStore failed for some reason",
        "MediaStore failed for some reason",
        null
      )
  }
}
