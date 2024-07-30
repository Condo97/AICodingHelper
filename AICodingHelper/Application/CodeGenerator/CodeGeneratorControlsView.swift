//
//  CodeGeneratorControlsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation
import SwiftUI


struct CodeGeneratorControlsView: View {
    
    @Binding var rootFilepath: String
    @Binding var selectedFilepaths: [String]
    @ObservedObject var tabsViewModel: TabsViewModel
    var onSubmit: (_ actionType: ActionType, _ generateOptions: GenerateOptions/*TODO: , _ userInput: String?*/) -> Void
    
    
    private static let additionalPromptTitleMatchedGeometryEffectID = "additionalPromptTitle"
    private static let additionalPromptTextMatchedGeometryEffectID = "additionalPromptText"
    
    
    @Namespace private var namespace
    
    @EnvironmentObject private var focusViewModel: FocusViewModel
    
//    @State private var additionalPromptText: String = ""
    
//    @State private var additionalReferenceFilepaths: [String] = []
    
//    @State private var isDisplayingAdditionalPrompt: Bool = false
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
    
    private var multipleFilesSelected: Bool {
        selectedFilepaths.count != 1
    }
    
    
    var body: some View {
        HStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16.0) {
                    Spacer()
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        // Comment
                        CodeGeneratorControlButton(
                            label: Text("//")
                                .font(.system(size: 100.0))
                                .minimumScaleFactor(0.01),
                            title: .constant(Text("Comment").fontWeight(.medium)),
                            subtitle: .constant("Smart comments for your file\(multipleFilesSelected ? "s" : "")."),
                            hoverDescription: Binding(get: {"AI creates smart comments for your file\(multipleFilesSelected ? "s" : "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.comment, enabledGenerateOptions) })
                        
                        // Bug Fix
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.bug)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Bug Fix").fontWeight(.medium)),
                            subtitle: .constant("Smart fix bugs for your file\(multipleFilesSelected ? "s" : "")"),
                            hoverDescription: Binding(get: {"AI fixes bugs in for your file\(multipleFilesSelected ? "s" : "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.bugFix, enabledGenerateOptions) })
                        
                        // Split
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.split)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Split").fontWeight(.medium)),
                            subtitle: .constant("Split classes for your file\(multipleFilesSelected ? "s" : "")"),
                            hoverDescription: Binding(get: {"AI separates large classes and structures for your file\(multipleFilesSelected ? "s" : "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.split, enabledGenerateOptions) })
                        
                        // Simplify
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.simplify)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Simplify").fontWeight(.medium)),
                            subtitle: .constant("Simplify code for your file\(multipleFilesSelected ? "s" : "")"),
                            hoverDescription: Binding(get: {"AI simplifies complex code for your file\(multipleFilesSelected ? "s" : "")."}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.simplify, enabledGenerateOptions) })
                        
                        // Test
                        CodeGeneratorControlButton(
                            label: Image(Constants.ImageName.Actions.createTests)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Create Tests").fontWeight(.medium)),
                            subtitle: .constant("Create tests for your file\(multipleFilesSelected ? "s" : "")"),
                            hoverDescription: Binding(get: {"AI creates tests for your file\(multipleFilesSelected ? "s" : "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.createTests, enabledGenerateOptions) })
                        
                        //                        // Custom
                        CodeGeneratorControlButton(
                            label: Image(systemName: "ellipsis")
                                .symbolRenderingMode(.palette)
                                .resizable()
                                .foregroundStyle(LinearGradient(colors: [.red, .green, .blue], startPoint: .leading, endPoint: .trailing))
                                .aspectRatio(contentMode: .fit),
                            title: .constant(Text("Omni").fontWeight(.medium)),
                            subtitle: .constant("***Your prompt only***."),
                            hoverDescription: Binding(get: {"AI executes a task descirbed in your prompt for your file\(multipleFilesSelected ? "s" : "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.custom, enabledGenerateOptions) })
                    }
                    
                    // Selected Files
                    VStack(alignment: .leading) {
                        if focusViewModel.focus == .editor,
                           let openTabFilepath = tabsViewModel.openTab?.filepath as? NSString {
                            Text("Open File")
                                .bold()
                            Text(openTabFilepath.lastPathComponent)
                                .font(.subheadline)
                                .opacity(0.6)
                        } else if focusViewModel.focus == .browser {
                            Text("Selected File\(selectedFilepaths.count == 1 ? "" : "s")")
                                .bold()
                            ForEach(selectedFilepaths, id: \.self) { selectedFilepath in
                                Text((selectedFilepath as NSString).lastPathComponent)
                                    .font(.subheadline)
                                    .opacity(0.6)
                            }
                        }
                        
                        if selectedFilepaths.isEmpty {
                            Text("Nothing selected in sidebar, using entire project.")
                                .font(.subheadline)
                                .italic()
                                .opacity(0.6)
                        }
                    }
                }
//                .frame(width: 350.0)//, height: 800.0)
                //                            .padding(.bottom)
                //                            .padding([.leading, .trailing])
//                .padding()
            }
            .overlay {
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(LinearGradient(colors: [Colors.foreground, .clear], startPoint: .bottom, endPoint: .top))
                        .frame(height: 16.0)
                }
            }
        }
    }
    
}

#Preview {
    
    CodeGeneratorControlsView(
//        scope: .constant(.directory),
        rootFilepath: .constant("~/Downloads/test_dir"),
//        focusViewModel: FocusViewModel(),
        selectedFilepaths: .constant(["Test", "Test2"]),
        tabsViewModel: TabsViewModel(),
        onSubmit: { actionType, generateOptions in
            print("Submitted \(actionType)")
        }
    )
        .padding()
        .background(Colors.background)
        .frame(width: 800, height: 650)
    
}
