import Foundation

struct RoutinePromptBuilder {

    static func build(
        onboardingData: OnboardingData,
        ingredients: [Ingredient],
        imageProvided: Bool
    ) -> String {

        let tZone = onboardingData.tZone?.rawValue ?? "normal"
        let uZone = onboardingData.uZone?.rawValue ?? "normal"
        let cZone = onboardingData.cZone?.rawValue ?? "normal"

        let zones = [tZone, uZone, cZone]
        let counts = Dictionary(grouping: zones, by: { $0 }).mapValues { $0.count }
        let skinType = counts.max(by: { $0.value < $1.value })?.key ?? "normal"

        let sensitivity = onboardingData.sensitivity?.rawValue ?? "sometimes"
        let uvExposure = onboardingData.uvExposure?.rawValue ?? "moderate"

        let ingredientText = ingredients.prefix(8).map {
            let uses = $0.uses?.joined(separator: ",") ?? ""
            let safe = $0.safeForSensitive.map { String($0) } ?? "unknown"
            return "\($0.name) | uses:\(uses) | safe:\(safe)"
        }.joined(separator: "\n")

        let goalText = onboardingData.goals.map { "- \($0.rawValue)" }.joined(separator: "\n")

        return """
        You are a skincare AI. Return ONLY a valid JSON object — no markdown, no explanation.

        USER
        Skin: \(skinType) | T-Zone: \(tZone) | U-Zone: \(uZone) | Chin: \(cZone)
        Sensitivity: \(sensitivity) | UV: \(uvExposure)
        Goals: \(goalText.isEmpty ? "general skincare" : goalText)
        \(imageProvided ? "Face image attached — factor in visible skin concerns." : "No image — use user profile only.")

        CONFLICTS (never put both in the same routine)
        retinol + benzoyl peroxide | retinol + glycolic acid | retinol + salicylic acid
        retinol + vitamin C | vitamin C + glycolic acid | vitamin C + salicylic acid
        vitamin C + benzoyl peroxide | benzoyl peroxide + salicylic acid
        niacinamide + vitamin C | glycolic acid + salicylic acid

        RULES
        - Vitamin C → AM only | Retinol → PM only | SPF → AM last step only
        - AHA/BHA → one routine only, never both
        - High sensitivity → prefer Centella, Ceramides, Panthenol, Allantoin
        - High UV → SPF 50+ mandatory in AM

        INGREDIENTS (choose from these)
        \(ingredientText)

        OUTPUT exactly 5 AM steps and 5 PM steps.
        AM order — productType: cleanser → toner → serum → moisturizer → sunscreen
        PM order — productType: cleanser → toner → treatment → moisturizer → repair
        All productType values must be lowercase exactly as shown above.
        "reason" and "usage" must each be 2-3 sentences max.

        Return this exact JSON structure, nothing else:
        {
          "morning": [
            { "id": "uuid-string", "stepNumber": 1, "productType": "cleanser", "productName": "", "keyIngredients": [], "reason": "", "usage": "", "isUserAdded": false }
          ],
          "evening": [
            { "id": "uuid-string", "stepNumber": 1, "productType": "cleanser", "productName": "", "keyIngredients": [], "reason": "", "usage": "", "isUserAdded": false }
          ]
        }
        """
    }
}
