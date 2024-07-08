//
//  AIProjectCreatorPopup.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import SwiftUI

struct AIProjectCreatorPopup: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var baseFilepath: String
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                AIProjectCreatorContainer(
                    isPresented: $isPresented,
                    baseFilepath: $baseFilepath)
            }
    }
    
}


extension View {
    
    func aiProjectCreatorPopup(isPresented: Binding<Bool>, baseFilepath: Binding<String>) -> some View {
        self
            .modifier(AIProjectCreatorPopup(isPresented: isPresented, baseFilepath: baseFilepath))
    }
    
}
