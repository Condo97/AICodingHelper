//
//  TabsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/29/24.
//

import SwiftUI

struct TabsView: View {
    
    @Binding var openTabs: [CodeViewModel]
    @Binding var selectedTab: CodeViewModel?
    @State var onSelect: (CodeViewModel) -> Void
    
    
    private static let tabsHeight: CGFloat = 60.0
    
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0.0) {
                ForEach(openTabs) { openTab in
                    var openTabTitle: Binding<String> {
                        Binding(
                            get: {
                                // Open tab title is last path component of url with openTab filepath
                                if let filepath = openTab.filepath {
                                    return URL(fileURLWithPath: filepath).lastPathComponent
                                }
                                
                                // Default if filepath cannot be unwrapped
                                return "*No Filename*"
                            },
                            set: { value in
                                // No set actions
                            })
                    }
                    
                    var openTabOpen: Binding<Bool> {
                        Binding(
                            get: {
                                // Always true if in openTabs
                                true
                            },
                            set: { value in
                                if !value {
                                    // If false remove openTab from openTabs
                                    openTabs.removeAll(where: {$0 === openTab})
                                    
                                    // TODO: Maybe remove all tabs with nil filepaths? Or should that be done somewhere else? Maybe onChange of openTabs or something
                                }
                            })
                    }
                    
                    var openTabSelected: Binding<Bool> {
                        Binding(
                            get: {
                                // Conditional if openTab equals selectedTab
                                openTab === selectedTab
                            },
                            set: { value in
                                if value {
                                    // If true set selectedTab to openTab
                                    selectedTab = openTab
                                    //                                onSelect(openTab)
                                }
                            })
                    }
                    
                    //                CodeTabView(
                    //                    title: openTabTitle,
                    //                    open: openTabOpen,
                    //                    selected: openTabSelected)
                    CodeTabView(
                        title: openTabTitle,
                        //                    onSelect: {
                        //                        // Set selectedTab to openTab
                        //                        selectedTab = openTab
                        //                    },
                        selected: openTabSelected,
                        onClose: {
                            // If current tab is selected, move to adjacent tab on left or right or set to nil
                            if selectedTab === openTab {
                                let indexOfOpenTab = openTabs.firstIndex(where: {$0 === openTab})
                                if indexOfOpenTab != nil && indexOfOpenTab! >= 1 {
                                    // Select tab left of openTab if it exists
                                    selectedTab = openTabs[indexOfOpenTab! - 1]
                                } else if indexOfOpenTab != nil && indexOfOpenTab! < openTabs.count - 1 {
                                    // Select tab to right of openTab if it exists
                                    selectedTab = openTabs[indexOfOpenTab! + 1]
                                } else {
                                    // Set selectedTab to nil
                                    selectedTab = nil
                                }
                            }
                            
                            // Remove openTab from openTabs
                            openTabs.removeAll(where: {$0 === openTab})
                        })
                }
            }
        }
        .frame(height: TabsView.tabsHeight)
    }
    
}

//#Preview {
//    
//    TabsView(
//        openTabs: .constant([CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt")]),
//        selectedTab: .constant(CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt"))
//    )
//    
//}
