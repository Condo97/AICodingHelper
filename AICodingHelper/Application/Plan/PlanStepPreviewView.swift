//
//  PlanStepPreviewView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct PlanStepPreviewView: View {
    
    @Binding var step: PlanCodeGenerationFC.Step
    @State var showInstructions: Bool = true
    
    var body: some View {
        HStack {
            Text("\(step.index)")
                .font(.largeTitle)
                .padding([.vertical, .leading])
            
            VStack(alignment: .leading) {
                Text("Action: ")
                    .font(.headline)
                +
                Text(step.action.rawValue.capitalized)
                Text(step.filepath)
                    .font(.subheadline)
                    .italic()
                    .opacity(0.6)
                
                if showInstructions {
                    if let editInstructions = step.editInstructions {
                        Divider()
                            .frame(maxWidth: 150.0)
                        
                        Text("Instruction")
                            .font(.subheadline)
                        Text(editInstructions)
                            .padding(.bottom, 2)
                            .lineLimit(99)
                    }
                    
                    if let referenceFilepaths = step.referenceFilepaths {
                        Text("Reference Files")
                            .font(.subheadline)
                        ForEach(referenceFilepaths, id: \.self) { filepath in
                            Text(filepath)
                                .font(.subheadline)
                                .italic()
                                .opacity(0.6)
                        }
                    }
                }
            }
            .padding([.vertical, .trailing])
        }
    }
    
}

#Preview {
    PlanStepPreviewView(step: .constant(PlanCodeGenerationFC.Step(
        index: 0,
        action: .edit,
        filepath: "This/Is/The/Filepath",
        editInstructions: "Do this first step and edit the file you are gonna edit the file yay :)",
        referenceFilepaths: ["filepath/1", "filepath2/folderinfile"])))
}
