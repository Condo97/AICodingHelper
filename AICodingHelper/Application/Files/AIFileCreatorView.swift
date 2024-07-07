//
//  AIFileCreatorView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import SwiftUI

struct AIFileCreatorView: View {
    
    var body: some View {
        VStack {
            // Title
            Text("Create AI File")
            
            // File Name - A binding text field for the user to enter the name of the file
            
            // Reference Files and Add Reference File - Shown as a side scrolling view it displays the filepaths' last path component which is the file name. This will be fed by a binding of filepaths which are the full filepaths for the files. You will also need to add the ability to add files from the user's file browser which will import the full filepaths into the binding and therefore update this view automatically.
            
            // User Prompt - An additional binding TextEditor that is larger and allows for the user to enter in the functionality to prompt GPT with when creating the file
            
            // Cancel and Submit - Both just call blank actions
        }
    }
    
}

#Preview {
    
    ZStack {
        AIFileCreatorView()
            .background(Colors.foreground)
    }
    .frame(width: 550.0, height: 500.0)
    
}
