//
//  NarrowScopeControlsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import SwiftUI

struct NarrowScopeControlsView: View {
    
    @Binding var scope: Scope
    var onSubmit: (_ actionType: ActionType, _ userInput: String?) -> Void
    
    
    @State private var isShowingUserInputDisplay: Bool = false
    @State private var userInputText: String = ""
    
    
    private var submittableUserInputText: String? {
        isShowingUserInputDisplay ? userInputText : nil
    }
    
    
    var body: some View {
        VStack {
            // User Input Field
            if isShowingUserInputDisplay {
                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        Text("Additional Prompt")
                            .font(.system(size: 17.0, weight: .regular))
                        Text("*- Use this to make small tweaks or specify custo functionality.*")
                            .minimumScaleFactor(0.5)
                            .font(.system(size: 10.0, weight: .light))
                    }
                    
                    TextEditor(text: $userInputText) //"Enter additional prompt..."
                        .scrollContentBackground(.hidden)
                        .padding()
                        .background(Colors.secondary.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .padding(.top)
                .padding([.leading, .trailing])
                .frame(minHeight: 180.0, maxHeight: 280.0)
            }
            
            HStack(spacing: 0.0) {
                Color.clear
                    .padding(.leading, 16.0)
                
                // Comment
                NarrowScopeControlButton(
                    label: Text("//")
                        .font(.system(size: 100.0))
                        .minimumScaleFactor(0.01),
                    subtitle: .constant("Comment"),
                    hoverDescription: Binding(get: {"AI comments your \(scope.name)"}, set: {_ in}),
                    foregroundColor: .foreground,
                    action: { onSubmit(.comment, submittableUserInputText) })
                
                // Bug Fix
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.bug)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Bug Fix"),
                    hoverDescription: Binding(get: {"AI fixes bugs in your \(scope.name)"}, set: {_ in}),
                    foregroundColor: .foreground,
                    action: { onSubmit(.bugFix, submittableUserInputText) })
                
                // Split
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.split)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Split"),
                    hoverDescription: Binding(get: {"AI separates your \(scope.name)"}, set: {_ in}),
                    foregroundColor: .foreground,
                    action: { onSubmit(.split, submittableUserInputText) })
                
                // Simplify
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.simplify)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Simplify"),
                    hoverDescription: Binding(get: {"AI simplifies your \(scope.name)."}, set: {_ in}),
                    foregroundColor: .foreground,
                    action: { onSubmit(.simplify, submittableUserInputText) })
                
                // Test
                NarrowScopeControlButton(
                    label: Image(Constants.ImageName.Actions.createTests)
                        .resizable()
                        .aspectRatio(contentMode: .fit),
                    subtitle: .constant("Create Tests"),
                    hoverDescription: Binding(get: {"AI creates tests for your \(scope.name)"}, set: {_ in}),
                    foregroundColor: .foreground,
                    action: { onSubmit(.createTests, submittableUserInputText) })
                
                // Custom
                NarrowScopeControlButton(
                    label: Image(systemName: "questionmark.app")
                        .resizable(),
                    subtitle: .constant("Custom"),
                    hoverDescription: Binding(get: {"AI runs with no prompt for your \(scope.name)."}, set: {_ in}),
                    foregroundColor: .foreground,
                    action: { onSubmit(.custom, submittableUserInputText) })
                
                Divider()
                    .frame(height: 28.0)
                
                // User Input Display Toggle
//                Button(action: {
//                    withAnimation(.bouncy(duration: 0.5)) {
//                        isShowingUserInputDisplay.toggle()
//                    }
//                }) {
//                    Image(systemName: isShowingUserInputDisplay ? "chevron.down" : "chevron.up")
//                        .imageScale(.medium)
//                }
//                .help("Add a prompt to give custom instructions.")
//                .buttonStyle(PlainButtonStyle())
//                .padding([.leading, .trailing])
                NarrowScopeControlButton(
                    label: Image(systemName: isShowingUserInputDisplay ? "chevron.down" : "chevron.up")
                        .imageScale(.large),
                    subtitle: .constant(nil),
                    hoverDescription: Binding(get: {"AI runs with no prompt for your \(scope.name)."}, set: {_ in}),
                    foregroundColor: .foreground,
                    size: CGSize(width: 60.0, height: 80.0),
                    action: {
                        withAnimation(.bouncy(duration: 0.5)) { // TODO: Maybe try springy
                            isShowingUserInputDisplay.toggle()
                        }
                    })
                
                Color.clear
                    .padding(.trailing, 8.0)
            }
            .frame(height: 80.0)
        }
        .fixedSize(horizontal: true, vertical: false)
    }
    
}

#Preview {
    
    ZStack {
        NarrowScopeControlsView(scope: .constant(.file)) { actionType, userInput in
            
        }
//        .frame(height: 80.0)
        .background(Colors.foreground)
        .clipShape(RoundedRectangle(cornerRadius: 48.0))
    }
    
}
