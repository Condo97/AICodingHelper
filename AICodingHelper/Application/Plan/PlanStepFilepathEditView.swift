//
//  PlanStepFilepathEditView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/12/24.
//

import SwiftUI

struct PlanStepFilepathEditView: View {
    
    @Binding var filepath: String
    @State var emptyFilepathLabel: LocalizedStringKey = "\(Image(systemName: "plus")) Select Filepath"
    @State var canChooseDirectories: Bool
    @State var canChooseFiles: Bool
    
    
    @State private var isShowingBaseFilepathImporter: Bool = false
    
    var body: some View {
        HStack {
            Button(filepath.isEmpty ? emptyFilepathLabel : "\(Image(systemName: "arrow.uturn.up.circle"))") {
                isShowingBaseFilepathImporter = true
            }
            Text(filepath)
                .font(.subheadline)
        }
        .grantedPermissionsDirectoryImporter(isPresented: $isShowingBaseFilepathImporter, filepath: $filepath, canChooseDirectories: canChooseDirectories, canChooseFiles: canChooseFiles)
    }
    
}

#Preview {
    PlanStepFilepathEditView(
        filepath: .constant("~/Downloads/test_dir"),
        canChooseDirectories: true,
        canChooseFiles: true)
}
