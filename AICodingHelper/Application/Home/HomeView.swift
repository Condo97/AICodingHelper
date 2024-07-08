import Foundation
import SwiftUI

struct HomeView: View {
    
    @Binding var isShowingCreateAIProject: Bool
    @Binding var isShowingCreateBlankProject: Bool
    @Binding var isShowingOpenFileImporter: Bool
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("AICodingHelper")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button("Create AI Project") {
                        isShowingCreateAIProject = true
                    }
                    
                    Button("Create Blank Project") {
                        isShowingCreateBlankProject = true
                    }
                    
                    Button("Open Project") {
                        isShowingOpenFileImporter = true
                    }
                }
                .padding()
                
                Spacer()
                
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(UserDefaultsHelper.recentProjectFolders, id: \.self) { filePath in
                            Text((filePath as NSString).lastPathComponent) // Assuming an extension or utility to get the last part of the filepath
                                .padding(.vertical, 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            Spacer()
        }
        .frame(width: 650.0, height: 500.0)
    }
}


#Preview {
    HomeView(
        isShowingCreateAIProject: .constant(false),
        isShowingCreateBlankProject: .constant(false),
        isShowingOpenFileImporter: .constant(false))
}
