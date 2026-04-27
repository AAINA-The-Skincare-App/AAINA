//
//  model.swift
//  ScanCard
//
//  Created by GEU on 18/03/26.
//

import Foundation

struct ScanAnalysisResult {
    let isRecommended: Bool
    let title: String
    let detail: String
    let detectedIngredients: [String]
    let matchedIngredients: [String]
    let conflicts: [String]
}

class RoutineManager {
    private let dataModel = DataModel()
    private let weakIngredientTokens: Set<String> = [
        "acid", "extract", "water", "aqua", "oil", "root", "leaf", "fruit",
        "seed", "sodium", "potassium", "tocopherol", "alcohol"
    ]
    
    private let routine: [String: [String]] = [
        "Cleanser": ["glycerin", "niacinamide"],
        "Serum": ["vitamin c", "hyaluronic acid"],
        "Moisturizer": ["ceramide", "peptides"],
        "Sunscreen": ["zinc oxide", "avobenzone"]
    ]
    
    private let conflicts: [[String]] = [
        ["retinol", "aha"],
        ["retinol", "glycolic acid"],
        ["retinol", "lactic acid"],
        ["retinol", "salicylic acid"],
        ["benzoyl peroxide", "retinol"]
    ]

    private let ingredientAliases: [String: [String]] = [
        "aha": ["aha", "alpha hydroxy acid", "glycolic acid", "lactic acid", "mandelic acid"],
        "avobenzone": ["avobenzone", "butyl methoxydibenzoylmethane"],
        "benzoyl peroxide": ["benzoyl peroxide"],
        "ceramide": ["ceramide", "ceramide np", "ceramide ap", "ceramide eop"],
        "glycerin": ["glycerin", "glycerine"],
        "hyaluronic acid": ["hyaluronic acid", "sodium hyaluronate"],
        "lactic acid": ["lactic acid"],
        "glycolic acid": ["glycolic acid"],
        "niacinamide": ["niacinamide", "vitamin b3"],
        "peptides": ["peptide", "peptides", "palmitoyl tripeptide", "palmitoyl tetrapeptide"],
        "retinol": ["retinol", "retinal", "retinaldehyde", "retinyl palmitate", "retinoid"],
        "salicylic acid": ["salicylic acid", "bha", "beta hydroxy acid"],
        "vitamin c": ["vitamin c", "ascorbic acid", "ethyl ascorbic acid", "3 o ethyl ascorbic acid", "3-o-ethyl ascorbic acid", "ascorbyl glucoside", "sodium ascorbyl phosphate"],
        "zinc oxide": ["zinc oxide"]
    ]

    private lazy var mergedIngredientAliases: [String: [String]] = {
        var aliases = ingredientAliases

        for ingredient in AppDataModel.shared.allIngredients() {
            let key = normalizeIngredient(ingredient.name)
            var values = aliases[key] ?? [ingredient.name]
            values.append(ingredient.name)
            values.append(contentsOf: ingredient.aliases ?? [])
            aliases[key] = Array(Set(values.map(normalize))).sorted()
        }

        return aliases
    }()

    private lazy var allConflictPairs: [[String]] = {
        var pairs = conflicts

        for ingredient in AppDataModel.shared.allIngredients() {
            for conflict in ingredient.avoidWith ?? [] {
                pairs.append([ingredient.name, conflict])
            }

            for conflictingID in ingredient.conflictingWith {
                guard let conflictingIngredient = AppDataModel.shared.ingredient(forID: conflictingID) else { continue }
                pairs.append([ingredient.name, conflictingIngredient.name])
            }
        }

        return deduplicatedConflictPairs(from: pairs)
    }()
    
    func getRoutineIngredients(for step: String) -> [String] {
        let fallback = routine[step] ?? []
        let stepKey = step.lowercased()
        let aiIngredients = AppDataModel.shared.aiRoutineIngredients()
            .filter { $0.step == stepKey }
            .flatMap { $0.ingredients }

        let currentUserID = dataModel.currentUser().id
        let jsonIngredients = dataModel.routineStepsForHomeScreen(for: currentUserID)
            .filter { $0.type.rawValue == stepKey }
            .flatMap { dataModel.ingredientNames(for: $0) }

        return Array(Set((fallback + aiIngredients + jsonIngredients).map(normalizeIngredient))).sorted()
    }
    
    func getConflictingPairs() -> [[String]] {
        allConflictPairs
    }
    
    func currentRoutineContains(_ ingredient: String) -> Bool {
        currentRoutineIngredients().contains(normalizeIngredient(ingredient))
    }

    func identifyIngredients(in text: String) -> [String] {
        let normalizedText = normalize(text)
        let textTokens = Set(normalizedText.split(separator: " ").map(String.init))
        var detected = Set<String>()

        for (ingredient, aliases) in mergedIngredientAliases {
            if aliases.contains(where: { containsPhrase($0, in: normalizedText) }) ||
                matchesIngredientTokens(ingredient: ingredient, aliases: aliases, textTokens: textTokens) {
                detected.insert(ingredient)
            }
        }

        return detected.sorted()
    }

