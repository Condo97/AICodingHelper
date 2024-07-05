//
//  View+FocusEffectDisabledVersionCheck.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import Foundation
import SwiftUI


extension View {
    
    @ViewBuilder
    func focusEffectDisabledVersionCheck() -> some View {
        if #available(macOS 14.0, *) {
            self
                .focusEffectDisabled()
        } else {
            self
        }
    }
    
}
