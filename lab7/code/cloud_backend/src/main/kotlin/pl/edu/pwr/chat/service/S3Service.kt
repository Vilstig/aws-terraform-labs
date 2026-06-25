package pl.edu.pwr.chat.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import software.amazon.awssdk.services.s3.model.GetObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import software.amazon.awssdk.services.s3.presigner.S3Presigner
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest
import java.time.Duration
import java.util.*

@Service
class S3Service(
    private val s3Presigner: S3Presigner,
    @Value("\${aws.s3.bucket-name}") private val bucketName: String
) {

    fun generateUploadUrl(filename: String): Pair<String, String> {
        val extension = filename.substringAfterLast('.', "")
        val key = "images/${UUID.randomUUID()}.$extension"

        val putRequest = PutObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build()

        val presignRequest = PutObjectPresignRequest.builder()
            .signatureDuration(Duration.ofMinutes(15))
            .putObjectRequest(putRequest)
            .build()

        val presignedUrl = s3Presigner.presignPutObject(presignRequest).url().toString()
        return Pair(presignedUrl, key)
    }

    fun generateDownloadUrl(key: String): String {
        val getRequest = GetObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build()

        val presignRequest = GetObjectPresignRequest.builder()
            .signatureDuration(Duration.ofHours(1))
            .getObjectRequest(getRequest)
            .build()

        return s3Presigner.presignGetObject(presignRequest).url().toString()
    }
}
