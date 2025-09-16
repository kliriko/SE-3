//
//  MapBuilders.swift
//  UniversalMap
//
//  Created by Володимир on 16.09.2025.
//

import SwiftUI
import MapKit
import GoogleMaps

struct MapKitMapBuilder: View {
    @ObservedObject var viewModel: MapLinkViewModel
    
    var body: some View {
        let cameraState = viewModel.cameraState
        
        if case let .mapkitRegion(region) = cameraState {
            Map(position: .constant(.region(region))) {
                UserAnnotation()
                
                ForEach(viewModel.markers) { point in
                    Marker(point.name, coordinate: point.coordinate)
                }
                
                if let route = viewModel.route {
                    MapPolyline(route.toMKPolyline())
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(mapStyle(for: viewModel.selectedMapType))
            .onMapCameraChange { context in
                let center = context.region.center
                viewModel.currentCameraLatitude = center.latitude
                viewModel.currentCameraLongitude = center.longitude
            }
        }
    }
    
    private func mapStyle(for type: MapType) -> MapStyle {
        switch type {
        case .satelite: return .imagery
        case .hybrid: return .hybrid
        default: return .standard
        }
    }
}

struct GMSMapBuilder: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapLinkViewModel
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(latitude: viewModel.currentCameraLatitude,
                                       longitude: viewModel.currentCameraLongitude,
                                       zoom: 14)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        if case let .gmsCamera(camera) = viewModel.cameraState {
            mapView.animate(to: camera)
        }
        
        switch viewModel.selectedMapType {
        case .standard:
            mapView.mapType = .normal
        case .satelite:
            mapView.mapType = .satellite
        case .hybrid:
            mapView.mapType = .hybrid
        }
        
        mapView.clear()

        for markerPoint in viewModel.markers {
            let marker = GMSMarker(position: markerPoint.coordinate)
            marker.title = markerPoint.name
            marker.map = mapView
        }
        
        if let route = viewModel.route {
            let path = GMSMutablePath()
            for coord in route.coordinates {
                path.add(coord)
            }
            let polyline = GMSPolyline(path: path)
            polyline.strokeColor = .blue
            polyline.strokeWidth = 5
            polyline.map = mapView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var viewModel: MapLinkViewModel
        init(viewModel: MapLinkViewModel) {
            self.viewModel = viewModel
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            viewModel.currentCameraLatitude = position.target.latitude
            viewModel.currentCameraLongitude = position.target.longitude
        }
    }
}
