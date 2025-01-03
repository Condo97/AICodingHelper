//
//  NarrowScopeControlButton.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

struct NarrowScopeControlButton<Content: View>: View {
    
    var label: Content
    @Binding var subtitle: String?
    @Binding var hoverDescription: String
    @State var foregroundColor: Color
    @State var size: CGSize = CGSize(width: 80.0, height: 80.0)
    var action: () -> Void
    
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                foregroundColor
                
                VStack {
                    label
                        .frame(width: 28.0, height: 28.0)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .lineLimit(2)
                    }
                }
            }
            .frame(width: size.width, height: size.height)
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
        hoverDescription: .constant("Analyzes all comments."),
        foregroundColor: Colors.foreground,
        action: {
            
        }
    )
    
}
