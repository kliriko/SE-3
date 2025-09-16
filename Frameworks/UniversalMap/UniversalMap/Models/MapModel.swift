//
//  MapScreenModel.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import Foundation
import MapKit
import GoogleMaps

enum MapProvider: String {
    case gms, mapkit
}

enum MapType: String {
    case standard, satelite, hybrid
}

struct Point: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.id == rhs.id
    }
}

struct GMSPlacesResponse: Decodable {
    let results: [GMSPlace]
}

struct GMSPlace: Decodable {
    let name: String
    let geometry: GMSGeometry
}

struct GMSGeometry: Decodable {
    let location: GMSLocation
}

struct GMSLocation: Decodable {
    let lat: Double
    let lng: Double
}

struct GMSDirectionsResponse: Decodable {
    let routes: [GMSDirectionsRoute]
}

struct GMSDirectionsRoute: Decodable {
    let overview_polyline: GMSPolylineData
}

struct GMSPolylineData: Decodable {
    let points: String
}

enum MapCameraState {
    case mapkitRegion(MKCoordinateRegion)
    case gmsCamera(GMSCameraPosition)
}

protocol MapProviderProtocol {
    func resetCameraPosition(userLocation: CLLocationCoordinate2D?) -> MapCameraState
    func performSearch(query: String,
                       cameraLatitude: Double,
                       cameraLongitude: Double,
                       completion: @escaping (Result<[Point], Error>) -> Void)
    func getDirections(start: CLLocationCoordinate2D,
                       destination: CLLocationCoordinate2D,
                       completion: @escaping (Result<RouteRepresentation, Error>) -> Void)
}
