//
//  MapScreenViewModel.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import Foundation
import SwiftUI

class MapScreenViewModel: ObservableObject {
    var searchFieldText: String = ""
    var selectedMapProvider: MapProvider = .gms
    var selectedMapType: MapType = .standard
    
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
}
