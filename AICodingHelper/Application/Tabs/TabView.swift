//
//  CodeTabView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/29/24.
//

import SwiftUI

struct CodeTabView: View {
    
    @ObservedObject var codeViewModel: CodeViewModel
    var onSelect: () -> Void
    var onClose: () -> Void
    
//    @Binding var title: String
//    @Binding var open: Bool
//    @Binding var selected: Bool
    
    var title: String {
        URL(fileURLWithPath: codeViewModel.filepath ?? "").lastPathComponent
    }
    
    
    var body: some View {
        Button(action: {
            onSelect()
        }) {
            HStack {
                // Title
                Text(title)
                
                // Close Button
                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding([.leading, .trailing])
            .background(
                RoundedRectangle(cornerRadius: 2.0)
//                    .fill(selected ? Colors.foreground : Colors.secondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
}

//#Preview {
//    
//    CodeTabView(
//        title: .constant("Tab"),
//        open: .constant(true),
//        selected: .constant(true)
//    )
//    
//}
