//
//  AIFileCreatorView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/7/24.
//

import SwiftUI

struct AIFileCreatorView: View {
    
    @Binding var newFileName: String
    @Binding var referenceFilepaths: [String]
    @Binding var userPrompt: String
    var onCancel: () -> Void
    var onSubmit: () -> Void
    
    @State private var isFileImporterPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Create AI File")
                .font(.title)
                .fontWeight(.bold)
            
            // File Name
            VStack(alignment: .leading, spacing: 8) {
                Text("File Name")
                    .font(.headline)
                TextField("Enter file name", text: $newFileName)
            }
            
            // Reference Files
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Reference Files")
                        .font(.headline)
                    
                    Button(action: {
                        isFileImporterPresented = true
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(referenceFilepaths, id: \.self) { path in
                            HStack {
                                Text(path.components(separatedBy: "/").last ?? "")
                                Image(systemName: "xmark.circle")
                                    .onTapGesture {
                                        if let index = referenceFilepaths.firstIndex(of: path) {
                                            referenceFilepaths.remove(at: index)
                                        }
                                    }
                            }
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            // User Prompt
            VStack(alignment: .leading, spacing: 8) {
                Text("User Prompt")
                    .font(.headline)
                TextEditor(text: $userPrompt)
                    .frame(height: 100)
                    .scrollContentBackground(.hidden)
                    .padding()
                    .background(Colors.secondary.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
            
            // Cancel and Submit
            HStack {
                Spacer()
                
                Button(action: onCancel) {
                    Text("Cancel")
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing])
                        .cornerRadius(8)
                }
                .keyboardShortcut(.cancelAction)
                
                Button(action: onSubmit) {
                    Text("Submit")
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing])
                        .cornerRadius(8)
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.vertical, 8)
        }
        .padding()
        .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.plainText], allowsMultipleSelection: true) { result in
            do {
                let selectedFiles = try result.get()
                let paths = selectedFiles.map { $0.path }
                referenceFilepaths.append(contentsOf: paths)
            } catch {
                print("Error selecting files: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    
    ZStack {
        AIFileCreatorView(
            newFileName: .constant(""),
            referenceFilepaths: .constant([]),
            userPrompt: .constant(""),
            onCancel: {},
            onSubmit: {}
        )
        .padding()
    }
    .background(Color.white)
    .frame(width: 550.0, height: 500.0)
}
