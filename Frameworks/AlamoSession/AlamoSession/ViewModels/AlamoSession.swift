//
//  AlamoSession.swift
//  AlamoSession
//
//  Created by Володимир on 22.09.2025.
//

import Foundation
import Alamofire

enum RequestType: String {
    case alamofire, urlsession
}

final class AlamoSession {
    static func request<T: Codable>(type: RequestType, API: String, query: String, method: HTTPMethod, parameters: [String: Any]? = nil) async throws -> T{
        
        let combinedQuery = API + query
        guard let url = URL(string: combinedQuery) else {
            throw URLError(.badURL)
        }
        
        switch type {
            case .alamofire:
                let response = try await AF.request(combinedQuery, method: method, parameters: parameters, headers: ["X-RapidAPI-Host" : "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",                  "X-RapidAPI-Key" : Constants.RapidAPIKey])
                    .serializingDecodable(T.self)
                    .value
                return response
            
            case .urlsession:
                var request = URLRequest(url: url)

                request.httpMethod = String(describing: method)
                request.setValue("spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
                request.setValue(Constants.RapidAPIKey, forHTTPHeaderField: "X-RapidAPI-Key")
            
            
                if let parameters = parameters {
                    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                }
            
            
                let (data, response) = try await URLSession.shared.data(for: request)
                let recipeResponse = try JSONDecoder().decode(T.self, from: data)
                
                return recipeResponse
        }
    }
}
