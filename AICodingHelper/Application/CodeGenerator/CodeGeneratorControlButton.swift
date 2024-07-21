//
//  CodeGeneratorControlButton.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import SwiftUI

struct CodeGeneratorControlButton<Content: View>: View {
    
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
                
                VStack {
                    label
                        .frame(width: 28.0, height: 28.0)
                        .padding(4)
                    
                    title
                        .lineLimit(1)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .lineLimit(2)
//                            .font(.system(size: 10.0))
                            .font(.footnote)
                            .opacity(0.6)
                            .frame(height: 38.0, alignment: .top)
                    }
                    
//                    Spacer()
//                    
//                    Image(systemName: "chevron.right")
//                        .imageScale(.medium)
                }
                .padding(4)
            }
//            .frame(width: size.width, height: size.height)
        }
//        .buttonStyle(PlainButtonStyle())
        .help(hoverDescription)
    }
    
}

#Preview {
    
    CodeGeneratorControlButton(
        label: Text("//")
            .font(.system(size: 100.0))
            .minimumScaleFactor(0.01),
        title: .constant(Text("Comment")),
        subtitle: .constant("Analyze all comments and stuff this should be two lines.."),
        hoverDescription: .constant("Analyze all comments."),
        foregroundColor: Colors.foreground,
        action: {
            
        }
    )
    
}
