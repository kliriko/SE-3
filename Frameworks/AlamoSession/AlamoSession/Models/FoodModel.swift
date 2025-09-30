//
//  FoodModel.swift
//  AlamoSession
//
//  Created by Володимир on 21.09.2025.
//

import Foundation

nonisolated struct RecipeSearch: Codable {
    let results: [Recipe]
}

nonisolated struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String
}

nonisolated struct Cuisine: Codable {
    let cuisine: String
}

nonisolated struct RecipeInformation: Codable {
    let readyInMinutes: Int
    let servings: Int
    let extendedIngredients: [Ingridient]
}

struct Ingridient: Codable, Identifiable {
    let id: Int
    let amount: Double
    let original: String
    let image: String?
}

nonisolated struct NutritionResponse: Codable {
    let calories: NutritionCalories
}

struct NutritionCalories: Codable {
    let value: Int
}

struct Constants {
    static let baseRecipeRequestURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch?query="
    static let cusineClassificationRequestURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/cuisine"
    static let recipeInformationRequestURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/"
    static let recipeNutritionRequestURL = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/guessNutrition?title="
    static let RapidAPIKey = "5e392b455amsha99f0902c6e694fp15c3f1jsndb4ba5d5fddb"
}

