//
//  Fader.swift
//  QKnobs
//
//  Created by Володимир on 25.09.2025.
//

import SwiftUI

public struct QFader: View {
    @StateObject private var vm = QFaderViewModel()
    
    public init() {
        
    }
    
    public init (handleWidth: Double = 30, handleHeight: Double = 50) {
        vm.handleHeight = handleHeight
        vm.handleWidth = handleWidth
    }
    
    public var body: some View {
        GeometryReader { geo in
            let trackHeight = geo.size.height
            let travel = (trackHeight / 2 - vm.handleHeight / 2)
            
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: vm.handleWidth, height: vm.handleHeight)
                    .offset(y: vm.offsetY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                vm.handleDragGesture(value: value, travel: travel)
                            }
                            .onEnded { _ in
                                vm.handleDragEnd(travel: travel)
                            }
                    )
                    .animation(.easeInOut(duration: 0.2), value: vm.offsetY)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    VStack {
        QFader()
    }
    .frame(width: 50, height: 100)
}
