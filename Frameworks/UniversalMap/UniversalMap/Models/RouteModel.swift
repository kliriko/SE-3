//
//  MapLink.swift
//  UniversalMap
//
//  Created by Володимир on 16.09.2025.
//

import MapKit
import GoogleMaps

struct RouteRepresentation {
    let coordinates: [CLLocationCoordinate2D]
    
    init(mapKitRoute: MKRoute) {
        self.coordinates = mapKitRoute.polyline.coordinates
    }
    
    init(gmsPath: GMSPath) {
        var coords: [CLLocationCoordinate2D] = []
        for i in 0..<gmsPath.count() {
            coords.append(gmsPath.coordinate(at: i))
        }
        self.coordinates = coords
    }
    
    func toMKPolyline() -> MKPolyline {
        MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: self.pointCount)
        self.getCoordinates(&coords, range: NSRange(location: 0, length: self.pointCount))
        return coords
    }
}

extension String {
    func decodePolyline() -> [CLLocationCoordinate2D] {
        let data = self.data(using: .utf8)!
        var coords: [CLLocationCoordinate2D] = []
        var index = 0
        var lat = 0
        var lng = 0
        
        while index < data.count {
            var b: UInt8
            var shift = 0
            var result = 0
            
            repeat {
                b = data[index] - 63
                result |= Int(b & 0x1F) << shift
                shift += 5
                index += 1
            } while b >= 0x20
            
            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat += dlat
            
            shift = 0
            result = 0
            
            repeat {
                b = data[index] - 63
                result |= Int(b & 0x1F) << shift
                shift += 5
                index += 1
            } while b >= 0x20
            
            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng += dlng
            
            let coord = CLLocationCoordinate2D(latitude: Double(lat) / 1e5, longitude: Double(lng) / 1e5)
            coords.append(coord)
        }
        return coords
    }
}

extension RouteRepresentation {
    init(from gmsResponse: GMSDirectionsResponse) {
        if let firstRoute = gmsResponse.routes.first {
            self.coordinates = firstRoute.overview_polyline.points.decodePolyline()
        } else {
            self.coordinates = []
        }
    }
}

