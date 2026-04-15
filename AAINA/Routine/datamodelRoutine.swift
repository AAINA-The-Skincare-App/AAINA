///
//  datamodelRoutine.swift
//  AAINA
//
//  Created by GEU on 09/04/26.
//

import Foundation



struct IngredientConcentration {
    let min: String
    let max: String
    var range: String { "\(min) – \(max)" }
}

final class IngredientConcentrationDatabase {
    static let shared = IngredientConcentrationDatabase()
    private init() {}

    private let data: [String: IngredientConcentration] = [
        // High-Performance Actives
        "retinol":           IngredientConcentration(min: "0.01%", max: "0.3%"),
        "salicylic acid":    IngredientConcentration(min: "0.5%",  max: "2.0%"),
        "glycolic acid":     IngredientConcentration(min: "5%",    max: "10%"),
        "lactic acid":       IngredientConcentration(min: "1%",    max: "5%"),
        "vitamin c":         IngredientConcentration(min: "10%",   max: "20%"),
        "ascorbic acid":     IngredientConcentration(min: "10%",   max: "20%"),
        "niacinamide":       IngredientConcentration(min: "2%",    max: "5%"),
        "alpha-arbutin":     IngredientConcentration(min: "1%",    max: "2%"),
        "kojic acid":        IngredientConcentration(min: "0.5%",  max: "1%"),
        "azelaic acid":      IngredientConcentration(min: "5%",    max: "10%"),
        "bakuchiol":         IngredientConcentration(min: "0.5%",  max: "1%"),
        "cbd":               IngredientConcentration(min: "0.1%",  max: "0.2%"),
        "caffeine":          IngredientConcentration(min: "0.5%",  max: "3%"),
        "tranexamic acid":   IngredientConcentration(min: "2%",    max: "5%"),
        // Humectants & Hydrators
        "hyaluronic acid":   IngredientConcentration(min: "0.1%",  max: "2%"),
        "glycerin":          IngredientConcentration(min: "2%",    max: "10%"),
        "panthenol":         IngredientConcentration(min: "1%",    max: "5%"),
        "squalane":          IngredientConcentration(min: "1%",    max: "100%"),
        "ceramides":         IngredientConcentration(min: "0.01%", max: "1%"),
        "ceramide np":       IngredientConcentration(min: "0.01%", max: "1%"),
        "urea":              IngredientConcentration(min: "2%",    max: "10%"),
        "allantoin":         IngredientConcentration(min: "0.1%",  max: "0.5%"),
        "aloe vera":         IngredientConcentration(min: "0.1%",  max: "1%"),
        "sodium pca":        IngredientConcentration(min: "0.5%",  max: "2%"),
        "beta-glucan":       IngredientConcentration(min: "0.1%",  max: "1%"),
        // Emollients & Occlusives
        "shea butter":       IngredientConcentration(min: "1%",    max: "20%"),
        "petrolatum":        IngredientConcentration(min: "10%",   max: "100%"),
        "jojoba oil":        IngredientConcentration(min: "1%",    max: "10%"),
        "argan oil":         IngredientConcentration(min: "0.5%",  max: "5%"),
        "caprylic triglyceride": IngredientConcentration(min: "2%", max: "15%"),
        "dimethicone":       IngredientConcentration(min: "1%",    max: "5%"),
        "isopropyl palmitate": IngredientConcentration(min: "1%",  max: "5%"),
        // Preservatives & Stabilisers
        "phenoxyethanol":    IngredientConcentration(min: "0.5%",  max: "1%"),
        "sodium benzoate":   IngredientConcentration(min: "0.1%",  max: "0.5%"),
        "potassium sorbate": IngredientConcentration(min: "0.1%",  max: "0.5%"),
        "ethylhexylglycerin": IngredientConcentration(min: "0.3%", max: "1%"),
        "bht":               IngredientConcentration(min: "0.01%", max: "0.1%"),
        "disodium edta":     IngredientConcentration(min: "0.1%",  max: "0.2%"),
        "tocopherol":        IngredientConcentration(min: "0.1%",  max: "0.5%"),
        "vitamin e":         IngredientConcentration(min: "0.1%",  max: "0.5%"),
        // Texture & Sunscreen
        "xanthan gum":       IngredientConcentration(min: "0.1%",  max: "1%"),
        "carbomer":          IngredientConcentration(min: "0.1%",  max: "0.5%"),
        "cetyl alcohol":     IngredientConcentration(min: "1%",    max: "5%"),
        "citric acid":       IngredientConcentration(min: "0.1%",  max: "1%"),
        "zinc oxide":        IngredientConcentration(min: "5%",    max: "25%"),
        "titanium dioxide":  IngredientConcentration(min: "2%",    max: "15%"),
        "avobenzone":        IngredientConcentration(min: "2%",    max: "3%"),
        "octocrylene":       IngredientConcentration(min: "5%",    max: "10%"),
        // Surfactants
        "cocamidopropyl betaine": IngredientConcentration(min: "2%", max: "10%"),
        "decyl glucoside":   IngredientConcentration(min: "3%",    max: "15%"),
        "polysorbate 20":    IngredientConcentration(min: "1%",    max: "5%"),
        "lauryl glucoside":  IngredientConcentration(min: "2%",    max: "10%"),
        // Peptides
        "peptides":          IngredientConcentration(min: "0.01%", max: "2%"),
        "colloidal oatmeal": IngredientConcentration(min: "0.5%",  max: "5%"),
        "ferulic acid":      IngredientConcentration(min: "0.5%",  max: "1%"),
    ]

