//
//  FolderCreatorPopup.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import SwiftUI

struct FolderCreatorPopup: ViewModifier {
    
    @Binding var isPresented: Bool
    @State var path: String
    
    
    @State private var newFolderName: String = ""
    
    @State private var errorMessage: String = ""
    @State private var alertShowingError: Bool = false
    
    
    func body(content: Content) -> some View {
        content
            .alert("Create Folder", isPresented: $isPresented) {
                TextField("Folder Name", text: $newFolderName)
                Button("Create") {
                    createFolder(withName: newFolderName, atPath: path)
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert(isPresented: $alertShowingError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("Done")))
            }
    }
    
    
    private func createFolder(withName name: String, atPath path: String) {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) {
            let directoryPath = isDirectory.boolValue ? path : (path as NSString).deletingLastPathComponent
            let folderPath = URL(fileURLWithPath: directoryPath).appendingPathComponent(name).path
            
            if FileManager.default.fileExists(atPath: folderPath) {
                errorMessage = "Folder already exists at path: \(folderPath)"
                alertShowingError = true
            } else {
                do {
                    try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    errorMessage = "Error creating folder: \(error)"
                    alertShowingError = true
                }
            }
        } else {
            errorMessage = "Could not find base directory when creating folder: \(path)"
            alertShowingError = true
        }
    }
    
}


extension View {
    
    func folderCreatorPopup(isPresented: Binding<Bool>, path: String) -> some View {
        self
            .modifier(FolderCreatorPopup(isPresented: isPresented, path: path))
    }
    
}



#Preview {
    
    ZStack {
        
    }
    .folderCreatorPopup(isPresented: .constant(true), path: "~/Downloads/test_dir")
    
}
