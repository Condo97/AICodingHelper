//
//  DismissOnAppearView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/8/24.
//

import SwiftUI

struct DismissOnAppearView: View {
    
    var beforeDismiss: () -> Void
    
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            
        }
        .onAppear {
            beforeDismiss()
            dismiss.callAsFunction()
        }
    }
    
}
