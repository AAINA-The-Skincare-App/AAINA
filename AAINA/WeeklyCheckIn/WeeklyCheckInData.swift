//
//  WeeklyCheckInData.swift
//  AAINA
//

import UIKit

struct WeeklyCheckInData {
    var weekStart: Date = Date()
    var skinCondition: String = ""
    var concerns: [String] = []
    var morningDaysCompleted: [Int] = []   // indices 0-6
    var eveningDaysCompleted: [Int] = []
    var sleepQuality: Int = 0              // 1-5
    var stressLevel: Float = 0.5           // 0-1
    var waterIntake: Int = 0               // glasses
    var productChanges: [(name: String, isAdded: Bool)] = []
    var progressPhoto: UIImage? = nil
    var additionalNotes: String = ""
    var wantsRoutineChange: Bool = false
    var routineChangeReason: String = ""
}
