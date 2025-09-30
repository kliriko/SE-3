//
//  RecipeViewModel.swift
//  AlamoSession
//
//  Created by Володимир on 21.09.2025.
//

import Foundation
import Combine
import Alamofire

class RecipeSearchViewModel: ObservableObject {
    @Published var searchResult = ""
    @Published var recipes: [Recipe] = []
    @Published var showNutritionAlertfalse = false
    @Published var nutritionGuess = 0
    
    func identifyNutririon() {
        Task {
            if let nutritionResponse: NutritionResponse = await AlamoSession.request(type: .alamofire, API: Constants.recipeNutritionRequestURL, query: searchResult,
                method: .get
            ) {
                nutritionGuess = nutritionResponse.calories.value
                showNutritionAlertfalse = true
            }
        }
    }
}

