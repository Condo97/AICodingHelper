//
//  CodeGeneratorOverlayView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/22/24.
//

import SwiftUI


struct CodeGeneratorOverlayView<Content: View>: View {
    
    @ViewBuilder var content: Content
    
    
    @State private var isDisplayingControls: Bool = false
    
    
    var body: some View {
        VStack(alignment: .trailing) {
            // Controls
            if isDisplayingControls {
                VStack(alignment: .trailing, spacing: 0.0) {
                    content
                    
                    // Triangle for popup
                    Image(systemName: "triangle.fill")
                        .resizable()
                        .frame(width: 60.0, height: 28.0)
                        .rotationEffect(.degrees(180))
                        .padding(.top, -8)
                        .padding(.trailing, 4)
                        .foregroundStyle(Colors.foreground)
                        .zIndex(-1.0) // Move to the back so that it does not cast a shadow on te controls container
                }
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
            
            // Show and Hide Controls Button
            Button(action: {
                withAnimation(.bouncy(duration: 0.28)) {
                    isDisplayingControls.toggle()
                }
            }) {
                Image(systemName: "doc.fill.badge.ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40.0, height: 40.0)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(Colors.foreground)
            .clipShape(Circle())
            .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
        }
    }
    
}
