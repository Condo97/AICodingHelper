//
//  WideScopeControlButton.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import SwiftUI

struct WideScopeControlButton<Content: View>: View {
    
    var label: Content
    @Binding var title: Text
    @Binding var subtitle: LocalizedStringKey?
    @Binding var hoverDescription: LocalizedStringKey
    @State var foregroundColor: Color
//    @State var size: CGSize = CGSize(width: 180.0, height: 60.0)
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
                    
                    VStack(alignment: .leading) {
                        title
                            .lineLimit(1)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .lineLimit(2)
                                .font(.system(size: 12.0, weight: .light))
                                .minimumScaleFactor(0.5)
                                .opacity(0.6)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .imageScale(.medium)
                }
            }
//            .frame(width: size.width, height: size.height)
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
        title: .constant(Text("Comment")),
        subtitle: .constant("Analyze all comments."),
        hoverDescription: .constant("Analyze all comments."),
        foregroundColor: Colors.foreground,
        action: {
            
        }
    )
    
}
