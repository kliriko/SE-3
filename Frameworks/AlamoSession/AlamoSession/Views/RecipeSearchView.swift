//
//  ContentView.swift
//  AlamoSession
//
//  Created by Володимир on 21.09.2025.
//

import SwiftUI
import Alamofire

struct RecipeSearchView: View {
    @StateObject var viewModel: RecipeSearchViewModel = RecipeSearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Search", text: $viewModel.searchResult)
                    Button("Search") {
                        Task {
                            if let recipeSearch: RecipeSearch = await AlamoSession.request(type: .urlsession, API: Constants.baseRecipeRequestURL, query: viewModel.searchResult,
                                method: .get
                            ) {
                                viewModel.recipes = recipeSearch.results
                            }
                            
                        }
                    }
                    Button("Nutrition") {
                        viewModel.identifyNutririon()
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
