package pl.edu.pwr.chat.service

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.stereotype.Service
import pl.edu.pwr.chat.dto.MessageRequestTO
import pl.edu.pwr.chat.dto.MessageTO
import pl.edu.pwr.chat.dto.MessagesListTO
import pl.edu.pwr.chat.model.ChatMessage
import pl.edu.pwr.chat.repository.ChatMessageRepository
import java.time.LocalDateTime

@Service
class ChatServiceImpl @Autowired constructor(

    private val chatMessageRepository: ChatMessageRepository,
    private val s3Service: S3Service

) : ChatService {

    private fun toTO(msg: ChatMessage): MessageTO = MessageTO(
        username = msg.username,
        message = msg.message,
        timestamp = msg.timestamp,
        imageKey = msg.imageKey,
        imageUrl = msg.imageKey?.let { s3Service.generateDownloadUrl(it) }
    )

    override fun getAllEvents(username: String): MessagesListTO {
        val messages = chatMessageRepository.findAll()
        return MessagesListTO(messages = messages.map { toTO(it) })
    }

    override fun getNewMessages(username: String, after: LocalDateTime): MessagesListTO {
        val messages = chatMessageRepository.findByTimestampAfter(after)
        return MessagesListTO(messages = messages.map { toTO(it) })
    }

    override fun createLiveEvent(messageDTO: MessageRequestTO) {
        val chatMessage = ChatMessage(
            username = messageDTO.username,
            message = messageDTO.message,
            timestamp = LocalDateTime.now(),
            imageKey = messageDTO.imageKey
        )

        chatMessageRepository.save(chatMessage)
    }

}

