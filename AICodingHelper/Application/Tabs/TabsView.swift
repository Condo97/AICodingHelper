//
//  TabsView.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/29/24.
//

import SwiftUI

struct TabsView: View {
    
    @ObservedObject var tabsViewModel: TabsViewModel
    
    
    @Environment(\.undoManager) private var undoManager
    
    
    private static let tabsHeight: CGFloat = 60.0
    
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0.0) {
                ForEach($tabsViewModel.openTabs) { openTab in
                    var openTabTitle: Binding<String> {
                        Binding(
                            get: {
                                // Open tab title is last path component of url with openTab filepath
                                if let filepath = openTab.wrappedValue.filepath {
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
                                    tabsViewModel.openTabs.removeAll(where: {$0 === openTab.wrappedValue})
                                    
                                    // TODO: Maybe remove all tabs with nil filepaths? Or should that be done somewhere else? Maybe onChange of openTabs or something
                                }
                            })
                    }
                    
                    var openTabSelected: Binding<Bool> {
                        Binding(
                            get: {
                                // Conditional if openTab equals tabsViewModel openTab
                                openTab.wrappedValue === tabsViewModel.openTab
                            },
                            set: { value in
                                if value {
                                    // If true save undo and set tabsViewModel openTab to openTab
                                    if let undoManager = undoManager {
                                        tabsViewModel.saveUndo(undoManager: undoManager)
                                    }
                                    tabsViewModel.openTab = openTab.wrappedValue
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
                            if tabsViewModel.openTab === openTab.wrappedValue {
                                let indexOfOpenTab = tabsViewModel.openTabs.firstIndex(where: {$0 === openTab.wrappedValue})
                                if indexOfOpenTab != nil && indexOfOpenTab! >= 1 {
                                    // Select tab left of openTab if it exists
                                    tabsViewModel.openTab = tabsViewModel.openTabs[indexOfOpenTab! - 1]
                                } else if indexOfOpenTab != nil && indexOfOpenTab! < tabsViewModel.openTabs.count - 1 {
                                    // Select tab to right of openTab if it exists
                                    tabsViewModel.openTab = tabsViewModel.openTabs[indexOfOpenTab! + 1]
                                } else {
                                    // Set selectedTab to nil
                                    tabsViewModel.openTab = nil
                                }
                            }
                            
                            // Remove openTab from openTabs
                            tabsViewModel.openTabs.removeAll(where: {$0 === openTab.wrappedValue})
                        })
                }
            }
        }
        .frame(height: TabsView.tabsHeight)
    }
    
}

#Preview {
    
    let tabsViewModel = TabsViewModel()
    tabsViewModel.openTabs = [CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt")]
    
    return TabsView(
        tabsViewModel: tabsViewModel
    )
    
}
