//
//  MapBuilders.swift
//  UniversalMap
//
//  Created by Володимир on 16.09.2025.
//

import SwiftUI
import MapKit
import GoogleMaps


// MARK: - MapKit
struct MapKitMapBuilder: View {
    @ObservedObject var viewModel: MapLinkViewModel
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.450001, longitude: 30.523333),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    var body: some View {
        Map(position: $cameraPosition) {
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
        .onReceive(viewModel.$cameraState) { newState in
            if case let .mapkitRegion(region) = newState {
                cameraPosition = .region(region)
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

// MARK: - Google Maps
struct GMSMapBuilder: UIViewRepresentable {
    @ObservedObject var viewModel: MapLinkViewModel

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(latitude: viewModel.currentCameraLatitude,
                                       longitude: viewModel.currentCameraLongitude,
                                       zoom: 14)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        // Store reference in ViewModel
        viewModel.gmsMapView = mapView
        
        return mapView
    }



    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // 1️⃣ Animate camera if cameraState changed
        switch viewModel.cameraState {
        case let .gmsCamera(camera):
            // Animate only if different
            if mapView.camera.target.latitude != camera.target.latitude ||
               mapView.camera.target.longitude != camera.target.longitude ||
               mapView.camera.zoom != camera.zoom {
                mapView.animate(to: camera)
            }
        default: break
        }

        // 2️⃣ Update map type
        switch viewModel.selectedMapType {
        case .standard: mapView.mapType = .normal
        case .satelite: mapView.mapType = .satellite
        case .hybrid: mapView.mapType = .hybrid
        }

        // 3️⃣ Clear overlays before adding new ones
        mapView.clear()

        // 4️⃣ Add markers
        for markerPoint in viewModel.markers {
            let marker = GMSMarker(position: markerPoint.coordinate)
            marker.title = markerPoint.name
            marker.map = mapView
        }

        // 5️⃣ Draw route if exists
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

    class Coordinator: NSObject, GMSMapViewDelegate {
        var viewModel: MapLinkViewModel
        weak var mapView: GMSMapView?

        init(viewModel: MapLinkViewModel) {
            self.viewModel = viewModel
        }

        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            viewModel.currentCameraLatitude = position.target.latitude
            viewModel.currentCameraLongitude = position.target.longitude
        }

        // New method to center camera directly
        func centerCamera() {
            guard let mapView = mapView else { return }
            let camera = GMSCameraPosition(
                latitude: viewModel.currentCameraLatitude,
                longitude: viewModel.currentCameraLongitude,
                zoom: mapView.camera.zoom
            )
            mapView.animate(to: camera)
        }
    }

}
