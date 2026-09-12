package com.nyakacord.core

import android.util.Log
import com.nyakacord.plugins.BuiltInPlugins
import org.json.JSONObject

object GatewayInterceptor {

    private val messageCache = mutableMapOf<String, CachedMessage>()

    data class CachedMessage(
        val id: String,
        val channelId: String,
        val authorId: String,
        val authorName: String,
        val content: String,
        val attachments: List<String>
    )

    fun interceptGatewayEvent(eventName: String, data: JSONObject) {
        when (eventName) {
            "MESSAGE_CREATE" -> handleMessageCreate(data)
            "MESSAGE_DELETE" -> handleMessageDelete(data)
            "MESSAGE_UPDATE" -> handleMessageUpdate(data)
        }
    }

    private fun handleMessageCreate(data: JSONObject) {
        val id = data.optString("id") ?: return
        val channelId = data.optString("channel_id", "")
        val author = data.optJSONObject("author")
        val attachmentArray = data.optJSONArray("attachments")

        val attachments = mutableListOf<String>()
        if (attachmentArray != null) {
            for (i in 0 until attachmentArray.length()) {
                attachmentArray.optJSONObject(i)?.optString("url")?.let { attachments.add(it) }
            }
        }

        messageCache[id] = CachedMessage(
            id = id,
            channelId = channelId,
            authorId = author?.optString("id", "") ?: "",
            authorName = author?.optString("username", "Unknown") ?: "Unknown",
            content = data.optString("content", ""),
            attachments = attachments
        )

        if (messageCache.size > 5000) {
            val oldest = messageCache.keys.take(1000)
            oldest.forEach { messageCache.remove(it) }
        }
    }

    private fun handleMessageDelete(data: JSONObject) {
        val messageId = data.optString("id") ?: return
        val channelId = data.optString("channel_id", "")
        val cached = messageCache[messageId]

        val pluginManager = NYakaCordApp.instance.pluginManager
        val logger = pluginManager.getPlugin("message_logger") as? BuiltInPlugins.MessageLogger
        logger?.onMessageDelete(
            messageId = messageId,
            channelId = channelId,
            cachedContent = cached?.content,
            authorId = cached?.authorId,
            authorName = cached?.authorName,
            attachments = cached?.attachments
        )

        Log.d(NYakaCordApp.TAG, "MESSAGE_DELETE intercepted: $messageId")
    }

    private fun handleMessageUpdate(data: JSONObject) {
        val messageId = data.optString("id") ?: return
        val channelId = data.optString("channel_id", "")
        val newContent = data.optString("content", "")
        val cached = messageCache[messageId]

        if (cached != null && cached.content != newContent) {
            val pluginManager = NYakaCordApp.instance.pluginManager
            val logger = pluginManager.getPlugin("message_logger") as? BuiltInPlugins.MessageLogger
            logger?.onMessageUpdate(
                messageId = messageId,
                channelId = channelId,
                oldContent = cached.content,
                newContent = newContent
            )

            messageCache[messageId] = cached.copy(content = newContent)
        }

        Log.d(NYakaCordApp.TAG, "MESSAGE_UPDATE intercepted: $messageId")
    }
}
