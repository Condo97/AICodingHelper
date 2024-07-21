//
//  CodeGeneratorControlSwitch.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/1/24.
//

import SwiftUI


struct CodeGeneratorControlSwitch: View {
    
    @Binding var isOn: Bool
    @Binding var title: Text
    @Binding var subtitle: Text?
    @Binding var hoverDescription: LocalizedStringKey
    @State var foregroundColor: Color
//    @State var size: CGSize = CGSize(width: 280.0, height: 60.0)
    
    
    var body: some View {
        ZStack {
            foregroundColor
            
            HStack(alignment: .top) {
                Toggle("", isOn: $isOn)
                    .toggleStyle(.switch)
                    .offset(y: 4)
                
                VStack(alignment: .leading) {
                    title
                    
                    if let subtitle = subtitle {
                        subtitle
                            .font(.system(size: 12.0))
                            .opacity(0.6)
                            .minimumScaleFactor(0.5)
                    }
                }
                
                Spacer()
            }
            .help(hoverDescription)
        }
//        .frame(width: size.width, height: size.height)
    }
    
}

#Preview {
    
    CodeGeneratorControlSwitch(
        isOn: .constant(true),
        title: .constant(Text("Use Entire Project as Context")),
        subtitle: .constant(Text("More accurate results but may cost large amounts of tokens.")),
        hoverDescription: .constant("Analyze all comments."),
        foregroundColor: Colors.foreground
    )
    
}
