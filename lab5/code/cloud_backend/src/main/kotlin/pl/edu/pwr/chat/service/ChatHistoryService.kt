package pl.edu.pwr.chat.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import pl.edu.pwr.chat.dto.MessageTO
import pl.edu.pwr.chat.model.ChatMessage
import software.amazon.awssdk.services.dynamodb.DynamoDbClient
import software.amazon.awssdk.services.dynamodb.model.*
import java.time.LocalDateTime
import java.util.*

@Service
class ChatHistoryService(
    private val dynamoDbClient: DynamoDbClient,
    private val s3Service: S3Service,
    @Value("\${aws.dynamodb.table-name}") private val tableName: String
) {

    fun saveHistory(messages: List<ChatMessage>): String {
        val chatId = UUID.randomUUID().toString()

        messages.forEach { msg ->
            val sortKey = "${msg.timestamp}#${UUID.randomUUID()}"
            val item = mutableMapOf(
                "chatId" to AttributeValue.fromS(chatId),
                "timestamp" to AttributeValue.fromS(sortKey),
                "username" to AttributeValue.fromS(msg.username),
                "message" to AttributeValue.fromS(msg.message)
            )
            if (msg.imageKey != null) {
                item["imageKey"] = AttributeValue.fromS(msg.imageKey!!)
            }

            dynamoDbClient.putItem(
                PutItemRequest.builder()
                    .tableName(tableName)
                    .item(item)
                    .build()
            )
        }

        return chatId
    }

    fun loadHistory(chatId: String): List<MessageTO> {
        val response = dynamoDbClient.query(
            QueryRequest.builder()
                .tableName(tableName)
                .keyConditionExpression("chatId = :cid")
                .expressionAttributeValues(mapOf(":cid" to AttributeValue.fromS(chatId)))
                .build()
        )

        return response.items().map { item ->
            val imageKey = item["imageKey"]?.s()
            MessageTO(
                username = item["username"]?.s() ?: "",
                message = item["message"]?.s() ?: "",
                timestamp = LocalDateTime.parse(item["timestamp"]!!.s().substringBefore("#")),
                imageKey = imageKey,
                imageUrl = imageKey?.let { s3Service.generateDownloadUrl(it) }
            )
        }
    }
}
