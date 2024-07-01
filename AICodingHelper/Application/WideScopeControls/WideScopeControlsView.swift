//
//  WideScopeControlsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/30/24.
//

import SwiftUI

struct WideScopeControlsView: View {
    
    @Binding var scope: Scope?
    @Binding var selectedFilepaths: [String]
    var onSubmit: (_ actionType: ActionType/*TODO: , _ userInput: String?*/) -> Void
    
    
    @State private var isDisplayingControls: Bool = true
    
    
    private var buttonScopeNmae: String {
        switch scope {
        case .project:
            "Project"
        case .directory:
            "Directory"
        case .file:
            "File\(selectedFilepaths.count == 1 ? "" : "s")"
        default:
            ""
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            // Controls
            if isDisplayingControls {
                VStack(spacing: 0.0) {
                    VStack(spacing: 0.0) {
                        // Comment
                        WideScopeControlButton(
                            label: Text("//")
                                .font(.system(size: 100.0))
                                .minimumScaleFactor(0.01),
                            subtitle: .constant("Comment \(scope?.name.capitalized ?? "")"),
                            hoverDescription: Binding(get: {"AI comments your \(scope?.name ?? "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.comment) })
                        
                        // Bug Fix
                        WideScopeControlButton(
                            label: Image(Constants.ImageName.Actions.bug)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            subtitle: .constant("Bug Fix"),
                            hoverDescription: Binding(get: {"AI fixes bugs in your \(scope?.name ?? "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.bugFix) })
                        
                        // Split
                        WideScopeControlButton(
                            label: Image(Constants.ImageName.Actions.split)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            subtitle: .constant("Split"),
                            hoverDescription: Binding(get: {"AI separates your \(scope?.name ?? "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.split) })
                        
                        // Simplify
                        WideScopeControlButton(
                            label: Image(Constants.ImageName.Actions.simplify)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            subtitle: .constant("Simplify"),
                            hoverDescription: Binding(get: {"AI simplifies your \(scope?.name ?? "")."}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.simplify) })
                        
                        // Test
                        WideScopeControlButton(
                            label: Image(Constants.ImageName.Actions.createTests)
                                .resizable()
                                .aspectRatio(contentMode: .fit),
                            subtitle: .constant("Create Tests"),
                            hoverDescription: Binding(get: {"AI creates tests for your \(scope?.name ?? "")"}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.createTests) })
                        
                        // Custom
                        WideScopeControlButton(
                            label: Image(systemName: "questionmark.app")
                                .resizable(),
                            subtitle: .constant("Custom"),
                            hoverDescription: Binding(get: {"AI runs with no prompt for your \(scope?.name ?? "")."}, set: {_ in}),
                            foregroundColor: .foreground,
                            action: { onSubmit(.custom) })
                        
                        // Use entire project as context TODO: Add option to NarrowScopeControlsView
                        // Create temporary files instead of rewriting TODO: Add option to NarrowScopeControlsView
                        // TODO: Add files to directory
                    }
                    .padding()
                    .background(Colors.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                
                // Triangle for popup
                Image(systemName: "triangle.fill")
                    .resizable()
                    .frame(width: 60.0, height: 28.0)
                    .rotationEffect(.degrees(180))
                    .padding(.top, -18)
                    .padding(.leading, 4)
                    .foregroundStyle(Colors.foreground)
            }
            
            // Show and Hide Controls Button
            Button(action: {
                withAnimation(.bouncy(duration: 0.5)) {
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
        selectedFilepaths: .constant([]),
        onSubmit: { actionType in
            print("Submitted \(actionType)")
        }
    )
        .padding()
        .background(Colors.background)
}
