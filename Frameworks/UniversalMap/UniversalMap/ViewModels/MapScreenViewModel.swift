//
//  MapScreenViewModel.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import Foundation
import SwiftUI
import MapKit

class MapScreenViewModel: ObservableObject {
    @Published var searchFieldText: String = ""
    @Published var selectedMapProvider: MapProvider = .mapkit
    @Published var selectedMapType: MapType = .standard
    
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.450001, longitude: 30.523333),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))
    
    @Published var currentCameraLatitude: Double = 0
    @Published var currentCameraLongitude: Double = 0
    
    @Published var displayAlert = false
    
    @Published var markers: [Point] = []
    
    @ViewBuilder
    func mapSwitch(text: String, mapType: MapType) -> some View {
        Button(action: {
            self.selectedMapType = mapType
        }) {
            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedMapType == mapType ? Color.purple : Color.gray.opacity(0.2))
                .foregroundColor(selectedMapType == mapType ? .white : .black)
                .cornerRadius(8)
        }
    }
    
    func resetCameraPosition () {
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.450001, longitude: 30.523333),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    func performSearch (query: String) {
        let usCenterCoordinate = CLLocationCoordinate2D(latitude: currentCameraLatitude, longitude: currentCameraLongitude)
        let usRadius: CLLocationDistance = 50_000
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(center: usCenterCoordinate, latitudinalMeters: usRadius * 2, longitudinalMeters: usRadius * 2)
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print("Search error: \(error)")
                self.displayAlert = true
                return
            }
            guard let response = response else { return }

            let points: [Point] = response.mapItems.compactMap { item in
                guard let name = item.name else { return nil }
                return Point(name: name, coordinate: item.placemark.coordinate)
            }

            if !(0..<5).contains(points.count) {
                self.markers = []
                self.displayAlert = true
                self.resetCameraPosition()
                return
            } else {
                self.displayAlert = false
            }

            self.markers = points

            if let first = points.first {
                let region = MKCoordinateRegion(center: first.coordinate,
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                self.cameraPosition = .region(region)
                self.markers = [first]
            } else {
                self.markers = []
            }
            
            
            

            for item in response.mapItems {
                print("""
                    Name: \(item.name ?? "Unknown")
                    Locality: \(item.placemark.locality ?? "Unknown")
                    Country: \(item.placemark.country ?? "Unknown")
                    Coordinates: \(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)
                    """)
            }
        }
    }
}

