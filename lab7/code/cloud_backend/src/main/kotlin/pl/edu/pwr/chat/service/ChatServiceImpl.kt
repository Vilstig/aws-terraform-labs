package pl.edu.pwr.chat.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import pl.edu.pwr.chat.dto.MessageRequestTO
import pl.edu.pwr.chat.dto.MessageTO
import pl.edu.pwr.chat.dto.MessagesListTO
import software.amazon.awssdk.services.dynamodb.DynamoDbClient
import software.amazon.awssdk.services.dynamodb.model.AttributeValue
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest
import software.amazon.awssdk.services.dynamodb.model.QueryRequest
import java.time.LocalDateTime
import java.util.UUID

private const val ROOM_ID = "live"

@Service
class ChatServiceImpl(
    private val dynamoDbClient: DynamoDbClient,
    private val s3Service: S3Service,
    @Value("\${aws.dynamodb.live-chat-table-name}") private val tableName: String
) : ChatService {

    private fun itemToTO(item: Map<String, AttributeValue>): MessageTO {
        val imageKey = item["imageKey"]?.s()
        return MessageTO(
            username = item["username"]?.s() ?: "",
            message = item["message"]?.s() ?: "",
            timestamp = LocalDateTime.parse(item["sortKey"]!!.s().substringBefore("#")),
            imageKey = imageKey,
            imageUrl = imageKey?.let { s3Service.generateDownloadUrl(it) }
        )
    }

    override fun getAllEvents(username: String): MessagesListTO {
        val response = dynamoDbClient.query(
            QueryRequest.builder()
                .tableName(tableName)
                .keyConditionExpression("roomId = :room")
                .expressionAttributeValues(mapOf(
                    ":room" to AttributeValue.fromS(ROOM_ID)
                ))
                .build()
        )
        return MessagesListTO(messages = response.items().map { itemToTO(it) })
    }

    override fun getNewMessages(username: String, after: LocalDateTime): MessagesListTO {
        val response = dynamoDbClient.query(
            QueryRequest.builder()
                .tableName(tableName)
                .keyConditionExpression("roomId = :room AND sortKey > :after")
                .expressionAttributeValues(mapOf(
                    ":room" to AttributeValue.fromS(ROOM_ID),
                    ":after" to AttributeValue.fromS(after.toString())
                ))
                .build()
        )
        return MessagesListTO(messages = response.items().map { itemToTO(it) })
    }

    override fun createLiveEvent(messageDTO: MessageRequestTO) {
        val now = LocalDateTime.now()
        val sortKey = "${now}#${UUID.randomUUID()}"

        val item = mutableMapOf(
            "roomId" to AttributeValue.fromS(ROOM_ID),
            "sortKey" to AttributeValue.fromS(sortKey),
            "username" to AttributeValue.fromS(messageDTO.username),
            "message" to AttributeValue.fromS(messageDTO.message)
        )
        if (messageDTO.imageKey != null) {
            item["imageKey"] = AttributeValue.fromS(messageDTO.imageKey)
        }

        dynamoDbClient.putItem(
            PutItemRequest.builder()
                .tableName(tableName)
                .item(item)
                .build()
        )
    }
}
