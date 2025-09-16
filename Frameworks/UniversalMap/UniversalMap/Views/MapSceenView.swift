//
//  ContentView.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var viewModel: MapScreenViewModel = MapScreenViewModel()

    var body: some View {
        ZStack {
            if viewModel.selectedMapProvider == .mapkit {
                MapKitMapBuilder()
                    .onMapCameraChange { context in
                        let centerCoordinate = context.region.center
                        viewModel.currentCameraLatitude = centerCoordinate.latitude
                        viewModel.currentCameraLongitude = centerCoordinate.longitude
                        
                        print(centerCoordinate)
                    }
            } else if viewModel.selectedMapProvider == .gms {
                MapViewControllerBridge(mapType: viewModel.selectedMapType)
                    .ignoresSafeArea(edges: .all)
            }
        
            VStack {
                HStack {
                    SearchFieldWithDebounce(viewModel: viewModel)
                        .padding(.horizontal, 12)
                        .frame(width: 250, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.purple, lineWidth: 2)
                        )
                        .onChange(of: viewModel.searchFieldText) { newValue in
                            if !newValue.isEmpty {
                                viewModel.performSearch(query: newValue)
                            }
                        }
                    Button(action: {
                        viewModel.resetCameraPosition()
                    }, label: {
                        Image(systemName: "arrow.down.right.and.arrow.up.left.square")
                            .font(.system(size: 40))
                            .foregroundStyle(.purple)
                    })
                }
                
                Spacer()
                
                HStack {
                    HStack {
                        Button(action: {
                            viewModel.selectedMapProvider = .gms
                        }, label: {
                            Image(.GMS)
                                .resizable()
                                .frame(width: 40, height: 40)
                        })
                        
                        Button(action: {
                            viewModel.selectedMapProvider = .mapkit
                        }, label: {
                            Image(.mapKit)
                                .resizable()
                                .frame(width: 40, height: 40)
                        })
                    }
                    
                    Spacer()
                    
                    HStack {
                        viewModel.mapSwitch(text: "Standard", mapType: .standard)
                        viewModel.mapSwitch(text: "Satelite", mapType: .satelite)
                        viewModel.mapSwitch(text: "Hybrid", mapType: .hybrid)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Make your search more accurate", isPresented: $viewModel.displayAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The query you provided isn't specific enough")
        }
    }
    
    @ViewBuilder
    func MapKitMapBuilder() -> some View {
        switch viewModel.selectedMapType {
        case .satelite:
            Map(position: $viewModel.cameraPosition) {
                ForEach(viewModel.markers) { point in
                    Marker(point.name, coordinate: point.coordinate)
                }
            }
                .mapStyle(.imagery)
        case .hybrid:
            Map(position: $viewModel.cameraPosition) {
                ForEach(viewModel.markers) { point in
                    Marker(point.name, coordinate: point.coordinate)
                }
            }
                .mapStyle(.hybrid)
        default:
            Map(position: $viewModel.cameraPosition) {
                ForEach(viewModel.markers) { point in
                    Marker(point.name, coordinate: point.coordinate)
                }
            }
                .mapStyle(.standard)
        }
    }
        
}

#Preview {
    ContentView()
}
