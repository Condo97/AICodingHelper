//
//  CodeTabView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/29/24.
//

import SwiftUI

struct CodeTabView: View {
    
    @Binding var title: String
    @Binding var selected: Bool
    var onClose: () -> Void
    
    
    @State private var isHovering: Bool = false
    
    
    var body: some View {
        Button(action: {
            selected = true
        }) {
            VStack {
                Spacer()
                HStack {
                    // Title
                    Text(title)
                    
                    // Close Button
                    Button(action: {
                        onClose()
                    }) {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                Spacer()
            }
            .padding([.leading, .trailing])
            .background(selected ? Colors.foreground : (isHovering ? Colors.background : Colors.secondary))
            .clipShape(RoundedRectangle(cornerRadius: 2.0))
            .onHover(perform: { hovering in
                isHovering = hovering
            })
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}

//#Preview {
//    
//    CodeTabView(
//        title: .constant("Tab"),
//        open: .constant(true),
//        selected: .constant(true)
//    )
//    
//}
