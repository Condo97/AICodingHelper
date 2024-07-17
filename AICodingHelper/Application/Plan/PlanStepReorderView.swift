//
//  PlanStepReorderView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct PlanStepReorderView: View {
    
    @Binding var steps: [PlanCodeGenerationFC.Step]
    var onDone: () -> Void

    var body: some View {
        VStack {
            List {
                ForEach($steps) { $step in
                    HStack {
                        PlanStepPreviewView(
                            step: $step,
                            showInstructions: false)
                            .onDrag {
                                NSItemProvider(object: String(step.id.uuidString) as NSString)
                            }
                            .onDrop(of: [.plainText], delegate: DropViewDelegate(currentStep: step, steps: $steps))
                        Spacer()
                        Image(systemName: "line.3.horizontal")
                    }
                    .background(Color.foreground)
                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .onMove(perform: move)
            }
            .listStyle(InsetListStyle()) // For a cleaner look on macOS
            
            HStack {
                Spacer()
                
                Button("Done") {
                    onDone()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding([.horizontal, .bottom])
        }
        .frame(minWidth: 350.0, idealWidth: 550.0, minHeight: 300.0, idealHeight: 500.0)
    }

    func move(from source: IndexSet, to destination: Int) {
        steps.move(fromOffsets: source, toOffset: destination)
        updateStepIndices()
    }

    func updateStepIndices() {
        for (index, step) in steps.enumerated() {
            steps[index].index = index
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let currentStep: PlanCodeGenerationFC.Step
    @Binding var steps: [PlanCodeGenerationFC.Step]

    func performDrop(info: DropInfo) -> Bool {
        let itemProviders = info.itemProviders(for: [.plainText])
        guard let itemProvider = itemProviders.first else { return false }

        itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { (data, error) in
            DispatchQueue.main.async {
                guard let data = data as? Data, let stringUUID = String(data: data, encoding: .utf8),
                      let uuid = UUID(uuidString: stringUUID),
                      let fromIndex = self.steps.firstIndex(where: { $0.id == uuid }),
                      let toIndex = self.steps.firstIndex(where: { $0.id == self.currentStep.id }) else { return }

                withAnimation {
                    let fromItem = self.steps.remove(at: fromIndex)
                    self.steps.insert(fromItem, at: toIndex)
                    self.updateStepIndices()
                }
            }
        }

        return true
    }

    func updateStepIndices() {
        for (index, step) in steps.enumerated() {
            steps[index].index = index
        }
    }
    
}

#Preview {
    PlanStepReorderView(
        steps: .constant([
            PlanCodeGenerationFC.Step(
                index: 0,
                action: .edit,
                filepath: "first filepath test",
                editInstructions: "This is the edit instruction for GPT :)",
                referenceFilepaths: ["Reference filepath 1", "Reference filepath 2", "Reference filepath 3"])]),
        onDone: {
        
    })
}
