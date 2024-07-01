//
//  WideScopeControlButton.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import SwiftUI

struct WideScopeControlButton<Content: View>: View {
    
    var label: Content
    @Binding var subtitle: String?
    @Binding var hoverDescription: String
    @State var foregroundColor: Color
    @State var size: CGSize = CGSize(width: 180.0, height: 60.0)
    var action: () -> Void
    
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                foregroundColor
                
                HStack {
                    label
                        .frame(width: 28.0, height: 28.0)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .buttonStyle(PlainButtonStyle())
        .help(hoverDescription)
    }
    
}

#Preview {
    
    WideScopeControlButton(
        label: Text("//")
            .font(.system(size: 100.0))
            .minimumScaleFactor(0.01),
        subtitle: .constant("Comment"),
        hoverDescription: .constant("Analyze all comments."),
        foregroundColor: Colors.foreground,
        action: {
            
        }
    )
    
}
