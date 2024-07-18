import SwiftUI

struct FileBrowserView: View {

    @Binding var baseDirectory: String
    @Binding var selectedFilepaths: [String]
    @ObservedObject var tabsViewModel: TabsViewModel

    @State private var searchText: String = ""
    @State private var searchResults: [String] = []

    var body: some View {
        VStack(spacing: 0.0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search", text: $searchText, onEditingChanged: { isEditing in
                    if !isEditing {
                        performSearch() // Execute search when editing ends
                    }
                })
                .textFieldStyle(.plain)
            }
            .padding()
            .background(Color.foreground)

            // Search Results
            if !searchResults.isEmpty {
                FileSearchResultsView(
                    searchResults: searchResults,
                    selectedFilepaths: $selectedFilepaths,
                    onAction: tabsViewModel.performAction
                )
            } else {
                // File Browser
                TabAddingFileSystemView(
                    directory: $baseDirectory,
                    selectedFilepaths: $selectedFilepaths,
                    searchText: $searchText,
                    tabsViewModel: tabsViewModel
                )
            }
        }
    }

    private func performSearch() {
        /* Update searchResults based on searchText
           Assuming a function 'searchFiles' which searches for files containing 'searchText' and returns their paths */
        searchResults = searchFiles(containing: searchText, atPath: baseDirectory)
    }
}

import SwiftUI

struct FileSearchResultsView: View {
    let searchResults: [String]
    @Binding var selectedFilepaths: [String]
    var onAction: (_ action: FileActions, _ path: String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(searchResults, id: \.self) { filePath in
                Text(filePath)
                    .onTapGesture { onAction(.open, filePath) }
                    .padding(.vertical, 2)
            }
        }
    }
}

#Preview {
    FileBrowserView(
        baseDirectory: .constant("~/Downloads/test_dir"),
        selectedFilepaths: .constant([]),
        tabsViewModel: TabsViewModel()
    )
    .environmentObject(FocusViewModel())
}