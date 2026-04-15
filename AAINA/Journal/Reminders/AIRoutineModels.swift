import Foundation

struct AIRoutineOutput: Codable {
    let morning: [AIRoutineStep]
    let evening: [AIRoutineStep]
}

struct AIRoutineStep: Codable, Identifiable {
    let id: String
    let stepNumber: Int
    let productType: StepType      // StepType defined in Models.swift
    let productName: String
    let keyIngredients: [String]
    let reason: String
    let usage: String
    let isUserAdded: Bool
}

// MARK: - Face Scan Analysis Result

struct FaceScanResult: Codable {
    let skinType: String           // e.g. "Combination", "Oily", "Dry", "Normal"
    let skinTone: String           // e.g. "Fair", "Medium", "Olive", "Deep", "Rich"
    let concerns: [FaceScanConcern]
    let summary: String            // 1–2 sentence plain-English summary
}

struct FaceScanConcern: Codable {
    let name: String       // e.g. "Dark circles", "Redness", "Visible pores"
    let severity: String   // "mild", "moderate", "notable"
    let area: String       // e.g. "under-eye area", "T-zone", "cheeks"
}

struct FullAnalysisOutput: Codable {
    let routine: AIRoutineOutput
    let scanResult: FaceScanResult
}
