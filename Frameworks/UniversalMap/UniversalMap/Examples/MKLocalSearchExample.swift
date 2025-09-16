//import MapKit
//
//let usCenterCoordinate = CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795)
//let usRadius: CLLocationDistance = 2_500_000 // Radius in meters
//let request = MKLocalSearch.Request()
//request.naturalLanguageQuery = "Springfield"
//request.region = MKCoordinateRegion(center: usCenterCoordinate, latitudinalMeters: usRadius * 2, longitudinalMeters: usRadius * 2)
//request.resultTypes = .pointOfInterest
//
//let search = MKLocalSearch(request: request)
//search.start { (response, error) in
//    if let error = error {
//        print("Search error: \(error)")
//    } else if let response = response {
//        for item in response.mapItems {
//            print("""
//                Name: \(item.name ?? "Unknown")
//                Locality: \(item.placemark.locality ?? "Unknown")
//                Country: \(item.placemark.country ?? "Unknown")
//                Coordinates: \(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)
//                """)
//        }
//    }
//}
