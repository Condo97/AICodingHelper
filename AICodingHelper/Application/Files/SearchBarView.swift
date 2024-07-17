import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct FileBrowserView: View {
    @State private var searchText = ""
    @State private var files = ["File1.txt", "File2.txt", "Document.pdf", "Image.png", "Notes.docx"]
    
    var filteredFiles: [String] {
        if searchText.isEmpty {
            return files
        } else {
            return files.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            SearchBarView(text: $searchText)
                .padding(.top, 8)
            List(filteredFiles, id: \.self) { file in
                NavigationLink(destination: FileNodeView(fileName: file)) {
                    FileSystemView(fileName: file)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding()
    }
}

struct FileSystemView: View {
    var fileName: String
    
    var body: some View {
        Text(fileName)
    }
}

struct FileNodeView: View {
    var fileName: String
    
    var body: some View {
        VStack {
            Text("Detail view for \(fileName)")
            Spacer()
        }
        .padding()
        .navigationTitle(fileName)
    }
}

#Preview {
    NavigationView {
        FileBrowserView()
    }
}