//
//  GrantedPermissionsDirectoryImporter.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import Foundation
import SwiftUI

struct GrantedPermissionsDirectoryImporter: ViewModifier {
    
    @Binding var isPresented: Bool
    @Binding var filepath: String
    @State var canChooseDirectories: Bool = true
    @State var canChooseFiles: Bool = false
    
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    DispatchQueue.main.async {
                        openFile()
                    
                        isPresented = false
                    }
                }
            }
    }
    
    private func openFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = canChooseDirectories
        dialog.canCreateDirectories = true
        dialog.canChooseFiles = canChooseFiles
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK, let url = dialog.url {
            filepath = url.path
        }
    }
    
}


extension View {
    
    func grantedPermissionsDirectoryImporter(isPresented: Binding<Bool>, filepath: Binding<String>, canChooseDirectories: Bool = true, canChooseFiles: Bool = false) -> some View {
        self
            .modifier(GrantedPermissionsDirectoryImporter(isPresented: isPresented, filepath: filepath, canChooseDirectories: canChooseDirectories, canChooseFiles: canChooseFiles))
    }
    
}
