//
//  UniversalMapService.swift
//  L2_project
//
//  Created by Ihor Malovanyi on 17.10.2022.
//

import MapKit
#if canImport(GoogleMaps)
import GoogleMaps
#endif

protocol UniversalMapServiceDelegate: AnyObject {
    
    func mapView(_ mapView: UniversalMapProvider, didLongPressAt coordinate: CLLocationCoordinate2D)
    
}

final class UniversalMapService: NSObject {
    
    weak var delegate: UniversalMapServiceDelegate?
    
    private(set) var container = UIView()
    private(set) var mapView: UniversalMapProvider!
    
    init(_ defaultType: UniversalMapProvider.Type = MKMapView.self) {
        super.init()
        switchProvider(to: defaultType)
    }
    
    func switchProvider(to provider: UniversalMapProvider.Type) {
        let lastConfiguration = mapView?.universalMapConfiguration
        
        container.subviews.forEach { $0.removeFromSuperview() }
        mapView = provider.init()
        
        if let lastConfiguration {
            mapView.universalMapConfiguration = lastConfiguration
        }
        
        if let mapView = mapView as? UIView {
            container.addSubview(mapView)
            mapView.frame = container.bounds
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            if self.mapView.needLongPressGesture {
                mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(tapOnMap)))
            } else {
                (mapView as? GMSMapView)?.delegate = self
            }
        }
    }
    
    func switchMapType(to type: Configuration.MapType) {
        mapView.universalMapConfiguration.mapType = type
    }
    
    func addPin(with title: String, to coordinate: CLLocationCoordinate2D) {
        mapView.addPin(with: title, to: coordinate)
    }
    
    struct Configuration {
        
        enum MapType: Int {
            
            case normal
            case satellite
            case hybrid
            
        }
        
        var mapType: MapType = .normal
        
    }
    
    @objc private func tapOnMap(_ recognizer: UILongPressGestureRecognizer) {
        guard let mapView = mapView as? MKMapView else { return }
        guard recognizer.state == .ended else { return }
        
        let touchLocation = recognizer.location(in: mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        delegate?.mapView(mapView, didLongPressAt: coordinate)
    }
    
}

extension UniversalMapService: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        delegate?.mapView(mapView, didLongPressAt: coordinate)
    }
    
}
