//
//  FilePickerView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/5/24.
//

import Foundation
import SwiftUI

struct FilePickerView: View {
    
    @Binding var filePath: String?
    
    var body: some View {
        VStack {
            Text(filePath ?? "No file selected")
                .padding()
            Button("Open File") {
                openFile()
            }
        }
        .padding()
    }
    
    private func openFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK, let url = dialog.url {
            filePath = url.path
        }
    }
    
}

// Wrapper View for Previews and Testing
struct FilePickerView_Previews: PreviewProvider {
    
    static var previews: some View {
        FilePickerView(filePath: .constant(nil))
    }
    
}
