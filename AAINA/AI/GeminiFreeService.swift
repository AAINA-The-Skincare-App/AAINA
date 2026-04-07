import Foundation
import UIKit

final class GeminiFreeService {

    func generateRoutine(prompt: String, image: UIImage?) async throws -> FullAnalysisOutput {

        var parts: [[String: Any]] = []

        let optimizedPrompt = """
        Do not include reasoning or explanations.
        Output ONLY valid JSON.

        \(prompt)
        """

        if let image,
           let data = image.jpegData(compressionQuality: 0.5) {
            parts.append([
                "inline_data": [
                    "mime_type": "image/jpeg",
                    "data": data.base64EncodedString()
                ]
            ])
        }

        parts.append(["text": optimizedPrompt])

        let body: [String: Any] = [
            "contents": [["parts": parts]],
            "generationConfig": [
                "temperature": 0.2,
                "maxOutputTokens": 4096,
                "responseMimeType": "application/json",
                "thinkingConfig": [
                    "thinkingBudget": 0
                ]
            ]
        ]

        guard let url = URL(string: "\(Config.geminiEndpoint)?key=\(Config.geminiAPIKey)") else {
            throw NSError(domain: "Gemini", code: -1)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await retryRequest(request)

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let rawResponse = String(data: data, encoding: .utf8) ?? "<unreadable>"
        print("🌐 Gemini HTTP \(statusCode)")
        print("📦 Raw response: \(rawResponse.prefix(1000))")

        if !(200...299).contains(statusCode) {
            print("❌ Gemini error – HTTP \(statusCode): \(rawResponse)")
            throw NSError(domain: "Gemini", code: statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode)"])
        }

        // For thinking models: skip thought parts, find the actual JSON part.
        // content is also absent when the safety filter blocks the request.
        if let success = try? JSONDecoder().decode(GeminiRawResponse.self, from: data),
           let text = success.candidates.first?.content?.parts.first(where: { $0.thought != true })?.text {

            print("✅ Gemini text extracted, decoding FullAnalysisOutput…")
            let cleaned = cleanJSON(text)
            guard let jsonData = cleaned.data(using: .utf8) else {
                throw NSError(domain: "Gemini", code: -2)
            }
            do {
                return try JSONDecoder().decode(FullAnalysisOutput.self, from: jsonData)
            } catch {
                print("❌ FullAnalysisOutput decode failed: \(error)")
                print("📄 Text from Gemini: \(cleaned.prefix(500))")
                throw error
            }
        }

        print("⚠️ Could not extract text from response – candidates: \(rawResponse.prefix(500))")

        // Safety block with image — retry without image so we still get a routine
        if image != nil {
            print("🔄 Retrying without image…")
            return try await generateRoutine(prompt: prompt, image: nil)
        }


        throw NSError(domain: "Gemini", code: -3,
                      userInfo: [NSLocalizedDescriptionKey: "No valid content in response"])
    }

    private func retryRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        for attempt in 1...4 {
            do {
                return try await URLSession.shared.data(for: request)
            } catch {
                if attempt == 4 { throw error }
                try await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
        throw NSError(domain: "Retry", code: -1)
    }

    private func cleanJSON(_ text: String) -> String {
        var cleaned = text
        cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned
    }
}

struct GeminiRawResponse: Codable {
    let candidates: [Candidate]

    struct Candidate: Codable {
        let content: Content?
    }

    struct Content: Codable {
        let parts: [Part]
    }

    struct Part: Codable {
        let text: String?
        let thought: Bool?
    }
}
