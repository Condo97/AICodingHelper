//
//  HomeView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/5/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    
    @Binding var isShowingOpenFileImporter: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("AICodingHelper")
                        .font(.title)
                        .fontWeight(.bold)
                    
//                    Text()
                }
                
                Spacer()
            }
            
            Spacer()
            
            Button("Open File") {
                isShowingOpenFileImporter = true
            }
        }
        .padding()
        .frame(width: 650.0, height: 500.0)
    }
    
}


#Preview {
    
    HomeView(isShowingOpenFileImporter: .constant(false))
    
}
