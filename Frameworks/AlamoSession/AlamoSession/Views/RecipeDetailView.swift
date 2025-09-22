//
//  RecipeDetailView.swift
//  AlamoSession
//
//  Created by Володимир on 22.09.2025.
//

import SwiftUI
import Alamofire // maybe add extra abstraction to not import it here just for one line

struct RecipeDetailView: View {
    let recipe: Recipe
    @State var cuisine = ""
    @State var recipeInformation: RecipeInformation?
    
    var body: some View {
        VStack {
            if !cuisine.isEmpty {
                Text("Cuisine: \(cuisine)")
            }

            Text(recipe.title)
                .font(.title)
                .padding()
            if let url = URL(string: recipe.image) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
            }
            
            if let information = recipeInformation {
                Text("Time to prepare: \(information.readyInMinutes)")
                Text("Servings: \(information.servings)")
                
                List(){
                    ForEach(information.extendedIngredients) { ingredient in
                        Text(ingredient.aisle + ". Quantity: \(ingredient.amount)")
                    }
                }
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            Task {
                let cuisineResult: Cuisine = try await AlamoSession.request(type: .alamofire, API: Constants.cusineClassificationRequestURL, query: "", method: .post, parameters: [
                    "ingredientList": "0",
                    "title": recipe.title
                    ])
                
                print(Constants.cusineClassificationRequestURL + recipe.title)
                self.cuisine = cuisineResult.cuisine
                
                
                let informationResult: RecipeInformation = try await AlamoSession.request(type: .alamofire, API: Constants.recipeInformationRequestURL, query: String(recipe.id) + "/information", method: .get)
                
                recipeInformation = informationResult
            }
        }
                
    }
}


#Preview {
    RecipeDetailView(recipe: Recipe(id: 0, title: "Sample Recipe", image: "https://example.com/image.jpg"))
}
