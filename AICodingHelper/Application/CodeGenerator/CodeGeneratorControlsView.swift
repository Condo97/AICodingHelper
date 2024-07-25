//
//  CodeGeneratorControlsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation
import SwiftUI


struct CodeGeneratorControlsView: View {
    
    @Binding var scope: Scope
    @Binding var rootFilepath: String
    @ObservedObject var focusViewModel: FocusViewModel
    @Binding var selectedFilepaths: [String]
    var onSubmit: (_ actionType: ActionType, _ userInput: String,  _ referenceFilepaths: [String], _ generateOptions: GenerateOptions/*TODO: , _ userInput: String?*/) -> Void
    
    
    private static let additionalPromptTitleMatchedGeometryEffectID = "additionalPromptTitle"
    private static let additionalPromptTextMatchedGeometryEffectID = "additionalPromptText"
    
    
    @Namespace private var namespace
    
    @State private var additionalPromptText: String = ""
    
    @State private var additionalReferenceFilepaths: [String] = []
    
    @State private var isDisplayingAdditionalPrompt: Bool = false
    @State private var isDisplayingControls: Bool = false
    
    @State private var isShowingAddAdditionalReferenceFileOrFolderDirectoryImporter: Bool = false
    @State private var addAdditionalReferenceFileOrFolderFilepath: String = ""
    
    @State private var isLoadingDiscussion: Bool = false
    
