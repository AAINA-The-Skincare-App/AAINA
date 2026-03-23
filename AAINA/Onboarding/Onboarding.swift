//
//  Onboarding.swift
//  SkinRoutineApp SkinRoutineApp SkinRoutineApp
//
//  Created by GEU on 02/02/26.
//
struct OnboardingData: Codable {
    var birthYear: Int?
    var tZone: SkinType?
    var uZone: SkinType?
    var cZone: SkinType?
    var sensitivity: SensitivityLevel?
    var goals: [SkinGoal] = []
    var uvExposure: UVExposureLevel?
}
