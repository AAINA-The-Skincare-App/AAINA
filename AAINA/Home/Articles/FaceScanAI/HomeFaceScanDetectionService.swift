import Foundation
import UIKit

final class HomeFaceScanDetectionService {

    func detectConcerns(image: UIImage) async throws -> FaceScanResult {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "HomeFaceScanDetection", code: -1)
        }

        let prompt = """
        Analyse the face in this image for skincare-visible concerns.
        Return ONLY valid JSON. No markdown. No explanation.

        Focus on visible detection and face position/area:
        - acne, pimples, clogged pores
        - pigmentation, dark spots, uneven tone
        - redness, dryness, oiliness, texture
        - under-eye darkness where visible

        Each concern area must name the position on the face, for example:
        forehead, left cheek, right cheek, chin, nose/T-zone, under-eye area.

        Return this exact JSON object:
        {
          "skinType": "one of: Oily, Dry, Combination, Normal",
          "skinTone": "one of: Fair, Medium, Olive, Deep, Rich",
          "concerns": [
            { "name": "e.g. Acne", "severity": "mild | moderate | notable", "area": "e.g. left cheek" }
          ],
          "summary": "1-2 sentences describing the visible detections and where they appear."
        }

        List up to 6 visible concerns. Base everything only on what is visually observable.
        """

        let body: [String: Any] = [
            "contents": [[
                "parts": [
                    ["inline_data": ["mime_type": "image/jpeg", "data": data.base64EncodedString()]],
                    ["text": prompt]
                ]
            ]],
            "generationConfig": [
                "temperature": 0.15,
                "maxOutputTokens": 900,
                "responseMimeType": "application/json",
                "thinkingConfig": ["thinkingBudget": 0]
            ]
        ]

        guard let url = URL(string: "\(Config.geminiEndpoint)?key=\(Config.geminiAPIKey)") else {
            throw NSError(domain: "HomeFaceScanDetection", code: -2)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (responseData, response) = try await URLSession.shared.data(for: request)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        guard (200...299).contains(statusCode) else {
            throw NSError(domain: "HomeFaceScanDetection", code: statusCode)
        }

        if let raw = try? JSONDecoder().decode(GeminiRawResponse.self, from: responseData),
           let text = raw.candidates.first?.content?.parts.first(where: { $0.thought != true })?.text {
            let cleaned = cleanJSON(text)
            guard let jsonData = cleaned.data(using: .utf8) else {
                throw NSError(domain: "HomeFaceScanDetection", code: -3)
            }
            return try JSONDecoder().decode(FaceScanResult.self, from: jsonData)
        }

        throw NSError(domain: "HomeFaceScanDetection", code: -4)
    }

    private func cleanJSON(_ text: String) -> String {
        text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
