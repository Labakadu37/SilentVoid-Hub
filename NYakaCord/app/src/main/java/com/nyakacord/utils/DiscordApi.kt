package com.nyakacord.utils

import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

object DiscordApi {

    private const val BASE_URL = "https://discord.com/api/v10"
    private var token: String? = null

    fun setToken(token: String) {
        this.token = token
    }

    fun get(endpoint: String): JSONObject? {
        return request("GET", endpoint)
    }

    fun post(endpoint: String, body: JSONObject? = null): JSONObject? {
        return request("POST", endpoint, body)
    }

    fun patch(endpoint: String, body: JSONObject): JSONObject? {
        return request("PATCH", endpoint, body)
    }

    private fun request(method: String, endpoint: String, body: JSONObject? = null): JSONObject? {
        val token = this.token ?: return null

        return try {
            val url = URL("$BASE_URL$endpoint")
            val connection = url.openConnection() as HttpURLConnection
            connection.requestMethod = method
            connection.setRequestProperty("Authorization", token)
            connection.setRequestProperty("Content-Type", "application/json")
            connection.setRequestProperty("User-Agent", "NYakaCord/1.0.0")

            if (body != null && method != "GET") {
                connection.doOutput = true
                connection.outputStream.write(body.toString().toByteArray())
            }

            val reader = BufferedReader(InputStreamReader(connection.inputStream))
            val response = reader.readText()
            reader.close()

            JSONObject(response)
        } catch (e: Exception) {
            Logger.e("API request failed: $method $endpoint", e)
            null
        }
    }
}
