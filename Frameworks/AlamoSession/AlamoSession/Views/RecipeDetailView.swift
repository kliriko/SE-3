//
//  RecipeDetailView.swift
//  AlamoSession
//
//  Created by Володимир on 22.09.2025.
//

import SwiftUI
import Alamofire // maybe add extra abstraction to not import it here just for one line

struct RecipeDetailView: View {
    @ObservedObject var viewModel: RecipeDetailViewModel
    
    init(recipe: Recipe) {
        viewModel = RecipeDetailViewModel(recipe: recipe)
    }
    
    var body: some View {
        VStack (spacing: 0){
            if !viewModel.cuisine.isEmpty {
                Text("Cuisine: \(viewModel.cuisine)")
            }
            
            Text(viewModel.recipe.title)
                .font(.title)
                .padding()
            if let url = URL(string: viewModel.recipe.image) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }
            
            if let information = viewModel.recipeInformation {
                Text("Time to prepare: \(information.readyInMinutes)")
                Text("Servings: \(information.servings)")
                
                List(information.extendedIngredients) { ingredient in
                    VStack(alignment: .leading) {
                        Text(ingredient.original)
                            .font(.body)
                    }
                }
            }
        }
            
        .navigationTitle(viewModel.recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.identifyCuisine()
            viewModel.identifyDetails()
        }
    }
}


#Preview {
    RecipeDetailView(recipe: Recipe(id: 0, title: "Sample Recipe", image: "https://example.com/image.jpg"))
}
