//
//  MapScreenModel.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import Foundation
import MapKit

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
