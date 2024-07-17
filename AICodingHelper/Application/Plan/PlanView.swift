//
//  PlanView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct PlanView: View {
    
    @Binding var plan: CodeGenerationPlan
    
    @State private var isShowingNewStepView: Bool = false
    @State private var isShowingReorderStepsView: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Plan")
                    .font(.title)
                
                Picker("Model", selection: $plan.model) {
                    Text(GPTModels.GPT3_5.rawValue).tag(GPTModels.GPT3_5)
                    Text(GPTModels.GPT4o.rawValue).tag(GPTModels.GPT4o)
                }
                .frame(maxWidth: 150.0)
                .font(.headline)
                
                Spacer()
                
                Toggle("Overwrite Files?", isOn: Binding(get: { !plan.copyCurrentFilesToTempFiles }, set: { plan.copyCurrentFilesToTempFiles = !$0 }))
                    .toggleStyle(.switch)
                    .font(.headline)
                
                Spacer()
                
                Text("Instructions")
                    .font(.headline)
                TextField("Instructions", text: $plan.instructions)
                
                Spacer()
                
                HStack {
                    Text("Steps")
                        .font(.headline)
                    Button("\(Image(systemName: "plus"))") {
                        isShowingNewStepView = true
                    }
                    Button("\(Image(systemName: "list.number"))") {
                        isShowingReorderStepsView = true
                    }
                }
                ForEach($plan.planFC.steps, id: \.index) { $step in
                    PlanStepView(step: $step)
                }
            }
            .padding()
        }
        .frame(minWidth: 350.0, idealWidth: 550.0, minHeight: 300.0, idealHeight: 500.0)
        .sheet(isPresented: $isShowingNewStepView) {
            CreatePlanStepView(
                index: plan.planFC.steps.count,
                baseFilepath: "",
                onCancel: {
                    isShowingNewStepView = false
                },
                onSubmit: { step in
                    plan.planFC.steps.append(step)
                    
                    isShowingNewStepView = false
                })
        }
        .sheet(isPresented: $isShowingReorderStepsView) {
            PlanStepReorderView(
                steps: $plan.planFC.steps,
                onDone: {
                    isShowingReorderStepsView = false
                })
        }
    }
    
}

#Preview {
    
    PlanView(
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
        )
    )
    
}
