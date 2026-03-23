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
