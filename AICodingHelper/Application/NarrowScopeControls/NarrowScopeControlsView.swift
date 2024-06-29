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
                    subtitle: .constant("Comment"),
                    hoverDescription: Binding(get: {"AI comments your \(scope.name)"}, set: {_ in}),
                    action: { onSubmit(.comment) })
                
                // Bug Fix
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.bug)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Bug Fix"),
                    hoverDescription: Binding(get: {"AI fixes bugs in your \(scope.name)"}, set: {_ in}),
                    action: { onSubmit(.bugFix) })
                
                // Split
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.split)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Split"),
                    hoverDescription: Binding(get: {"AI separates your \(scope.name)"}, set: {_ in}),
                    action: { onSubmit(.split) })
                
                // Simplify
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.simplify)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Simplify"),
                    hoverDescription: Binding(get: {"AI simplifies your \(scope.name)."}, set: {_ in}),
                    action: { onSubmit(.simplify) })
                
                // Test
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.createTests)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Create Tests"),
                    hoverDescription: Binding(get: {"AI creates tests for your \(scope.name)"}, set: {_ in}),
                    action: { onSubmit(.createTests) })
                
                // Custom
                NarrowScopeControlButton(
                    label: Image(systemName: "questionmark.app")
                        .resizable(),
                    subtitle: .constant("Custom"),
                    hoverDescription: Binding(get: {"AI runs with no prompt for your \(scope.name)."}, set: {_ in}),
                    action: { onSubmit(.custom) })
            }
        }
    }
    
}

#Preview {
    
    NarrowScopeControlsView(scope: .constant(.file)) { actionType in
        
    }
    
}
