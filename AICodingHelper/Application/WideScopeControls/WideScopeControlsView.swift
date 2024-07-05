//
//  WideScopeControlsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import Foundation
import SwiftUI


struct WideScopeControlsView: View {
    
    @Binding var scope: Scope
    @ObservedObject var focusViewModel: FocusViewModel
    @Binding var selectedFilepaths: [String]
    var onSubmit: (_ actionType: ActionType, _ userInput: String, _ generateOptions: GenerateOptions/*TODO: , _ userInput: String?*/) -> Void
    
    
    private static let additionalPromptTitleMatchedGeometryEffectID = "additionalPromptTitle"
    private static let additionalPromptTextMatchedGeometryEffectID = "additionalPromptText"
    
    
    @Namespace private var namespace
    
    @State private var additionalPromptText: String = ""
    
    @State private var isDisplayingAdditionalPrompt: Bool = false
    @State private var isDisplayingControls: Bool = false
    
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
        VStack(alignment: .trailing) {
            // Controls
            if isDisplayingControls {
                VStack(alignment: .trailing, spacing: 0.0) {
                    HStack {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0.0) {
                                // Comment
                                WideScopeControlButton(
                                    label: Text("//")
                                        .font(.system(size: 100.0))
                                        .minimumScaleFactor(0.01),
                                    title: .constant(Text("Comment").fontWeight(.medium) + Text(" \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)")),
                                    subtitle: .constant("AI comments your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized.lowercased())"),
                                    hoverDescription: Binding(get: {"AI comments your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)"}, set: {_ in}),
                                    foregroundColor: .foreground,
                                    action: { onSubmit(.comment, additionalPromptText, enabledGenerateOptions) })
                                
                                // Bug Fix
                                WideScopeControlButton(
                                    label: Image(Constants.ImageName.Actions.bug)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit),
                                    title: .constant(Text("Bug Fix").fontWeight(.medium) + Text(" \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)")),
                                    subtitle: .constant("AI finds and fixes bugs in your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized.lowercased())"),
                                    hoverDescription: Binding(get: {"AI fixes bugs in your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)"}, set: {_ in}),
                                    foregroundColor: .foreground,
                                    action: { onSubmit(.bugFix, additionalPromptText, enabledGenerateOptions) })
                                
                                // Split
                                WideScopeControlButton(
                                    label: Image(Constants.ImageName.Actions.split)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit),
                                    title: .constant(Text("Split").fontWeight(.medium) + Text(" \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)")),
                                    subtitle: .constant("AI splits classes and structures in your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized.lowercased())"),
                                    hoverDescription: Binding(get: {"AI separates your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)"}, set: {_ in}),
                                    foregroundColor: .foreground,
                                    action: { onSubmit(.split, additionalPromptText, enabledGenerateOptions) })
                                
                                // Simplify
                                WideScopeControlButton(
                                    label: Image(Constants.ImageName.Actions.simplify)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit),
                                    title: .constant(Text("Simplify").fontWeight(.medium) + Text(" \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)")),
                                    subtitle: .constant("AI simplifies complex code in your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized.lowercased())"),
                                    hoverDescription: Binding(get: {"AI simplifies your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)."}, set: {_ in}),
                                    foregroundColor: .foreground,
                                    action: { onSubmit(.simplify, additionalPromptText, enabledGenerateOptions) })
                                
                                // Test
                                WideScopeControlButton(
                                    label: Image(Constants.ImageName.Actions.createTests)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit),
                                    title: .constant(Text("Create Tests").fontWeight(.medium) + Text(" for \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)")),
                                    subtitle: .constant("AI creates tests for code in your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized.lowercased())"),
                                    hoverDescription: Binding(get: {"AI creates tests for your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)"}, set: {_ in}),
                                    foregroundColor: .foreground,
                                    action: { onSubmit(.createTests, additionalPromptText, enabledGenerateOptions) })
                                
                                //                        // Custom
                                WideScopeControlButton(
                                    label: Image(systemName: "questionmark.app")
                                        .resizable(),
                                    title: .constant(Text("Omni").fontWeight(.medium) + Text(" for \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)")),
                                    subtitle: .constant("AI executes a task described by your *Additional Prompt* in your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized.lowercased())."),
                                    hoverDescription: Binding(get: {"AI executes a task descirbed by your \(focusViewModel.focus == .editor ? "Current " : "")\(scope.name.capitalized)"}, set: {_ in}),
                                    foregroundColor: .foreground,
                                    action: { onSubmit(.custom, additionalPromptText, enabledGenerateOptions) })
                                
