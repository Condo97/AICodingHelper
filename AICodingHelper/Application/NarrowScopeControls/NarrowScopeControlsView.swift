//
//  NarrowScopeControlsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

struct NarrowScopeControlsView: View {
    
    @Binding var scope: Scope
    var onSubmit: (_ actionType: ActionType) -> Void
    
    
    var body: some View {
        VStack {
            HStack {
                // Comment
                NarrowScopeControlButton(
                    label: Text("//")
                        .font(.system(size: 100.0))
                        .minimumScaleFactor(0.01),
                    subtitle: "Comment",
                    hoverDescription: "AI comments your \(scope.name)",
                    action: { onSubmit(.comment) })
                
                // Bug Fix
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.bug)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: "Bug Fix",
                    hoverDescription: "AI fixes bugs in your \(scope.name)",
                    action: { onSubmit(.bugFix) })
                
                // Split
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.split)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: "Split",
                    hoverDescription: "AI separates your \(scope.name)",
                    action: { onSubmit(.split) })
                
                // Simplify
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.simplify)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: "Simplify",
                    hoverDescription: "AI simplifies your \(scope.name).",
                    action: { onSubmit(.simplify) })
                
                // Test
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.createTests)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: "Create Tests",
                    hoverDescription: "AI creates tests for your \(scope.name)",
                    action: { onSubmit(.createTests) })
                
                // Custom
                NarrowScopeControlButton(
                    label: Image(systemName: "questionmark.app")
                        .resizable(),
                    subtitle: "Custom",
                    hoverDescription: "AI runs with no prompt for your \(scope.name).",
                    action: { onSubmit(.custom) })
            }
        }
    }
    
}

#Preview {
    
    NarrowScopeControlsView(scope: .constant(.file)) { actionType in
        
    }
    
}
