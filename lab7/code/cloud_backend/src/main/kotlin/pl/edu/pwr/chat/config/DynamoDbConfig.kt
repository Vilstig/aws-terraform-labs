package pl.edu.pwr.chat.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.dynamodb.DynamoDbClient

@Configuration
class DynamoDbConfig(
    @Value("\${aws.region}") private val region: String
) {
    @Bean
    fun dynamoDbClient(): DynamoDbClient =
        DynamoDbClient.builder()
            .region(Region.of(region))
            .build()
}
