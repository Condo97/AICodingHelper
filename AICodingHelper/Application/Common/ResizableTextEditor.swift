//
//  ResizableTextEditor.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/21/24.
//

import SwiftUI

struct ResizableTextEditor: View {
    
    @Binding var text: String
    @State private var textEditorHeight: CGFloat = 35 // Initial height

    var body: some View {
        TextEditor(text: $text)
            .frame(height: textEditorHeight)
            .padding(4)
            .border(Color.gray)
            .onChange(of: text) { newValue in
                updateHeight(for: newValue)
            }
            .onAppear { // Initial update on appear
                updateHeight(for: text)
            }
    }

    private func updateHeight(for text: String) {
        let maxWidth = 300.0 // Set a max width or calculate based on your view layout

        // Create an NSString for dynamic height calculation
        let nsString = text as NSString

        // Calculate the height based on the text and font
        let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let size = nsString.boundingRect(
            with: NSSize(width: maxWidth, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font]
        )

        // Updating the height
        textEditorHeight = max(35, size.height + 16) // +16 for padding (you can adjust this)
    }
    
}
