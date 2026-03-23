import Foundation

final class IngredientManager {

    static let shared = IngredientManager()

    private(set) var ingredients: [Ingredient] = []
    private var ingredientMap: [String: Ingredient] = [:]

    private init() {
        loadIngredients()
    }

    // MARK: Load JSON

    private func loadIngredients() {

        guard let url = Bundle.main.url(forResource: "ingredients", withExtension: "json") else {
            print("❌ ingredients.json not found in bundle")
            return
        }

        do {

            let data = try Data(contentsOf: url)

            let decoder = JSONDecoder()

            ingredients = try decoder.decode([Ingredient].self, from: data)

            // Create dictionary for fast lookup
            ingredientMap = Dictionary(uniqueKeysWithValues:
                ingredients.map { ($0.id, $0) }
            )

            print("✅ Ingredients loaded:", ingredients.count)

        } catch {

            print("❌ Ingredient JSON decode error:", error)
        }
    }

    // MARK: Get Ingredient by ID
    func ingredient(id: String) -> Ingredient? {

        let normalized = id
            .lowercased()
            .replacingOccurrences(of: "_", with: "-")

        return ingredientMap[normalized]
    }
    // MARK: Optional Helper (if needed)

    func ingredient(named name: String) -> Ingredient? {
        return ingredients.first {
            $0.name.lowercased() == name.lowercased()
        }
    }
}
