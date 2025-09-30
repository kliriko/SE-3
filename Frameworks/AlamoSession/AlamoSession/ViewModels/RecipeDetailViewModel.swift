//
//  RecipeDetailViewModel.swift
//  AlamoSession
//
//  Created by Володимир on 22.09.2025.
//

import Foundation
import Combine
import Alamofire

class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var cuisine = ""
    @Published var recipeInformation: RecipeInformation? = nil
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    func identifyCuisine() {
        Task {
            if let cuisineResult: Cuisine = await AlamoSession.request(
                type: .alamofire,
                API: Constants.cusineClassificationRequestURL,
                query: "",
                method: .post,
                parameters: [
                    "ingredientList": "0",
                    "title": recipe.title
                ]
            ) {
                self.cuisine = cuisineResult.cuisine
            } else {
                print("Failed to fetch cuisine")
            }
        }
    }
    
    func identifyDetails() {
        Task {
            if let informationResult: RecipeInformation = await AlamoSession.request(
                type: .alamofire,
                API: Constants.recipeInformationRequestURL,
                query: "\(recipe.id)/information",
                method: .get
            ) {
                await MainActor.run {
                    self.recipeInformation = informationResult
                }
            } else {
                print("Failed to fetch recipe info")
            }
        }
    }
}
