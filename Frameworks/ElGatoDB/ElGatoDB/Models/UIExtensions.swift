//
//  UIExtensions.swift
//  ElGatoDB
//
//  Created by Володимир on 11.10.2025.
//

import Foundation
import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            configuration.label
        }
    }
}
