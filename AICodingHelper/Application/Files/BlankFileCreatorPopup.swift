//
//  BlankFileCreatorPopup.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import SwiftUI

struct BlankFileCreatorPopup: ViewModifier {
    
    @Binding var isPresented: Bool
    @State var path: String
    
    
    @State private var newFileName: String = ""
    
    @State private var errorMessage: String = ""
    @State private var alertShowingError: Bool = false
    
    func body(content: Content) -> some View {
        content
            .alert("Create Blank File", isPresented: $isPresented) {
                TextField("File Name", text: $newFileName)
                Button("Create") {
                    createBlankFile(withName: newFileName, atPath: path)
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert(isPresented: $alertShowingError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("Done")))
            }
    }
    
    private func createBlankFile(withName name: String, atPath path: String) {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            let directoryPath = isDirectory.boolValue ? path : (path as NSString).deletingLastPathComponent
            let filePath = URL(fileURLWithPath: directoryPath).appendingPathComponent(name).path
            
            if FileManager.default.fileExists(atPath: filePath) {
                errorMessage = "File already exists at path: \(filePath)"
                alertShowingError = true
            } else {
                FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            }
        } else {
            errorMessage = "Could not find base directory when creating file: \(path)"
            alertShowingError = true
        }
    }
    
}


extension View {
    
    func blankFileCreatorPopup(isPresented: Binding<Bool>, path: String) -> some View {
        self
            .modifier(BlankFileCreatorPopup(isPresented: isPresented, path: path))
    }
    
}


#Preview {
    
    ZStack {
        
    }
    .blankFileCreatorPopup(
        isPresented: .constant(true),
        path: "~/Downloads/test_dir"
    )
    
}
