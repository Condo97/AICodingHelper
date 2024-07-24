//
//  LoadingChatView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/22/24.
//

import SwiftUI

struct LoadingChatView: View {
    
    @Binding var canCancel: Bool
    var stopLoading: () -> Void
    
    var body: some View {
        HStack(spacing: 16.0) {
            if canCancel {
                Button(action: { stopLoading() }) {
                    Text("Stop")
                    ProgressView()
                        .controlSize(.small)
                }
            } else {
                Text("Loading...")
            }
            
            Spacer()
        }
        .padding(4)
    }
    
}

#Preview {
    
    LoadingChatView(
        canCancel: .constant(true),
        stopLoading: {
            
        }
    )
    
}
