//
//  RecipeViewModel.swift
//  AlamoSession
//
//  Created by Володимир on 21.09.2025.
//

import Foundation
import Combine

class RecipeViewModel: ObservableObject {
    @Published var searchResult = ""
    @Published var recipes: [Recipe] = []
    @Published var showNutritionAlertfalse = false
    @Published var nutritionGuess = 0
}

