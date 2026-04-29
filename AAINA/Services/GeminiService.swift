//
//  GeminiService.swift
//  AAINA
//

import Foundation

enum GeminiService {

    // MARK: - Configuration
    static var apiKey: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key  = dict["GeminiAPIKey"] as? String, !key.isEmpty
        else { return "" }
        return key
    }()

    private static let model = "gemini-2.0-flash"

    // MARK: - Routine suggestion context

    struct RoutineContext {
        var skinCondition: String
        var concerns: [String]
        var stepsToChange: [String]         // one or more selected steps
        var routineTarget: String           // "morning", "evening", "both"
        var action: String                  // "change" or "remove"
        var reason: String
        var weeksSinceRoutineStart: Int
    }

    static func getRoutineSuggestion(
        context: RoutineContext,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard !apiKey.isEmpty else {
            completion(.failure(ServiceError.noAPIKey)); return
        }

        let skin     = context.skinCondition.isEmpty ? "combination" : context.skinCondition
        let concerns = context.concerns.isEmpty ? "general skin health" : context.concerns.joined(separator: ", ")
        let steps    = context.stepsToChange.joined(separator: ", ")
        let target   = context.routineTarget.capitalized  // Morning / Evening / Both
        let tooSoon  = context.weeksSinceRoutineStart < 4

        let prompt: String

        if tooSoon {
            prompt = """
            You are AAINA, a warm and knowledgeable skincare advisor for women. A user with \(skin) skin and concerns of \(concerns) wants to \(context.action) her \(target) routine step(s) — \(steps) — after only \(context.weeksSinceRoutineStart) week(s). Her reason: "\(context.reason)".

            Your response must:
            1. Start with one warm, validating sentence acknowledging her concern.
            2. Gently explain that skin typically needs 4–6 weeks to show results from a new product or routine change.
            3. Give ONE concrete, actionable tip she can try RIGHT NOW to ease the issue with \(steps) specifically — tailored to her reason and skin type.
            4. End with a short encouraging note that her skin's story is still unfolding.
            Keep it under 130 words. Warm, flowing paragraphs. Address her as "you". No bullet points.
            """
        } else if context.action == "remove" {
            prompt = """
            You are AAINA, a warm and knowledgeable skincare advisor for women.
            User: \(skin) skin, concerns: \(concerns).
            She wants to REMOVE the following step(s) from her \(target) routine after \(context.weeksSinceRoutineStart) week(s): \(steps).
            Her reason: "\(context.reason)".

            Reply in this exact format:
            One warm, understanding opening sentence.

            For each step she is removing, use a bold **Step Name** header followed by:
            — Whether removing it is beneficial for her specific skin type and reason (1 sentence).
            — One thing to keep an eye on without that step (1 sentence).

            Then show her simplified \(target) routine with those steps removed (list remaining steps in the correct skincare order, numbered).

            Close with one short encouraging sentence.
            Max 220 words. Warm, professional tone. Address her as "you".
            """
        } else {
            // action == "change"
            prompt = """
            You are AAINA, a warm and knowledgeable skincare advisor for women.
            User: \(skin) skin, concerns: \(concerns).
            She wants to CHANGE the following step(s) in her \(target) routine after \(context.weeksSinceRoutineStart) week(s): \(steps).
            Her reason: "\(context.reason)".

            Reply in this exact format:
            One warm, validating opening sentence (max 12 words).

            For each step she wants to change, use a bold **Step Name** header followed by:
            — ONE specific ingredient or product TYPE (no brand names) that suits her skin + concerns, with a 2-sentence explanation of why.
            — How to introduce it: frequency and any layering tip (1 sentence).

            Close with a brief patch-test reminder (1 sentence).
            Max 220 words. Warm, confident, flowing tone. Address her as "you". No sub-bullets.
            """
        }

        call(prompt: prompt, completion: completion)
    }

    // MARK: - Raw call

    private static func call(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(ServiceError.badURL)); return
        }

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": ["temperature": 0.72, "maxOutputTokens": 350]
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        req.timeoutInterval = 20

        URLSession.shared.dataTask(with: req) { data, _, error in
            DispatchQueue.main.async {
                if let error { completion(.failure(error)); return }
                guard let data,
                      let json       = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let candidates = json["candidates"] as? [[String: Any]],
                      let content    = candidates.first?["content"] as? [String: Any],
                      let parts      = content["parts"] as? [[String: Any]],
                      let text       = parts.first?["text"] as? String
                else { completion(.failure(ServiceError.badResponse)); return }
                completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
            }
        }.resume()
    }

    // MARK: - Errors

    enum ServiceError: LocalizedError {
        case noAPIKey, badURL, badResponse
        var errorDescription: String? {
            switch self {
            case .noAPIKey:    return "API key not configured. Add GeminiAPIKey to Config.plist."
            case .badURL:      return "Invalid API URL."
            case .badResponse: return "Couldn't read the response. Please try again."
            }
        }
    }
}
