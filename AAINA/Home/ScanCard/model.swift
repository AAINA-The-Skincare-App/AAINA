//
//  model.swift
//  ScanCard
//
//  Created by GEU on 18/03/26.
//

import UIKit

struct ScanItem {
    let title: String
    let subtitle: String
    let imageName: String
}

extension DataModel {
    
    func getScanItems() -> [ScanItem] {
        return [
            ScanItem(title: "Cleanser", subtitle: "Scan face wash ingredients", imageName: "cleanser"),
            ScanItem(title: "Serum", subtitle: "Check serum compatibility", imageName: "serum"),
            ScanItem(title: "Moisturizer", subtitle: "Analyze hydration formula", imageName: "moisturizer"),
            ScanItem(title: "Sunscreen", subtitle: "Verify sun protection", imageName: "sunscreen")
        ]
    }
}

import Foundation

class RoutineManager {
    
    private let routine: [String: [String]] = [
        "Cleanser": ["glycerin", "niacinamide"],
        "Serum": ["vitamin c", "hyaluronic acid"],
        "Moisturizer": ["ceramide", "peptides"],
        "Sunscreen": ["zinc oxide", "avobenzone"]
    ]
    
    private let conflicts: [[String]] = [
        ["retinol", "aha"],
        ["vitamin c", "niacinamide"]
    ]
    
    func getRoutineIngredients(for step: String) -> [String] {
        return routine[step] ?? []
    }
    
    func getConflictingPairs() -> [[String]] {
        return conflicts
    }
    
    func currentRoutineContains(_ ingredient: String) -> Bool {
        return routine.values.flatMap { $0 }.contains(ingredient)
    }
}
