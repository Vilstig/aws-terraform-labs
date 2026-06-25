package pl.edu.pwr.chat.model

import java.time.LocalDateTime

data class ChatMessage(
    val roomId: String,
    val sortKey: String,
    val username: String,
    val message: String,
    val timestamp: LocalDateTime,
    val imageKey: String? = null
)
