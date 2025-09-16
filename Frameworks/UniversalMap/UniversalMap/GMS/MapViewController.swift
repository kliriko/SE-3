// Copyright 2021 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  MapViewController.swift
//  GoogleMapsSwiftUI
//
//  Created by Chris Arriola on 2/4/21.
//

import GoogleMaps
import UIKit

class MapViewController: UIViewController {

  let map: GMSMapView
  var isAnimating: Bool = false

  init(mapType: MapType) {
    self.map = GMSMapView(frame: .zero)
    super.init(nibName: nil, bundle: nil)
    updateMapType(mapType)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    super.loadView()
    self.view = map
  }

  func updateMapType(_ mapType: MapType) {
    switch mapType {
    case .standard:
      map.mapType = .normal
    case .satelite:
      map.mapType = .satellite
    case .hybrid:
      map.mapType = .hybrid
    }
  }
}
