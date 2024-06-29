//
//  NarrowScopeControlButton.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

struct NarrowScopeControlButton<Content: View>: View {
    
    var label: Content
    @Binding var subtitle: String
    @Binding var hoverDescription: String
    var action: () -> Void
    
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack {
                label
                    .frame(width: 28.0, height: 28.0)
                
                Text(subtitle)
                    .lineLimit(2)
            }
            .frame(width: 80.0, height: 80.0)
        }
        .buttonStyle(PlainButtonStyle())
        .help(hoverDescription)
    }
    
}

#Preview {
    
    NarrowScopeControlButton(
        label: Text("//")
            .font(.system(size: 100.0))
            .minimumScaleFactor(0.01),
        subtitle: .constant("Comment"),
        hoverDescription: .constant("Analyzes all comments"),
        action: {
            
        }
    )
    
}
