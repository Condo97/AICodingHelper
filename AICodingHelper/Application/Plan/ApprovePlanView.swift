//
//  ApprovePlanView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct ApprovePlanView: View {
    
    @Binding var plan: CodeGenerationPlan
    @Binding var tokenEstimation: Int?
    var onCancel: () -> Void
    var onStart: () -> Void
    
    @EnvironmentObject private var activeSubscriptionUpdater: ActiveSubscriptionUpdater
    
    var startButtonDisabled: Bool {
        tokenEstimation == nil && (activeSubscriptionUpdater.openAIKey == nil || !activeSubscriptionUpdater.openAIKeyIsValid)
    }
    
    var body: some View {
        VStack {
            PlanView(plan: $plan)
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Button(action: {
                    onStart()
                }) {
                    HStack {
                        Text("Start")
                        
                        if startButtonDisabled {
                            ProgressView()
                        }
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(startButtonDisabled)
            }
        }
        .padding()
    }
    
}

#Preview {
    
    ApprovePlanView(
        plan: .constant(
            CodeGenerationPlan(
                model: .GPT4o,
                editActionSystemMessage: "Edit Action System Message",
                instructions: "Instructions all of them!",
                copyCurrentFilesToTempFiles: true,
                planFC: PlanCodeGenerationFC(steps: [
                    PlanCodeGenerationFC.Step(
                        index: 0,
                        action: .edit,
                        filepath: "first filepath test",
                        editInstructions: "This is the edit instruction for GPT :)",
                        referenceFilepaths: ["Reference filepath 1", "Reference filepath 2", "Reference filepath 3"])
                ]))
        ),
        tokenEstimation: .constant(0),
        onCancel: {
            
        },
        onStart: {
            
        }
    )
    
}
