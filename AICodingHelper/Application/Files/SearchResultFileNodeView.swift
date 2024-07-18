//
//  SearchResultFileNodeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/17/24.
//

import SwiftUI

struct SearchResultFileNodeView: View {
    
    @Binding var filepath: String
    @Binding var selectedFilepaths: [String]
    var onAction: (_ action: FileActions, _ path: String) -> Void
    
    @EnvironmentObject private var focusViewModel: FocusViewModel
    
    @FocusState private var focused
    
    @State private var hovering: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "doc.text")
            VStack(alignment: .leading) {
                Text(getFilename(filepath))
                Text(filepath)
                    .font(.subheadline)
                    .opacity(0.6)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(
            focusViewModel.focus == .browser
            ? Colors.element.opacity(selectedFilepaths.contains(filepath) ? 0.3 : hovering ? 0.1 : 0)
            : Color.gray.opacity(selectedFilepaths.contains(filepath) ? 0.3 : hovering ? 0.1 : 0)
        )
//        .clipShape(RoundedRectangle(cornerRadius: 4.0))
//        .padding(.bottom, 4)
        .focusable()
        .focusEffectDisabledVersionCheck()
//                    .focused($focused)
        .onTapGesture(count: 2) {
            onAction(.open, filepath)
        }
        .simultaneousGesture(
            TapGesture(count: 1)
                .onEnded {
                    if NSEvent.modifierFlags.contains(.shift) {
                        selectedFilepaths.append(filepath)
                    } else {
                        selectedFilepaths = [filepath]
                    }
                }
        )
        .onHover { hovering in
            self.hovering = hovering
            
            if hovering {
                NSCursor.arrow.push()
                NSCursor.pointingHand.set()
            }
        }
    }
    
    
    private func getFilename(_ filepath: String) -> String {
        return URL(fileURLWithPath: filepath).lastPathComponent
    }
    
}

#Preview {
    SearchResultFileNodeView(
        filepath: .constant("~/Downloads/test_dir"),
        selectedFilepaths: .constant([]),
        onAction: { action, path in
            
        })
}
