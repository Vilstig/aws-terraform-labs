package pl.edu.pwr.chat.dto

import java.time.LocalDateTime

data class MessageTO(
    val username: String,
    val message: String,
    val timestamp: LocalDateTime,
    val imageKey: String? = null,
    val imageUrl: String? = null
)