    /// Returns concentration for a given ingredient name (case-insensitive).
    func concentration(for name: String) -> IngredientConcentration? {
        data[name.lowercased().trimmingCharacters(in: .whitespaces)]
    }
}


struct SkincareProduct {
    let id: String
    let brand: String
    let name: String
    let ingredients: [String]
    let imageURL: String?
    let productURL: String?
}

// MARK: - Product Database

// MARK: - Ingredient Personalization Engine

final class IngredientPersonalizationEngine {
    static let shared = IngredientPersonalizationEngine()
    private init() {}

    /// Returns a short "Benefit for You" reason for an ingredient given the user's profile.
    func reason(for ingredientName: String, profile: Profile) -> String? {
        let key = ingredientName.lowercased().trimmingCharacters(in: .whitespaces)

        // 1. Try goal-specific reason first
        for goal in profile.goals {
            if let r = goalReasons[key]?[goal] { return r }
        }

        // 2. Try skin-type reason (check all three zones)
        let zones: [SkinType] = [profile.tZoneType, profile.uZoneType, profile.cZoneType]
        for zone in zones {
            if let r = skinTypeReasons[key]?[zone] { return r }
        }

        // 3. Generic fallback
        return genericReasons[key]
    }

    // MARK: - Goal-Specific Reasons
    private let goalReasons: [String: [SkinGoal: String]] = [
        "glycerin": [
            .hydration:    "Draws moisture into skin — matched to your hydration goal",
            .oilControl:   "Hydrates without heaviness — safe for oil-prone areas",
            .maintainSkin: "Supports your skin's natural moisture barrier"
        ],
        "hyaluronic acid": [
            .hydration:    "Holds 1000× its weight in water — directly targets your hydration goal",
            .antiAging:    "Plumps fine lines by replenishing moisture levels",
            .maintainSkin: "Keeps skin supple and balanced throughout the day"
        ],
        "niacinamide": [
            .oilControl:   "Regulates sebum production — chosen for your oil-control goal",
            .poreMinimize: "Visibly tightens pores with consistent use",
            .toneImprove:  "Fades uneven tone and reduces redness",
            .glow:         "Brightens dullness and evens out skin texture"
        ],
        "salicylic acid": [
            .oilControl:   "Clears pore-clogging sebum — ideal for your oily zones",
            .poreMinimize: "Dissolves debris inside pores to reduce their appearance"
        ],
        "retinol": [
            .antiAging:    "Stimulates collagen renewal — chosen for your anti-aging goal",
            .toneImprove:  "Speeds up cell turnover to reveal fresher skin",
            .poreMinimize: "Refines skin texture and minimizes pore visibility"
        ],
        "vitamin c": [
            .glow:         "Brightens complexion — selected for your glow goal",
            .toneImprove:  "Fades dark spots and evens skin tone",
            .antiAging:    "Neutralises free radicals and boosts collagen"
        ],
        "ascorbic acid": [
            .glow:         "Boosts radiance — selected for your glow goal",
            .toneImprove:  "Reduces hyperpigmentation and evens skin tone"
        ],
        "ceramide np": [
            .maintainSkin: "Reinforces skin barrier — supports your skin maintenance goal",
            .hydration:    "Locks in moisture by sealing the skin barrier"
        ],
        "ceramides": [
            .maintainSkin: "Repairs and maintains your protective skin barrier",
            .hydration:    "Prevents moisture loss throughout the day"
        ],
        "squalane": [
            .hydration:    "Lightweight emollient that seals in hydration without pore-clogging",
            .maintainSkin: "Mimics skin's natural oils to maintain healthy barrier"
        ],
        "zinc oxide": [
            .maintainSkin: "Broad-spectrum UV shield — protects your daily routine investment",
            .oilControl:   "Mineral sunscreen that won't trigger breakouts on oily skin"
        ],
        "azelaic acid": [
            .toneImprove:  "Targets redness and pigmentation — matched to your tone goal",
            .oilControl:   "Reduces bacterial growth that leads to breakouts"
        ],
        "lactic acid": [
            .glow:         "Gently exfoliates dead cells for an instant glow",
            .hydration:    "Exfoliates and hydrates simultaneously"
        ],
        "alpha-arbutin": [
            .toneImprove:  "Inhibits melanin production — chosen for your tone-evening goal",
            .glow:         "Fades dark spots to reveal brighter skin"
        ],
        "peptides": [
            .antiAging:    "Signal proteins that stimulate collagen and elastin production",
            .maintainSkin: "Supports healthy skin structure and firmness"
        ],
        "panthenol": [
            .hydration:    "Deeply hydrating pro-vitamin that soothes and repairs",
            .maintainSkin: "Strengthens skin barrier and reduces irritation"
        ],
    ]

