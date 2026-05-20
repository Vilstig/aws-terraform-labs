package pl.edu.pwr.chat.controller

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.format.annotation.DateTimeFormat
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
import pl.edu.pwr.chat.dto.*
import pl.edu.pwr.chat.service.ChatHistoryService
import pl.edu.pwr.chat.service.ChatService
import pl.edu.pwr.chat.service.S3Service
import pl.edu.pwr.chat.repository.ChatMessageRepository
import java.time.LocalDateTime


@RestController
@RequestMapping("chat")
class ChatController @Autowired constructor(
    private val chatService: ChatService,
    private val s3Service: S3Service,
    private val chatHistoryService: ChatHistoryService,
    private val chatMessageRepository: ChatMessageRepository
) {

    @GetMapping("all")
    fun getAllMessages(@RequestParam username: String): ResponseEntity<Any> {
        val resultTO: MessagesListTO = chatService.getAllEvents(username)
        return ResponseEntity.ok(resultTO)
    }

    @GetMapping
    fun getNewMessages(
        @RequestParam username: String,
        @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) after: LocalDateTime
    ): ResponseEntity<Any> {
        val resultTO: MessagesListTO = chatService.getNewMessages(username, after)
        return ResponseEntity.ok(resultTO)
    }

    @PostMapping
    fun createLiveEvent(@RequestBody messageDTO: MessageRequestTO): ResponseEntity<Any> {
        chatService.createLiveEvent(messageDTO)
        return ResponseEntity.ok().build()
    }

    @PostMapping("upload-url")
    fun getUploadUrl(@RequestBody request: UploadUrlRequestTO): ResponseEntity<UploadUrlResponseTO> {
        val (url, key) = s3Service.generateUploadUrl(request.filename)
        return ResponseEntity.ok(UploadUrlResponseTO(uploadUrl = url, key = key))
    }

    @PostMapping("history/save")
    fun saveHistory(): ResponseEntity<SaveHistoryResponseTO> {
        val allMessages = chatMessageRepository.findAll()
        val chatId = chatHistoryService.saveHistory(allMessages)
        return ResponseEntity.ok(SaveHistoryResponseTO(chatId = chatId))
    }

    @GetMapping("history/{chatId}")
    fun loadHistory(@PathVariable chatId: String): ResponseEntity<MessagesListTO> {
        val messages = chatHistoryService.loadHistory(chatId)
        return ResponseEntity.ok(MessagesListTO(messages = messages))
    }
}
