//
//  ContentView.swift
//  AlamoSession
//
//  Created by Володимир on 21.09.2025.
//

import SwiftUI
import Alamofire

struct RecipeSearchView: View {
    @StateObject var viewModel: RecipeViewModel = RecipeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search", text: $viewModel.searchResult)
                    Button("Search") {
                        Task {
                            let recipeSearch: RecipeSearch = try await AlamoSession.request(type: .alamofire, API: Constants.baseRecipeRequestURL, query: viewModel.searchResult,
                                method: .get
                            )
                            viewModel.recipes = recipeSearch.results
                        }
                    }
                    Button("Nutrition") {
                        Task {
                            let nutritionResponse: NutritionResponse = try await AlamoSession.request(type: .alamofire, API: Constants.recipeNutritionRequestURL, query: viewModel.searchResult,
                                method: .get
                            )
                            
                            viewModel.nutritionGuess = nutritionResponse.calories.value
                            viewModel.showNutritionAlertfalse = true
                        }
                    }
                }
                List(content: {
                    ForEach(viewModel.recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            Text(recipe.title)
                        }
                    }
                })
            }
            .padding()
            .alert(isPresented: $viewModel.showNutritionAlertfalse) {
                Alert(title: Text("Nutrition Information"), message: Text("Estimated calories count: \(viewModel.nutritionGuess)"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    RecipeSearchView()
}
