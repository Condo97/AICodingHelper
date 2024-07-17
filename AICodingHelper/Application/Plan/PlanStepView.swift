//
//  PlanStepView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct PlanStepView: View {
    
    @Binding var step: PlanCodeGenerationFC.Step
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        Button(action: {
            isEditing = true
        }) {
            preview
        }
        .sheet(isPresented: $isEditing) {
            editor
        }
    }
    
    var preview: some View {
        HStack {
            PlanStepPreviewView(step: $step)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .imageScale(.large)
                .padding(.trailing)
        }
    }
    
    var editor: some View {
        VStack {
            PlanStepEditView(step: $step)
            
            HStack {
                Spacer()
                
                Button("Done", action: {
                    isEditing = false
                })
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .background(Colors.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
    
}

#Preview {
    PlanStepView(step: .constant(PlanCodeGenerationFC.Step(
        index: 0,
        action: .edit,
        filepath: "This/Is/The/Filepath",
        editInstructions: "Do this first step and edit the file you are gonna edit the file yay :)",
        referenceFilepaths: ["filepath/1", "filepath2/folderinfile"])))
    .background(Colors.foreground)
    .clipShape(RoundedRectangle(cornerRadius: 14.0))
}