    // MARK: - Skin-Type Reasons
    private let skinTypeReasons: [String: [SkinType: String]] = [
        "glycerin": [
            .oily:        "Lightweight humectant — hydrates your oily skin without greasiness",
            .dry:         "Pulls moisture into dry skin and holds it there",
            .combination: "Balances hydration across your combination zones",
            .normal:      "Maintains your skin's optimal hydration level"
        ],
        "hyaluronic acid": [
            .dry:         "Intensely replenishes moisture lost by dry skin",
            .oily:        "Oil-free hydration — won't add excess shine",
            .combination: "Hydrates dry patches without congesting oily zones"
        ],
        "niacinamide": [
            .oily:        "Controls excess oil in your T-zone",
            .combination: "Balances oil in oily zones while being gentle on dry areas",
            .dry:         "Strengthens barrier to reduce moisture loss"
        ],
        "salicylic acid": [
            .oily:        "Cuts through sebum buildup typical of oily skin",
            .combination: "Targets oil-prone zones without over-drying dry areas"
        ],
        "ceramide np": [
            .dry:         "Replenishes ceramides often depleted in dry skin",
            .normal:      "Maintains your already-healthy moisture barrier"
        ],
        "ceramides": [
            .dry:         "Restores lipid barrier stripped by dryness",
            .combination: "Strengthens barrier in drier zones of your combination skin"
        ],
        "squalane": [
            .dry:         "Rich emollient that nourishes persistently dry skin",
            .oily:        "Non-comedogenic oil that regulates sebum without clogging"
        ],
        "zinc oxide": [
            .oily:        "Mattifying mineral SPF — won't worsen oiliness",
            .dry:         "Gentle mineral filter suitable for sensitive dry skin"
        ],
        "lactic acid": [
            .dry:         "Exfoliates while simultaneously hydrating dry skin"
        ],
        "vitamin c": [
            .normal:      "Maintains your healthy glow and prevents photo-ageing",
            .combination: "Brightens and protects across all skin zones"
        ],
        "panthenol": [
            .dry:         "Calms and deeply hydrates dry, tight skin",
            .combination: "Soothes dry patches without blocking pores"
        ],
    ]

    // MARK: - Generic Fallback Reasons
    private let genericReasons: [String: String] = [
        "glycerin":        "Humectant that draws moisture into skin and keeps it there",
        "hyaluronic acid": "Plumps and hydrates skin with lightweight moisture",
        "niacinamide":     "Multi-tasker that refines pores, controls oil, and brightens skin tone",
        "salicylic acid":  "BHA that deeply cleanses pores and prevents breakouts",
        "retinol":         "Gold-standard anti-aging ingredient for cell renewal",
        "vitamin c":       "Powerful antioxidant that brightens and protects",
        "ascorbic acid":   "Boosts radiance and defends against environmental damage",
        "ceramide np":     "Essential lipid that locks in moisture and repairs skin barrier",
        "ceramides":       "Restores the skin's protective lipid barrier",
        "squalane":        "Lightweight emollient that softens and seals moisture",
        "zinc oxide":      "Mineral SPF that shields against UVA and UVB rays",
        "azelaic acid":    "Targets redness, uneven tone, and surface bacteria",
        "lactic acid":     "Gentle AHA that exfoliates and hydrates simultaneously",
        "alpha-arbutin":   "Brightening agent that fades dark spots and uneven tone",
        "peptides":        "Boosts collagen production for firmer, smoother skin",
        "panthenol":       "Soothes, hydrates, and strengthens the skin barrier",
        "titanium dioxide":"Mineral UV filter that reflects harmful rays",
        "ferulic acid":    "Antioxidant that stabilises Vitamin C and boosts its efficacy",
        "bakuchiol":       "Plant-based retinol alternative — gentle yet effective",
        "tranexamic acid": "Targets stubborn dark spots and post-acne marks",
    ]
}

