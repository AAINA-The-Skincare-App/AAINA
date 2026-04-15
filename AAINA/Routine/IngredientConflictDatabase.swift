import UIKit



struct IngredientConflictEntry {
    let nameA: String          // display name for ingredient A
    let nameB: String          // display name for ingredient B
    let severity: Severity
    let recommendation: String

    enum Severity: String {
        case high   = "High"
        case medium = "Medium"
        case low    = "Low"

        var color: UIColor {
            switch self {
            case .high:   return UIColor(red: 210/255, green: 80/255,  blue: 80/255,  alpha: 1)
            case .medium: return UIColor(red: 210/255, green: 140/255, blue: 60/255,  alpha: 1)
            case .low:    return UIColor(red: 130/255, green: 160/255, blue: 100/255, alpha: 1)
            }
        }
    }
}



final class IngredientConflictDatabase {

    static let shared = IngredientConflictDatabase()
    private init() {}

    // Each rule: keywords to match ingredient A, keywords to match ingredient B, severity, recommendation
    private typealias Rule = (keysA: [String], keysB: [String], severity: IngredientConflictEntry.Severity, rec: String)

    private let rules: [Rule] = [
        (["vitamin c", "ascorbic acid"],
         ["niacinamide"],
         .medium, "Use in separate routines (AM/PM) or 30 min apart"),

        (["vitamin c", "ascorbic acid"],
         ["glycolic acid", "salicylic acid", "lactic acid", "aha", "bha"],
         .medium, "Alternate days; do not layer in the same routine"),

        (["vitamin c", "ascorbic acid"],
         ["benzoyl peroxide"],
         .high, "Never combine; use BPO in the AM and Vitamin C in the PM"),

        (["retinol", "retinoid", "tretinoin"],
         ["glycolic acid", "lactic acid", "aha"],
         .high, "Never layer; alternate nights; always use SPF the next morning"),

        (["retinol", "retinoid", "tretinoin"],
         ["salicylic acid", "bha"],
         .high, "Use on separate nights; hydrate between uses"),

        (["retinol", "retinoid", "tretinoin"],
         ["benzoyl peroxide"],
         .high, "Never combine; use BPO in the AM, retinol in the PM"),

        (["retinol", "retinoid", "tretinoin"],
         ["vitamin c", "ascorbic acid"],
         .medium, "Separate AM (Vitamin C) and PM (Retinol) routines"),

        (["retinol", "retinoid", "tretinoin"],
         ["lactic acid"],
         .medium, "Never apply in the same step; consider alternating nights"),

        (["retinol", "retinoid", "tretinoin"],
         ["azelaic acid"],
         .low, "Introduce gradually; patch test; consider alternating"),

        (["retinol", "retinoid", "tretinoin"],
         ["vitamin e", "tocopherol"],
         .low, "Low concentrations together are generally fine"),

        (["retinol", "retinoid", "tretinoin"],
         ["salicylic acid"],
         .high, "Strict alternation; not same session"),

        (["glycolic acid", "lactic acid"],
         ["salicylic acid"],
         .medium, "Alternate use; avoid same-day application on sensitive skin"),

        (["glycolic acid"],
         ["vitamin c", "ascorbic acid"],
         .medium, "Use at different times of day; SPF essential if used in the AM"),

        (["glycolic acid"],
         ["mandelic acid"],
         .medium, "Choose one AHA per routine; alternate days if needed"),

        (["benzoyl peroxide"],
         ["hydroquinone"],
         .high, "Never combine; use at separate times"),

        (["niacinamide"],
         ["glycolic acid", "salicylic acid", "lactic acid", "direct acid"],
         .low, "Apply niacinamide after pH normalises (15–30 min gap)"),

        (["niacinamide"],
         ["copper peptide"],
         .medium, "Allow a 30-minute gap between application steps"),

        (["peptide"],
         ["glycolic acid", "lactic acid", "salicylic acid", "aha", "bha"],
         .medium, "Apply peptides after the acid step has cleared; or use separately"),

        (["peptide"],
         ["vitamin c", "ascorbic acid"],
         .low, "Use Vitamin C first, allow 20 min, then apply peptide serum"),

        (["copper peptide"],
         ["vitamin c", "ascorbic acid"],
         .high, "Never use in the same routine; AM/PM split required"),

        (["copper peptide"],
         ["glycolic acid", "lactic acid", "salicylic acid", "aha", "bha"],
         .high, "Use on strictly alternating days"),

        (["kojic acid"],
         ["vitamin c", "ascorbic acid"],
         .low, "Use separately; store in opaque containers"),

        (["bakuchiol"],
         ["glycolic acid", "lactic acid", "salicylic acid", "aha", "bha"],
         .low, "Use acids first, let skin rest, then bakuchiol; or AM/PM split"),
    ]

    // MARK: - Public API

    /// For a given ingredient, returns all ingredients it should avoid — with severity + recommendation.
    func avoids(for ingredient: String) -> [(other: String, severity: IngredientConflictEntry.Severity, recommendation: String)] {
        let name = ingredient.lowercased()
        var results: [(other: String, severity: IngredientConflictEntry.Severity, recommendation: String)] = []

        for rule in rules {
            let matchesA = rule.keysA.contains(where: { name.contains($0) })
            let matchesB = rule.keysB.contains(where: { name.contains($0) })

            if matchesA {
                // ingredient is side A — list what it conflicts with (side B)
                let displayB = canonicalName(for: rule.keysB)
                results.append((displayB, rule.severity, rule.rec))
            } else if matchesB {
                // ingredient is side B — list what it conflicts with (side A)
                let displayA = canonicalName(for: rule.keysA)
                results.append((displayA, rule.severity, rule.rec))
            }
        }

        // Deduplicate by "other" name
        var seen = Set<String>()
        return results.filter { seen.insert($0.other).inserted }
    }

   

    /// Picks a human-readable name from a keyword list.
    private func canonicalName(for keys: [String]) -> String {
        let map: [String: String] = [
            "vitamin c":       "Vitamin C",
            "ascorbic acid":   "Vitamin C",
            "retinol":         "Retinol / Retinoids",
            "retinoid":        "Retinol / Retinoids",
            "tretinoin":       "Tretinoin",
            "niacinamide":     "Niacinamide",
            "glycolic acid":   "Glycolic Acid (AHA)",
            "lactic acid":     "Lactic Acid (AHA)",
            "aha":             "AHA (Glycolic/Lactic Acid)",
            "salicylic acid":  "Salicylic Acid (BHA)",
            "bha":             "BHA (Salicylic Acid)",
            "benzoyl peroxide":"Benzoyl Peroxide",
            "hydroquinone":    "Hydroquinone",
            "copper peptide":  "Copper Peptides",
            "peptide":         "Peptides",
            "hyaluronic acid": "Hyaluronic Acid",
            "direct acid":     "Strong Direct Acids",
            "kojic acid":      "Kojic Acid",
            "azelaic acid":    "Azelaic Acid",
            "bakuchiol":       "Bakuchiol",
            "mandelic acid":   "Mandelic Acid",
            "vitamin e":       "Vitamin E",
            "tocopherol":      "Vitamin E (Tocopherol)",
        ]
        for key in keys {
            if let display = map[key] { return display }
        }
        return keys.first?.capitalized ?? "Unknown"
    }
}
