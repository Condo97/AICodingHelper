//
//  PlanStepEditView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct PlanStepEditView: View {
    
    @Binding var step: PlanCodeGenerationFC.Step
    
//    @State private var isShowingBaseFilepathImporter: Bool = false
    @State private var isShowingNewReferenceFilepathImporter: Bool = false
    @State private var newReferenceFilepath: String = ""
    
    @State private var createBaseFilepath: String
    @State private var createFilename: String
    
    init(step: Binding<PlanCodeGenerationFC.Step>) {
        self._step = step
        
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: step.filepath.wrappedValue, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                createBaseFilepath = step.filepath.wrappedValue
                createFilename = ""
            } else {
                createBaseFilepath = URL(fileURLWithPath: step.filepath.wrappedValue).deletingLastPathComponent().path
                createFilename = URL(fileURLWithPath: step.filepath.wrappedValue).lastPathComponent
            }
        } else {
            createBaseFilepath = ""
            createFilename = ""
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(step.index)")
                .font(.largeTitle)
                .padding([.vertical, .leading])
            
            VStack(alignment: .leading, spacing: 8.0) {
                Picker("Action: ", selection: $step.action, content: {
                    Text(PlanCodeGenerationFC.Step.ActionType.create.rawValue.capitalized)
                        .tag(PlanCodeGenerationFC.Step.ActionType.create)
                    Text(PlanCodeGenerationFC.Step.ActionType.delete.rawValue.capitalized)
                        .tag(PlanCodeGenerationFC.Step.ActionType.delete)
                    Text(PlanCodeGenerationFC.Step.ActionType.edit.rawValue.capitalized)
                        .tag(PlanCodeGenerationFC.Step.ActionType.edit)
                })
                .frame(maxWidth: 200.0)
                
                if step.action == .create {
                    PlanStepFilepathEditView(
                        filepath: $createBaseFilepath,
                        emptyFilepathLabel: "\(Image(systemName: "folder")) Choose Base Folder",
                        canChooseDirectories: true,
                        canChooseFiles: false)
                    
                    TextField("File Name", text: $createFilename)
                    
                    VStack(alignment: .leading) {
                        Text("To create a **file**, include the extension (i.e. \"foo")
                        + Text(".java").bold()
                        + Text("\", \"bar")
                        + Text(".txt").bold()
                        + Text("\", etc.)")
                        Text("To create a **folder** do not include the extension (i.e. \"foldername\")")
                    }
                    .font(.subheadline)
                    .opacity(0.6)
                } else {
                    PlanStepFilepathEditView(
                        filepath: $step.filepath,
                        emptyFilepathLabel: "\(Image(systemName: "plus")) Choose File or Folder",
                        canChooseDirectories: true,
                        canChooseFiles: true)
                }
                
                if step.action == .edit {
                    var editInstructionsUnwrappedBinding: Binding<String> {
                        Binding(
                            get: {
                                step.editInstructions ?? ""
                            },
                            set: { value in
                                step.editInstructions = value
                            })
                    }
                    var referenceFilepathsUnwrappedBinding: Binding<[String]> {
                        Binding(
                            get: {
                                step.referenceFilepaths ?? []
                            },
                            set: { value in
                                step.referenceFilepaths = value
                            })
                    }
                    
                    Divider()
                        .frame(maxWidth: 150.0)
                    
                    Text("Instruction")
                        .font(.subheadline)
                    TextEditor(text: editInstructionsUnwrappedBinding)
                        .padding()
                        .background(Color.foreground)
                        .clipShape(RoundedRectangle(cornerRadius: 2.0))
                        .padding(.bottom, 2)
                        .frame(minHeight: 150.0)
                    
                    HStack {
                        Text("Reference Files")
                            .font(.subheadline)
                        Button("\(Image(systemName: "plus"))") {
                            isShowingNewReferenceFilepathImporter = true
                        }
                    }
                    ForEach(referenceFilepathsUnwrappedBinding, id: \.self) { $filepath in
                        PlanStepFilepathEditView(
                            filepath: $filepath,
                            canChooseDirectories: true,
                            canChooseFiles: true)
                    }
                }
            }
//            .grantedPermissionsDirectoryImporter(isPresented: $isShowingBaseFilepathImporter, filepath: $step.filepath, canChooseFiles: true)
            .grantedPermissionsDirectoryImporter(isPresented: $isShowingNewReferenceFilepathImporter, filepath: $newReferenceFilepath, canChooseFiles: true)
            .onChange(of: newReferenceFilepath) { newValue in
                if !newValue.isEmpty {
                    // Add to reference filepaths
                    if step.referenceFilepaths == nil {
                        step.referenceFilepaths = [newValue]
                    } else {
                        step.referenceFilepaths?.append(newValue)
                    }
                    
                    // Set newReferenceFilepath to ""
                    newReferenceFilepath = ""
                }
            }
            .padding()
        }
        .background(Colors.secondary)
        .frame(minWidth: 350.0, idealWidth: 550.0, minHeight: 300.0, idealHeight: 500.0)
        .onChange(of: createBaseFilepath) { newValue in
            updateStepFilepathWithCreateFilepathValues()
        }
        .onChange(of: createFilename) { newValue in
            updateStepFilepathWithCreateFilepathValues()
        }
    }
    
    
    func updateStepFilepathWithCreateFilepathValues() {
        if !createBaseFilepath.isEmpty && !createFilename.isEmpty {
            step.filepath = URL(fileURLWithPath: createBaseFilepath).appendingPathComponent(createFilename).path
        }
    }
    
}

#Preview {
    PlanStepEditView(step: .constant(PlanCodeGenerationFC.Step(
        index: 0,
        action: .edit,
        filepath: "This/Is/The/Filepath",
        editInstructions: "Do this first step and edit the file you are gonna edit the file yay :)",
        referenceFilepaths: ["filepath/1", "filepath2/folderinfile"])))
}