// MARK: - Product Database

final class SkincareProductDatabase {

    static let shared = SkincareProductDatabase()
    private init() {}

    private let allProducts: [SkincareProduct] = [
        SkincareProduct(
            id: "p1",
            brand: "SkinCeuticals",
            name: "Hydrating B5 Gel",
            ingredients: ["Hyaluronic Acid", "Vitamin B5", "Glycerin"],
            imageURL: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=400",
            productURL: "https://www.skinceuticals.com/hydrating-b5-gel/HC587.html"
        ),
        SkincareProduct(
            id: "p2",
            brand: "La Roche-Posay",
            name: "B3 Serum",
            ingredients: ["Niacinamide", "Hyaluronic Acid"],
            imageURL: "https://images.unsplash.com/photo-1556228578-626d95b59e88?w=400",
            productURL: "https://www.laroche-posay.us/our-products/face/serum/pure-niacinamide-b3-serum"
        ),
        SkincareProduct(
            id: "p3",
            brand: "CeraVe",
            name: "Hydrating Cleanser",
            ingredients: ["Ceramides", "Hyaluronic Acid", "Glycerin"],
            imageURL: "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=400",
            productURL: "https://www.cerave.com/skincare/cleansers/hydrating-facial-cleanser"
        ),
        SkincareProduct(
            id: "p4",
            brand: "The Ordinary",
            name: "Niacinamide 10% + Zinc",
            ingredients: ["Niacinamide", "Zinc"],
            imageURL: "https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=400",
            productURL: "https://theordinary.com/en-us/niacinamide-10-zinc-1-100436.html"
        ),
        SkincareProduct(
            id: "p5",
            brand: "Paula's Choice",
            name: "C15 Super Booster",
            ingredients: ["Ascorbic Acid", "Vitamin C", "Ferulic Acid"],
            imageURL: "https://images.unsplash.com/photo-1571781926291-c477ebfd024b?w=400",
            productURL: "https://www.paulaschoice.com/c15-super-booster/607.html"
        ),
        SkincareProduct(
            id: "p6",
            brand: "Neutrogena",
            name: "Hydro Boost Gel",
            ingredients: ["Hyaluronic Acid", "Glycerin"],
            imageURL: "https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?w=400",
            productURL: "https://www.neutrogena.com/skin/skin-moisturizers/hydro-boost-water-gel/6811046.html"
        ),
        SkincareProduct(
            id: "p7",
            brand: "Drunk Elephant",
            name: "Protini Polypeptide Cream",
            ingredients: ["Ceramides", "Peptides", "Vitamin B5"],
            imageURL: "https://images.unsplash.com/photo-1570194065650-d99fb4bedf0a?w=400",
            productURL: "https://www.drunkelephant.com/products/protini-polypeptide-moisturizer"
        ),
        SkincareProduct(
            id: "p8",
            brand: "First Aid Beauty",
            name: "Ultra Repair Cream",
            ingredients: ["Ceramides", "Glycerin", "Colloidal Oatmeal"],
            imageURL: "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=400",
            productURL: "https://www.firstaidbeauty.com/skin-care-products/moisturizers/ultra-repair-cream-intense-hydration"
        ),
        SkincareProduct(
            id: "p9",
            brand: "EltaMD",
            name: "UV Clear SPF 46",
            ingredients: ["Zinc Oxide", "Niacinamide", "Hyaluronic Acid"],
            imageURL: "https://images.unsplash.com/photo-1556228841-a3c527ebefe5?w=400",
            productURL: "https://www.eltamd.com/product/uv-clear-broad-spectrum-spf-46/"
        ),
        SkincareProduct(
            id: "p10",
            brand: "La Roche-Posay",
            name: "Anthelios Mineral SPF 50",
            ingredients: ["Zinc Oxide", "Titanium Dioxide"],
            imageURL: "https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?w=400",
            productURL: "https://www.laroche-posay.us/anthelios-mineral-sunscreen-spf50"
        )
    ]

    /// Returns products whose ingredients overlap with the given list (case-insensitive).
    func products(matchingIngredients ingredients: [String]) -> [SkincareProduct] {
        guard !ingredients.isEmpty else { return [] }
        
        let query = ingredients.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }
        
        return allProducts.filter { product in
            product.ingredients.contains { ing in
                let normalized = ing.lowercased().trimmingCharacters(in: .whitespaces)
                return query.contains(normalized)
            }
        }
    }
    /// Returns all products for a given step type keyword.
    func products(forStepType stepType: String) -> [SkincareProduct] {
        return allProducts
    }
}
