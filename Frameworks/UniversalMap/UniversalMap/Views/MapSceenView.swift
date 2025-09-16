//
//  ContentView.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import SwiftUI
import MapKit
import GoogleMaps

struct ContentView: View {
    @StateObject var viewModel = MapLinkViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.selectedMapProvider == .mapkit {
                MapKitMapBuilder(viewModel: viewModel)
            } else {
                GMSMapBuilder(viewModel: viewModel)
                    .ignoresSafeArea(edges: .all)
            }
            
            VStack {
                HStack {
                    SearchFieldWithDebounce(viewModel: viewModel)
                        .frame(width: 250, height: 50)
                        .padding(Edge.Set.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple, lineWidth: 2))
                        .onChange(of: viewModel.searchFieldText) { newValue in
                            if !newValue.isEmpty {
                                viewModel.performSearch(query: newValue)
                            }
                        }
                    
                    Button(action: {
                        viewModel.resetCameraPosition()
                    }) {
                        Image(systemName: "arrow.down.right.and.arrow.up.left.square")
                            .font(.system(size: 40))
                            .foregroundStyle(.purple)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Spacer()
                
                HStack {
                    Button(action: { viewModel.selectedMapProvider = .gms }) {
                        Image(.GMS).resizable().frame(width: 40, height: 40)
                    }
                    Button(action: { viewModel.selectedMapProvider = .mapkit }) {
                        Image(.mapKit).resizable().frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    viewModel.mapSwitch(text: "Standard", mapType: .standard)
                    viewModel.mapSwitch(text: "Satellite", mapType: .satelite)
                    viewModel.mapSwitch(text: "Hybrid", mapType: .hybrid)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Make your search more accurate", isPresented: $viewModel.displayAlert) {
            Button("OK", role: .cancel) { }
        }
        .onAppear {
            viewModel.locationManager.requestWhenInUseAuthorization()
        }
    }
}