    func analyze(scannedIngredients: [String], for step: String) -> ScanAnalysisResult {
        let normalizedScanned = Set(scannedIngredients.map(normalizeIngredient))
        let shouldUseWholeRoutine = step.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            step.caseInsensitiveCompare("Ingredient scanner") == .orderedSame
        let recommended = shouldUseWholeRoutine
            ? Array(currentRoutineIngredients())
            : getRoutineIngredients(for: step).map(normalizeIngredient)
        let routineIngredients = currentRoutineIngredients()

        let matched = normalizedScanned.intersection(recommended).sorted()
        var conflictMessages: [String] = []

        if normalizedScanned.isEmpty {
            return ScanAnalysisResult(
                isRecommended: false,
                title: "Scan a relevant product",
                detail: "This does not look like a skincare ingredient label. Scan a product that clearly shows skincare ingredients.",
                detectedIngredients: scannedIngredients,
                matchedIngredients: [],
                conflicts: []
            )
        }

        for pair in allConflictPairs {
            guard pair.count == 2 else { continue }
            let first = normalizeIngredient(pair[0])
            let second = normalizeIngredient(pair[1])

            let productHasFirst = normalizedScanned.contains(first)
            let productHasSecond = normalizedScanned.contains(second)
            let routineHasFirst = routineIngredients.contains(first)
            let routineHasSecond = routineIngredients.contains(second)

            if (productHasFirst && (productHasSecond || routineHasSecond)) ||
                (productHasSecond && routineHasFirst) {
                conflictMessages.append("\(pair[0]) clashes with \(pair[1])")
            }
        }

        if !conflictMessages.isEmpty {
            return ScanAnalysisResult(
                isRecommended: false,
                title: "Not Recommended",
                detail: "Not recommended because these ingredients conflict with your routine: \(conflictMessages.joined(separator: ", ")).",
                detectedIngredients: scannedIngredients,
                matchedIngredients: matched,
                conflicts: conflictMessages
            )
        }

        if !matched.isEmpty {
            return ScanAnalysisResult(
                isRecommended: true,
                title: "Product Recommended",
                detail: "Recommended because these ingredients match your routine: \(matched.map(displayName(for:)).joined(separator: ", ")).",
                detectedIngredients: scannedIngredients,
                matchedIngredients: matched,
                conflicts: []
            )
        }

        return ScanAnalysisResult(
            isRecommended: false,
            title: "Not Recommended",
            detail: "Not recommended because the scanned ingredients do not match your routine.",
            detectedIngredients: scannedIngredients,
            matchedIngredients: [],
            conflicts: []
        )
    }

    private func containsPhrase(_ phrase: String, in text: String) -> Bool {
        let normalizedPhrase = normalize(phrase)
        return " \(text) ".contains(" \(normalizedPhrase) ")
    }

    private func matchesIngredientTokens(ingredient: String, aliases: [String], textTokens: Set<String>) -> Bool {
        ingredientTokenCandidates(for: ingredient, aliases: aliases).contains { candidate in
            let candidateTokens = significantTokens(in: candidate)
            guard !candidateTokens.isEmpty else { return false }
            return candidateTokens.isSubset(of: textTokens)
        }
    }

    private func ingredientTokenCandidates(for ingredient: String, aliases: [String]) -> [String] {
        Array(Set([ingredient] + aliases))
    }

    private func significantTokens(in text: String) -> Set<String> {
        Set(
            normalize(text)
                .split(separator: " ")
                .map(String.init)
                .filter { token in
                    token.count > 2 && !weakIngredientTokens.contains(token)
                }
        )
    }

    private func displayName(for ingredient: String) -> String {
        AppDataModel.shared.ingredient(named: ingredient)?.name ?? ingredient.capitalized
    }

    private func deduplicatedConflictPairs(from pairs: [[String]]) -> [[String]] {
        var seen = Set<String>()
        var result: [[String]] = []

        for pair in pairs where pair.count == 2 {
            let normalizedPair = pair.map(normalizeIngredient).sorted()
            guard normalizedPair.count == 2,
                  normalizedPair[0] != normalizedPair[1] else { continue }

            let key = normalizedPair.joined(separator: "::")
            if seen.insert(key).inserted {
                result.append(normalizedPair)
            }
        }

        return result
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9,]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizeIngredient(_ ingredient: String) -> String {
        let normalized = normalize(ingredient)
        if normalized == "alpha hydroxy acid" || normalized == "glycolic acid" ||
            normalized == "lactic acid" || normalized == "mandelic acid" {
            return normalized == "alpha hydroxy acid" ? "aha" : normalized
        }
        return normalized
    }

    private func currentRoutineIngredients() -> Set<String> {
        let currentUserID = dataModel.currentUser().id
        let jsonIngredients = dataModel.routineStepsForHomeScreen(for: currentUserID)
            .flatMap { dataModel.ingredientNames(for: $0) }
        let aiIngredients = AppDataModel.shared.aiRoutineIngredients().flatMap { $0.ingredients }
        let fallback = routine.values.flatMap { $0 }

        return Set((fallback + jsonIngredients + aiIngredients).map(normalizeIngredient))
    }
}

private extension AppDataModel {
    func aiRoutineIngredients() -> [(step: String, ingredients: [String])] {
        guard let aiRoutine else { return [] }
        let allSteps = aiRoutine.morning + aiRoutine.evening
        return allSteps.map {
            (step: $0.productType.rawValue, ingredients: $0.keyIngredients)
        }
    }
}