                                // Additional Prompt Entry or Popup or Show Button or Something
                                if !isDisplayingAdditionalPrompt {
                                    Button(action: {
                                        withAnimation(.bouncy(duration: 0.28)) {
                                            isDisplayingAdditionalPrompt = true
                                        }
                                    }) {
                                        HStack {
                                            Spacer()
                                            VStack {
                                                Text("Additional Prompt")
                                                    .fontWeight(.medium)
                                                    .matchedGeometryEffect(id: WideScopeControlsView.additionalPromptTitleMatchedGeometryEffectID, in: namespace)
                                                Text(additionalPromptText.isEmpty ? "No Additional Prompt" : additionalPromptText)
                                                    .font(.system(size: 10.0))
                                                    .opacity(0.6)
                                                    .matchedGeometryEffect(id: WideScopeControlsView.additionalPromptTextMatchedGeometryEffectID, in: namespace)
                                            }
                                            .padding(8)
                                            Spacer()
                                        }
                                    }
                                    .padding(.top, 8)
                                    //                                .buttonStyle(PlainButtonStyle())
                                }
                                
                                Divider()
                                    .padding(8)
                                
                                // Create temporary files instead of rewriting TODO: Add option to NarrowScopeControlsView
                                WideScopeControlSwitch(
                                    isOn: generateOptionCopyCurrentFilesToTempFile,
                                    title: .constant(Text("Save to Temp File")),
                                    subtitle: generateOptionCopyCurrentFilesToTempFile.wrappedValue ? .constant(Text("Will not overwrite your files.")) : .constant(Text("***Will overwrite***").foregroundColor(Color(NSColor.systemRed)) + Text(" your files.")),
                                    hoverDescription: .constant("Use all files to give AI more context to what it is coding."),
                                    foregroundColor: .foreground)
                                .offset(x: -8)
                                
                                // Use entire project as context TODO: Maybe make this a three option switch where it can either be no added context, selected files as context, project as context.. TODO: Add option to NarrowScopeControlsView
                                WideScopeControlSwitch(
                                    isOn: generateOptionUseEntireProjectAsContext,
                                    title: .constant(Text("Project as Context")),
                                    subtitle: generateOptionUseEntireProjectAsContext.wrappedValue ? .constant(Text("More accuracy and cost.")) : .constant(Text("Let AI see your entire project. May increase cost.")),
                                    hoverDescription: .constant("Use all files to give AI more context to what it is coding."),
                                    foregroundColor: .foreground)
                                .offset(x: -8)
                                
                                // TODO: Add files to directory
                                
                                
                                Spacer()
                            }
                            .frame(width: 280.0, height: 560.0)
                            .padding(.bottom)
                            .padding([.leading, .trailing])
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
                                //                                    .matchedGeometryEffect(id: WideScopeControlsView.additionalPromptTitleMatchedGeometryEffectID, in: namespace)
                                
                                // Text
                                TextEditor(text: $additionalPromptText)
                                    .padding()
                                    .scrollContentBackground(.hidden)
                                    .background(Color.background.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                                //                                    .matchedGeometryEffect(id: WideScopeControlsView.additionalPromptTextMatchedGeometryEffectID, in: namespace)
                                
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
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    .frame(maxHeight: 580.0)
                    
                    // Triangle for popup
                    Image(systemName: "triangle.fill")
                        .resizable()
                        .frame(width: 60.0, height: 28.0)
                        .rotationEffect(.degrees(180))
                        .padding(.top, -8)
                        .padding(.trailing, 4)
                        .foregroundStyle(Colors.foreground)
                        .zIndex(-1.0) // Move to the back so that it does not cast a shadow on te controls container
                }
                .transition(.asymmetric(insertion: .push(from: .bottom), removal: .push(from: .top)))
            }
            
            // Show and Hide Controls Button
            Button(action: {
                withAnimation(.bouncy(duration: 0.28)) {
                    isDisplayingControls.toggle()
                }
            }) {
                Image(systemName: "doc.fill.badge.ellipsis")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40.0, height: 40.0)
            }
            .buttonStyle(PlainButtonStyle())
            .padding()
            .background(Colors.foreground)
            .clipShape(Circle())
            .shadow(color: Colors.foregroundText.opacity(0.05), radius: 8.0)
            
        }
    }
    
}

#Preview {
    
    WideScopeControlsView(
        scope: .constant(.directory),
        focusViewModel: FocusViewModel(),
        selectedFilepaths: .constant([]),
        onSubmit: { actionType, additionalPromptText, generateOptions in
            print("Submitted \(actionType)")
        }
    )
        .padding()
        .background(Colors.background)
        .frame(width: 800, height: 400)
    
}
