//
//  ContentView.swift
//  UniversalMap
//
//  Created by Володимир on 10.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: MapScreenViewModel = MapScreenViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("Search", text: $viewModel.searchFieldText)
                        .padding(.horizontal, 12)
                        .frame(width: 250, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.purple, lineWidth: 2)
                        )
                    
                    Button(action: {
                        
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
    }
}

#Preview {
    ContentView()
}
