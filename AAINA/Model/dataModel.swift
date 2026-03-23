//dataModel.swift
import Foundation
import UIKit

final class DataModel {

    private var users: [User] = []
    private var profiles: [Profile] = []
    private var ingredients: [Ingredient] = []
    private var routines: [Routine] = []
    private var journals: [JournalEntry] = []
    private var weeklyProgress: [WeeklyProgress] = []
    private var dailyTip: DailyTip?
    private var skinInsights: [SkinInsight] = []
    private var affirmations: [Affirmation] = []

    private var routineCompletion: [String:[String:Bool]] = [:]

    init() {
        loadJSON()
    }

    private func loadJSON() {

        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            fatalError("data.json missing")
        }

        do {

            let data = try Data(contentsOf: url)
            let root = try JSONDecoder().decode(SkinCareRoot.self, from: data)

            users = root.users
            profiles = root.profiles
            ingredients = root.ingredients
            routines = root.routines
            journals = root.journals
            weeklyProgress = root.weeklyProgress
            dailyTip = root.dailyTip
            skinInsights = root.skinInsights
            affirmations = root.affirmations

        } catch {

            fatalError("JSON decode error: \(error)")
        }
    }

    // MARK: USER

    func currentUser() -> User {

        guard let user = users.first else {
            fatalError("No user")
        }

        return user
    }

    func profile(for userID: String) -> Profile? {
        profiles.first { $0.userID == userID }
    }

    // MARK: ROUTINE

    func activeRoutine(for userID: String) -> Routine? {
        routines.first { $0.userID == userID && $0.isActive }
    }

    func morningSteps(for userID: String) -> [RoutineStep] {

        activeRoutine(for: userID)?
            .steps
            .filter { $0.timeOfDay == .morning }
            .sorted { $0.stepOrder < $1.stepOrder } ?? []
    }

    func eveningSteps(for userID: String) -> [RoutineStep] {

        activeRoutine(for: userID)?
            .steps
            .filter { $0.timeOfDay == .evening }
            .sorted { $0.stepOrder < $1.stepOrder } ?? []
    }

    func routineStepsForHomeScreen(for userID: String) -> [RoutineStep] {

        activeRoutine(for: userID)?
            .steps
            .sorted { $0.stepOrder < $1.stepOrder } ?? []
    }

    // MARK: INGREDIENTS

    func ingredient(for id: String) -> Ingredient? {
        ingredients.first { $0.id == id }
    }

    func ingredientNames(for step: RoutineStep) -> [String] {

        step.ingredientIDs.compactMap {
            ingredient(for: $0)?.name
        }
    }

    func hasIngredientConflict(ingredientIDs: [String]) -> Bool {

        let selected = ingredients.filter { ingredientIDs.contains($0.id) }

        for ingredient in selected {

            for conflict in ingredient.conflictingWith {

                if ingredientIDs.contains(conflict) {
                    return true
                }
            }
        }

        return false
    }

    // MARK: JOURNAL

    func journals(for userID: String) -> [JournalEntry] {
        journals.filter { $0.userID == userID }
    }

    // MARK: PROGRESS

    func weeklyProgress(for userID: String) -> WeeklyProgress? {
        weeklyProgress.first { $0.userID == userID }
    }

    func insightPoints(for userID: String) -> (points:Int, weekly:Int) {

        guard let progress = weeklyProgress(for: userID) else {
            return (0,0)
        }

        let avg = progress.days.map{$0.progress}.reduce(0,+)/Double(progress.days.count)

        return (Int(avg*100),Int(avg*15))
    }

    // MARK: DAILY TIP

    func getDailyTip() -> DailyTip? {
        dailyTip
    }

    // MARK: INSIGHTS

    func skinMatrixInsights() -> [SkinInsight] {
        skinInsights
    }

    func rotatingInsightUIModels() -> [(UIImage,String,Int)] {

        skinInsights.compactMap {

            guard let img = UIImage(systemName: $0.icon) else { return nil }

            return (img,$0.title,$0.percent)
        }
    }

    // MARK: AFFIRMATIONS

    func nextAffirmation() -> Affirmation? {

        guard !affirmations.isEmpty else { return nil }

        let key = "last_affirmation_id"
        let last = UserDefaults.standard.string(forKey: key)

        var available = affirmations

        if let last {
            available.removeAll{$0.id == last}
        }

        let random = available.randomElement()

        if let random {
            UserDefaults.standard.set(random.id, forKey: key)
        }

        return random
    }

    // MARK: ROUTINE CHECKBOX

    func toggleStep(stepID:String,date:Date){

        let key = dateKey(date)

        if routineCompletion[key] == nil {
            routineCompletion[key] = [:]
        }

        let current = routineCompletion[key]?[stepID] ?? false
        routineCompletion[key]?[stepID] = !current
    }

    func isStepDone(stepID:String,date:Date)->Bool{

        let key = dateKey(date)

        return routineCompletion[key]?[stepID] ?? false
    }

    private func dateKey(_ date:Date)->String{

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }

    // MARK: AI ROUTINE

    func allIngredients() -> [Ingredient] {
        ingredients
    }

    func matchIngredient(name: String) -> Ingredient? {
        let lower = name.lowercased()
        return ingredients.first {
            $0.name.lowercased() == lower ||
            ($0.aliases?.contains { $0.lowercased() == lower } ?? false)
        }
    }

    func saveAIRoutine(_ output: AIRoutineOutput) {
        guard let data = try? JSONEncoder().encode(output) else { return }
        try? data.write(to: aiRoutineURL)
    }

    func loadAIRoutine() -> AIRoutineOutput? {
        guard let data = try? Data(contentsOf: aiRoutineURL) else { return nil }
        return try? JSONDecoder().decode(AIRoutineOutput.self, from: data)
    }

    private var aiRoutineURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ai_routine.json")
    }
}
