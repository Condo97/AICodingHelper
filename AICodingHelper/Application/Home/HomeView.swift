import Foundation
import SwiftUI

struct HomeView: View {
    
    @Binding var filepath: String  // Changed type to String to hold the file path
    @Binding var isShowingCreateAIProject: Bool
    @Binding var isShowingCreateBlankProject: Bool
    @Binding var isShowingOpenFileImporter: Bool
    
    @FocusState private var focusedRecentProject
    
    @State var softSelectedFilepath: String = ""
    
    var body: some View {
        VStack {
            HStack(spacing: 0.0) {
                VStack(alignment: .leading) {
                    Text("AI+CODE")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Button(action: {
                        isShowingCreateAIProject = true
                    }) {
                        HStack {
                            ZStack {
                                Image(systemName: "cpu")
                                    .imageScale(.large)
                                    .frame(width: 28.0)
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.medium)
                                    .offset(x: 10.0, y: 8.0)
                            }
                            .offset(x: -2, y: -2)
                            Text("Create AI Project")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.6)
                        }
                        .padding()
                        .background(Colors.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Button(action: {
                        isShowingCreateBlankProject = true
                    }) {
                        HStack {
                            ZStack {
                                Image(systemName: "doc")
                                    .imageScale(.large)
                                    .frame(width: 28.0)
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.medium)
                                    .offset(x: 10.0, y: 8.0)
                            }
                            .offset(x: -2, y: -2)
                            Text("Create Blank Project")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.6)
                        }
                        .padding()
                        .background(Colors.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                    
                    Button(action: {
                        isShowingOpenFileImporter = true
                    }) {
                        HStack {
                            Image(systemName: "folder")
                                .imageScale(.large)
                                .frame(width: 28.0)
                            Text("Open Project")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .opacity(0.6)
                        }
                        .padding()
                        .background(Colors.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .padding()
                .frame(maxHeight: .infinity)
                .background(Colors.foreground)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0.0) {
                        Spacer()
                        
                        ForEach(RecentProjectHelper.recentProjectFilepaths, id: \.self) { filepath in
                            Button(action: {
                                if filepath == softSelectedFilepath {
                                    // If user has soft selected the filepath the next click will open the file
                                    self.filepath = filepath
                                } else {
                                    // If the user has not clicked the filepath the first click will soft select it
                                    softSelectedFilepath = filepath
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text((filepath as NSString).lastPathComponent)  // Assuming an extension or utility to get the last part of the filepath
                                            .font(.headline)
                                        Text(filepath)
                                            .font(.subheadline)
                                            .italic()
                                            .opacity(0.6)
                                    }
                                    .foregroundStyle(filepath == softSelectedFilepath ? Colors.elementText : Colors.secondaryText)
                                    
                                    Spacer()
                                    
                                    if filepath == softSelectedFilepath {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(Colors.elementText)
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity)
                                .background(filepath == softSelectedFilepath ? Colors.element : Colors.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 14.0))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .focusable()
                            .focused($focusedRecentProject)
                            .focusEffectDisabledVersionCheck()
                            .onDeleteCommand(perform: {
                                // Remove from RecentProjectHelper recentProjectFilepaths
                                RecentProjectHelper.recentProjectFilepaths.removeAll(where: {$0 == softSelectedFilepath})
                            })
                            
                            Divider()
                        }
                        
                        Spacer(minLength: 80.0)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Colors.secondary)
            }
        }
        .frame(minWidth: 650.0, minHeight: 500.0)
    }
}


#Preview {
    HomeView(
        filepath: .constant(""),  // Added binding for filepath
        isShowingCreateAIProject: .constant(false),
        isShowingCreateBlankProject: .constant(false),
        isShowingOpenFileImporter: .constant(false))
}
