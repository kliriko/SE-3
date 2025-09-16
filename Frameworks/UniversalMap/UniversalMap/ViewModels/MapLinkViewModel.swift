//
//  MapLinkViewModel.swift
//  UniversalMap
//
//  Created by Володимир on 16.09.2025.
//

import Foundation
import SwiftUI
import MapKit
import GoogleMaps

class MapLinkViewModel: ObservableObject {
    @Published var locationManager = CLLocationManager()
    @Published var gmsMapView: GMSMapView?
    
    @Published var searchFieldText: String = ""
    @Published var selectedMapProvider: MapProvider = .mapkit
    @Published var selectedMapType: MapType = .standard
    
    @Published var cameraState: MapCameraState = .mapkitRegion(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.450001, longitude: 30.523333),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    @Published var currentCameraLatitude: Double = 50.450001
    @Published var currentCameraLongitude: Double = 30.523333
    
    @Published var displayAlert = false
    
    @Published var markers: [Point] = []
    @Published var route: RouteRepresentation?
    
    private var provider: MapProviderProtocol = MapKitProvider()
    
    init() {
        updateProvider()
    }
    
    func mapSwitch(text: String, mapType: MapType) -> some View {
        Button(action: { self.selectedMapType = mapType }) {
            Text(text)
                .padding(8)
                .background(selectedMapType == mapType ? Color.purple : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
    
    func updateProvider() {
        switch selectedMapProvider {
        case .mapkit:
            provider = MapKitProvider()
        case .gms:
            provider = GMSProvider()
        }
    }
    
    func resetCameraPosition() {
        let userLocation = locationManager.location?.coordinate
        let lat = userLocation?.latitude ?? 50.450001
        let lon = userLocation?.longitude ?? 30.523333

        currentCameraLatitude = lat
        currentCameraLongitude = lon

        switch selectedMapProvider {
        case .mapkit:
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
            )
            cameraState = .mapkitRegion(region)

        case .gms:
            if let map = gmsMapView {
                let camera = GMSCameraPosition(latitude: lat, longitude: lon, zoom: map.camera.zoom)
                map.animate(to: camera)
            }
        }
    }

    
    func performSearch(query: String) {
        provider.performSearch(query: query,
                               cameraLatitude: currentCameraLatitude,
                               cameraLongitude: currentCameraLongitude) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let points):
                    self.markers = points
                    if let first = points.first,
                       let start = self.locationManager.location?.coordinate {
                        
                        self.cameraState = .mapkitRegion(MKCoordinateRegion(
                            center: first.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))
                        
                        self.getDirections(to: first.coordinate, start: start)
                    }
                case .failure:
                    self.displayAlert = true
                }
            }
        }
    }
    
    func getDirections(to destination: CLLocationCoordinate2D, start: CLLocationCoordinate2D) {
        provider.getDirections(start: start, destination: destination) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let route):
                    self.route = route
                case .failure:
                    self.displayAlert = true
                }
            }
        }
    }
}
