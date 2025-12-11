//
//  QFaderViewModel.swift
//  QKnobs
//
//  Created by Володимир on 25.09.2025.
//

import Foundation
import Combine
import SwiftUI

class QFaderViewModel: ObservableObject {
    @Published var offsetY: CGFloat = 0
    @Published private var lastOffsetY: CGFloat = 0.0
    
    //in percentage
    var relativePosition: Double = 0.5
    
    private let centerThresholdPercent: Double
    private var enableSnapping: Bool
    
    var handleWidth: CGFloat = 30
    var handleHeight: CGFloat = 50
    
    public init(defaultPosition: Double = 0.5, enableSnapping: Bool = true) {
        self.centerThresholdPercent = defaultPosition
        self.enableSnapping = enableSnapping
    }
    
    public func handleDragGesture(value: DragGesture.Value, travel: CGFloat) {
        let newOffset = lastOffsetY + value.translation.height
        
        let minOffset = -travel
        let maxOffset = travel
        
        offsetY = min(max(newOffset, minOffset), maxOffset)
        
        // Update normalized value live
        let normalized = (travel - offsetY) / (2 * travel)
        relativePosition = Double(normalized)
        print("Value:", relativePosition)
    }
    
    public func handleDragEnd(travel: CGFloat) {
        if enableSnapping {
            let threshold = travel * centerThresholdPercent
            if abs(offsetY) < threshold {
                offsetY = 0
                relativePosition = 0.5
                print("Snapped to center")
            }
        }
        lastOffsetY = offsetY
    }
}
