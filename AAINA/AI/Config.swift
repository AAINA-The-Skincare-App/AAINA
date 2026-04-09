// Config.swift — Add this file to .gitignore
// Create a Config.example.swift with empty apiKey for teammates

enum Config {
    static let geminiAPIKey = "AIzaSyC7nIL5GArP1tCGZeNK2EMVHTUSJAxGS9k" // ⚠️Get a new key from Google AI Studio and paste it here (do NOT commit it)
    static let geminiEndpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
}
