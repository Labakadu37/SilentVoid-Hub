package com.nyakacord.plugins

import android.content.Context
import android.util.Log
import com.nyakacord.core.NYakaCordApp

object BuiltInPlugins {

    class MessageLogger : Plugin() {
        override val id = "message_logger"
        override val name = "Message Logger"
        override val description = "Logs deleted and edited messages so you can still see them"
        override val version = "1.0.0"
        override val author = "NYakaCord"

        private val deletedMessages = mutableMapOf<String, DeletedMessage>()
        private val editHistory = mutableMapOf<String, MutableList<EditedMessage>>()

        data class DeletedMessage(
            val messageId: String,
            val channelId: String,
            val authorId: String,
            val authorName: String,
            val content: String,
            val timestamp: Long,
            val deletedAt: Long = System.currentTimeMillis(),
            val attachments: List<String> = emptyList()
        )

        data class EditedMessage(
            val messageId: String,
            val channelId: String,
            val oldContent: String,
            val newContent: String,
            val editedAt: Long = System.currentTimeMillis()
        )

        override fun onLoad(context: Context) {
            Log.i(NYakaCordApp.TAG, "MessageLogger loaded - intercepting gateway events")
        }

        override fun onUnload() {
            deletedMessages.clear()
            editHistory.clear()
            Log.i(NYakaCordApp.TAG, "MessageLogger unloaded")
        }

        fun onMessageDelete(messageId: String, channelId: String, cachedContent: String?,
                            authorId: String?, authorName: String?, attachments: List<String>?) {
            if (!isLoaded) return

            val deleted = DeletedMessage(
                messageId = messageId,
                channelId = channelId,
                authorId = authorId ?: "unknown",
                authorName = authorName ?: "Unknown User",
                content = cachedContent ?: "[Content not cached]",
                timestamp = System.currentTimeMillis(),
                attachments = attachments ?: emptyList()
            )
            deletedMessages[messageId] = deleted
            Log.d(NYakaCordApp.TAG, "MessageLogger: captured deleted message $messageId in #$channelId")
        }

        fun onMessageUpdate(messageId: String, channelId: String, oldContent: String, newContent: String) {
            if (!isLoaded) return
            if (oldContent == newContent) return

            val edit = EditedMessage(
                messageId = messageId,
                channelId = channelId,
                oldContent = oldContent,
                newContent = newContent
            )
            editHistory.getOrPut(messageId) { mutableListOf() }.add(edit)
            Log.d(NYakaCordApp.TAG, "MessageLogger: captured edit for message $messageId")
        }

        fun getDeletedMessages(channelId: String): List<DeletedMessage> {
            return deletedMessages.values
                .filter { it.channelId == channelId }
                .sortedByDescending { it.deletedAt }
        }

        fun getEditHistory(messageId: String): List<EditedMessage> {
            return editHistory[messageId] ?: emptyList()
        }

        fun getAllDeletedMessages(): Map<String, DeletedMessage> = deletedMessages.toMap()

        fun clearLogs() {
            deletedMessages.clear()
            editHistory.clear()
        }

        fun clearLogsForChannel(channelId: String) {
            deletedMessages.entries.removeAll { it.value.channelId == channelId }
            editHistory.entries.removeAll { entry ->
                deletedMessages.none { it.value.messageId == entry.key }
            }
        }
    }

    class AlwaysOnline : Plugin() {
        override val id = "always_online"
        override val name = "Always Online"
        override val description = "Keeps your status as online even when the app is in background"
        override val version = "1.0.0"
        override val author = "NYakaCord"

        override fun onLoad(context: Context) {
            Log.i(NYakaCordApp.TAG, "AlwaysOnline loaded")
        }

        override fun onUnload() {
            Log.i(NYakaCordApp.TAG, "AlwaysOnline unloaded")
        }
    }

    class BetterMedia : Plugin() {
        override val id = "better_media"
        override val name = "Better Media"
        override val description = "Enhanced media viewer with download support and zoom"
        override val version = "1.0.0"
        override val author = "NYakaCord"

        override fun onLoad(context: Context) {
            Log.i(NYakaCordApp.TAG, "BetterMedia loaded")
        }

        override fun onUnload() {
            Log.i(NYakaCordApp.TAG, "BetterMedia unloaded")
        }
    }
}
