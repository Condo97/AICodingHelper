//
//  CreatePlanStepView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct CreatePlanStepView: View {
    
    var onCancel: () -> Void
    var onSubmit: (_ step: PlanCodeGenerationFC.Step) -> Void
    
    @State private var step: PlanCodeGenerationFC.Step
    
    var submitButtonDisabled: Bool {
        switch step.action {
        case .create:
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: step.filepath, isDirectory: &isDirectory) {
                if !isDirectory.boolValue {
                    return false
                }
            }
            return true
        case .delete:
            return step.filepath.isEmpty
        case .edit:
            return step.filepath.isEmpty || step.editInstructions == nil || step.editInstructions!.isEmpty
        }
    }
    
    init(index: Int, baseFilepath: String, onCancel: @escaping () -> Void, onSubmit: @escaping (_ step: PlanCodeGenerationFC.Step) -> Void) {
        self.onCancel = onCancel
        self.onSubmit = onSubmit
        
        self.step = PlanCodeGenerationFC.Step(
            index: index,
            action: .create,
            filepath: baseFilepath)
    }
    
    var body: some View {
        VStack {
            HStack {
                PlanStepEditView(step: $step)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Add") {
                    onSubmit(step)
                }
                .keyboardShortcut(.defaultAction)
                .disabled(submitButtonDisabled)
                .opacity(submitButtonDisabled ? 0.6 : 1.0)
            }
        }
        .padding()
        .frame(minWidth: 350.0, idealWidth: 550.0, minHeight: 300.0, idealHeight: 500.0)
        .background(Colors.secondary)
    }
    
}

#Preview {
    
    CreatePlanStepView(
        index: 0,
        baseFilepath: "/thisisthebasefilepath/base/filepath",
        onCancel: {
            
        },
        onSubmit: { step in
        
    })
    
}
