//
//  ProviderViewModel.swift
//  UniversalMap
//
//  Created by Володимир on 16.09.2025.
//

import Foundation
import MapKit
import GoogleMaps

class MapKitProvider: MapProviderProtocol {
    func resetCameraPosition() -> MapCameraState {
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.450001, longitude: 30.523333),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
        return .mapkitRegion(defaultRegion)
    }
    
    func performSearch(query: String,
                       cameraLatitude: Double,
                       cameraLongitude: Double,
                       completion: @escaping (Result<[Point], Error>) -> Void) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: cameraLatitude, longitude: cameraLongitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        MKLocalSearch(request: request).start { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let points = response?.mapItems.map { item in
                Point(name: item.name ?? "Unknown", coordinate: item.placemark.coordinate)
            } ?? []
            
            completion(.success(points))
        }
    }
    
    func getDirections(start: CLLocationCoordinate2D,
                       destination: CLLocationCoordinate2D,
                       completion: @escaping (Result<RouteRepresentation, Error>) -> Void) {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        MKDirections(request: request).calculate { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let route = response?.routes.first else {
                completion(.failure(NSError(domain: "NoRoute", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(RouteRepresentation(mapKitRoute: route)))
        }
    }
}

class GMSProvider: MapProviderProtocol {
    
    func resetCameraPosition() -> MapCameraState {
        let camera = GMSCameraPosition(latitude: 50.450001, longitude: 30.523333, zoom: 14)
        return .gmsCamera(camera)
    }
    
    func performSearch(query: String,
                       cameraLatitude: Double,
                       cameraLongitude: Double,
                       completion: @escaping (Result<[Point], Error>) -> Void) {
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(cameraLatitude),\(cameraLongitude)&radius=5000&keyword=\(query)&key=YOUR_API_KEY"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(GMSPlacesResponse.self, from: data)
                let points = result.results.map { place in
                    Point(name: place.name,
                          coordinate: CLLocationCoordinate2D(latitude: place.geometry.location.lat,
                                                             longitude: place.geometry.location.lng))
                }
                completion(.success(points))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getDirections(start: CLLocationCoordinate2D,
                       destination: CLLocationCoordinate2D,
                       completion: @escaping (Result<RouteRepresentation, Error>) -> Void) {
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start.latitude),\(start.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=YOUR_API_KEY"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(GMSDirectionsResponse.self, from: data)
                let route = RouteRepresentation(from: result)
                completion(.success(route))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