    private var generateOptionCopyCurrentFilesToTempFile: Binding<Bool> { BindingUserDefaultsHelper.generateOptionCopyCurrentFilesToTempFile }
    private var generateOptionUseEntireProjectAsContext: Binding<Bool> { BindingUserDefaultsHelper.generateOptionUseEntireProjectAsContext }
    
    
    private var enabledGenerateOptions: GenerateOptions {
        var generateOptions: GenerateOptions = []
        
        if generateOptionCopyCurrentFilesToTempFile.wrappedValue {
            generateOptions.insert(.copyCurrentFilesToTempFiles)
        }
        
        if generateOptionUseEntireProjectAsContext.wrappedValue {
            generateOptions.insert(.useEntireProjectAsContext)
        }
        
        return generateOptions
    }
    
    
    var body: some View {
        HStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16.0) {
                    Text("AI Task")
                        .font(.title)
                        .bold()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        // Comment
                        CodeGeneratorControlButton(
                            label: Text("//")
                                .font(.system(size: 100.0))
                                .minimumScaleFactor(0.01),
                            title: .constant(Text("Comment").fontWeight(.medium)),
                            subtitle: .constant("Smart comments \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized.lowercased())."),
                            hoverDescription: Binding(get: {"AI creates smart comments \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized)"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.comment, additionalPromptText, selectedFilepaths + additionalReferenceFilepaths, enabledGenerateOptions) })
                        
                        // Bug Fix
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.bug)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Bug Fix").fontWeight(.medium)),
                            subtitle: .constant("Smart fix bugs \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized.lowercased())"),
                            hoverDescription: Binding(get: {"AI fixes bugs in \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized)"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.bugFix, additionalPromptText, selectedFilepaths + additionalReferenceFilepaths, enabledGenerateOptions) })
                        
                        // Split
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.split)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Split").fontWeight(.medium)),
                            subtitle: .constant("Split classes \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized.lowercased())"),
                            hoverDescription: Binding(get: {"AI separates large classes and structures \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized)"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.split, additionalPromptText, selectedFilepaths + additionalReferenceFilepaths, enabledGenerateOptions) })
                        
                        // Simplify
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.simplify)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Simplify").fontWeight(.medium)),
                            subtitle: .constant("Simplify code \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized.lowercased())"),
                            hoverDescription: Binding(get: {"AI simplifies complex code \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized)."}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.simplify, additionalPromptText, selectedFilepaths + additionalReferenceFilepaths, enabledGenerateOptions) })
                        
                        // Test
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.createTests)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Create Tests").fontWeight(.medium)),
                            subtitle: .constant("Create tests  \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized.lowercased())"),
                            hoverDescription: Binding(get: {"AI creates tests \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized)"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.createTests, additionalPromptText, selectedFilepaths + additionalReferenceFilepaths, enabledGenerateOptions) })
                        
                        //                        // Custom
                        CodeGeneratorControlButton(
                            label: Image(systemName: "ellipsis")
                                .symbolRenderingMode(.palette)
                                .resizable()
                                .foregroundStyle(LinearGradient(colors: [.red, .green, .blue], startPoint: .leading, endPoint: .trailing))
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Omni").fontWeight(.medium)),
                            subtitle: .constant("***Your prompt only*** \(focusViewModel.focus == .editor ? "in Current " : "")\(scope.name.capitalized.lowercased())."),
                            hoverDescription: Binding(get: {"AI executes a task descirbed \(focusViewModel.focus == .editor ? "in Current " : "for your ")\(scope.name.capitalized)"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.custom, additionalPromptText, selectedFilepaths + additionalReferenceFilepaths, enabledGenerateOptions) })
                    }
                    
                    // Additional Prompt Entry or Popup or Show Button or Something
                    if !isDisplayingAdditionalPrompt {
                        Text("Additional Prompt")
                            .bold()
                        ZStack {
                            TextField("Type Prompt...", text: $additionalPromptText, axis: .vertical)
                                .frame(height: 100.0, alignment: .top)
                                .textFieldStyle(.plain)
                                .padding(4)
                                .background(Color.background.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 2.0))
                            //                                    TextEditor(text: $additionalPromptText)
                            //                                        .frame(height: 100)
                            //                                        .scrollContentBackground(.hidden)
                            //                                        .padding()
                            //                                        .background(Color.background.opacity(0.1))
                            //                                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            
                            HStack {
                                Spacer()
                                VStack {
                                    Spacer()
                                    Button(action: {
                                        withAnimation(.bouncy(duration: 0.28)) {
                                            isDisplayingAdditionalPrompt = true
                                        }
                                    }) {
                                        VStack {
                                            Text("Expand \(Image(systemName: "chevron.right"))")
                                                .matchedGeometryEffect(id: CodeGeneratorControlsView.additionalPromptTitleMatchedGeometryEffectID, in: namespace)
                                        }
                                    }
                                    .padding(8)
                                }
                            }
                        }
                    }
                    
                    // Selected and Additional Reference Files
                    VStack(alignment: .leading) {
                        Text("Selected Filepaths")
                            .bold()
                        ForEach(selectedFilepaths, id: \.self) { selectedFilepath in
                            Text((selectedFilepath as NSString).lastPathComponent)
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                        if selectedFilepaths.isEmpty {
                            Text("Nothing selected in sidebar.")
                                .font(.subheadline)
                                .italic()
                                .opacity(0.6)
                        }
                        
                        Text("Additional Filepaths")
                            .bold()
                            .padding(.top, 2)
                        ForEach(additionalReferenceFilepaths, id: \.self) { additionalReferenceFilepath in
                            HStack {
                                Button("\(Image(systemName: "xmark"))") {
                                    additionalReferenceFilepaths.removeAll(where: {$0 == additionalReferenceFilepath})
                                }
                                
                                Text((additionalReferenceFilepath as NSString).lastPathComponent)
                                    .font(.subheadline)
                                    .opacity(0.6)
                            }
                        }
                        Button("\(Image(systemName: "plus")) Add Reference Files or Folders") {
                            isShowingAddAdditionalReferenceFileOrFolderDirectoryImporter = true
                        }
                    }
                    
                    Divider()
                        .padding(8)
                    
//                    // Create temporary files instead of rewriting TODO: Add option to NarrowScopeControlsView
//                    CodeGeneratorControlSwitch(
//                        isOn: generateOptionCopyCurrentFilesToTempFile,
//                        title: .constant(Text("Save to Temp File")),
//                        subtitle: generateOptionCopyCurrentFilesToTempFile.wrappedValue ? .constant(Text("Will not overwrite your files.")) : .constant(Text("***Will overwrite***").foregroundColor(Color(NSColor.systemRed)) + Text(" your files.")),
//                        hoverDescription: .constant("Use all files to give AI more context to what it is coding."),
//                        foregroundColor: .foreground)
//                    .offset(x: -8)
                    
                    //                                // Use entire project as context TODO: Maybe make this a three option switch where it can either be no added context, selected files as context, project as context.. TODO: Add option to NarrowScopeControlsView
                    //                                CodeGeneratorControlSwitch(
                    //                                    isOn: generateOptionUseEntireProjectAsContext,
                    //                                    title: .constant(Text("Project as Context")),
                    //                                    subtitle: generateOptionUseEntireProjectAsContext.wrappedValue ? .constant(Text("More accuracy and cost.")) : .constant(Text("Let AI see your entire project. May increase cost.")),
                    //                                    hoverDescription: .constant("Use all files to give AI more context to what it is coding."),
                    //                                    foregroundColor: .foreground)
                    //                                .offset(x: -8)
                    
                    // TODO: Add files to directory
                    
                    
                    
                    Spacer()
                }
                .frame(width: 350.0)//, height: 800.0)
                //                            .padding(.bottom)
                //                            .padding([.leading, .trailing])
                .padding()
            }
            .overlay {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [Colors.foreground, .clear], startPoint: .bottom, endPoint: .top))
                        .frame(height: 16.0)
                }
            }
            
            if isDisplayingAdditionalPrompt {
                Divider()
                
                VStack(alignment: .leading) {
                    // Title
                    Text("Additional Prompt")
                        .font(.system(size: 17.0, weight: .medium))
                        .padding(.top)
                    //                                    .matchedGeometryEffect(id: CodeGeneratorControlsView.additionalPromptTitleMatchedGeometryEffectID, in: namespace)
                    
                    // Text
                    TextEditor(text: $additionalPromptText)
                        .padding()
                        .scrollContentBackground(.hidden)
                        .background(Color.background.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    //                                    .matchedGeometryEffect(id: CodeGeneratorControlsView.additionalPromptTextMatchedGeometryEffectID, in: namespace)
                    
                    // Hide Button
                    Button(action: {
                        withAnimation(.bouncy(duration: 0.28)) {
                            isDisplayingAdditionalPrompt = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("\(Image(systemName: "chevron.left")) Hide")
                            Spacer()
                        }
                        .padding(8)
                    }
                }
                .frame(width: 320.0)
                .padding(.bottom)
            }
        }
        .grantedPermissionsDirectoryImporter(
            isPresented: $isShowingAddAdditionalReferenceFileOrFolderDirectoryImporter,
            filepath: $addAdditionalReferenceFileOrFolderFilepath)
        .onChange(of: addAdditionalReferenceFileOrFolderFilepath) { newValue in
            if !newValue.isEmpty,
               !additionalReferenceFilepaths.contains(newValue) {
                additionalReferenceFilepaths.append(newValue)
            }
        }
    }
    
}

#Preview {
    
    CodeGeneratorControlsView(
        scope: .constant(.directory),
        rootFilepath: .constant("~/Downloads/test_dir"),
        focusViewModel: FocusViewModel(),
        selectedFilepaths: .constant(["Test", "Test2"]),
        onSubmit: { actionType, userInput, referenceFilepaths, generateOptions in
            print("Submitted \(actionType)")
        }
    )
        .padding()
        .background(Colors.background)
        .frame(width: 800, height: 650)
    
}
