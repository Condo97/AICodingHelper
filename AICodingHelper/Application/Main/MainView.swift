//
//  MainView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

struct MainView: View {
    
    @State var directory: String = "~/Downloads/test_dir"
    
    
    @State private var selectedFile: String?
    
    
    var body: some View {
        ZStack {
            HStack {
                // File Browser
                FileSystemView(
                    directory: $directory,
                    selectedFile: $selectedFile)
                
                // Selected File
            }
            
            // Wide Scope Controls
            
            // Narrow Scope Controls
        }
        .onChange(of: selectedFile) { newValue in
            print(newValue)
        }
    }
    
}

#Preview {
    MainView()
}
