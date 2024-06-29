////
////  CodeTabView.swift
////  AICodingHelper
////
////  Created by Alex Coundouriotis on 6/29/24.
////
//
//import SwiftUI
//
//struct CodeTabView: View {
//    
//    @ObservedObject var codeViewModel: CodeViewModel
//    var onSelect: () -> Void
//    
//    
//    var openTabTitle: Binding<String> {
//        Binding(
//            get: {
//                // Open tab title is last path component of url with openTab filepath
//                if let filepath = openTab.filepath {
//                    return URL(fileURLWithPath: filepath).lastPathComponent
//                }
//                
//                // Default if filepath cannot be unwrapped
//                return "*No Filename*"
//            },
//            set: { value in
//                // No set actions
//            })
//    }
//    
//    var openTabOpen: Binding<Bool> {
//        Binding(
//            get: {
//                // Always true if in openTabs
//                true
//            },
//            set: { value in
//                if !value {
//                    // If false remove openTab from openTabs
//                    openTabs.removeAll(where: {$0 === openTab})
//                    
//                    // TODO: Maybe remove all tabs with nil filepaths? Or should that be done somewhere else? Maybe onChange of openTabs or something
//                }
//            })
//    }
//    
//    var openTabSelected: Binding<Bool> {
//        Binding(
//            get: {
//                // Conditional if openTab equals selectedTab
//                openTab === selectedTab
//            },
//            set: { value in
//                if value {
//                    // If true call didSelectTab
//                    didSelectTab
//                }
//            })
//    }
//    
//    
//    var body: some View {
//        TabView(
//            title: <#T##Binding<String>#>,
//            open: <#T##Binding<Bool>#>,
//            selected: <#T##Binding<Bool>#>)
//    }
//    
//}
//
//#Preview {
//    CodeTabView(
//        codeViewModel: CodeViewModel(filepath: "~/Downloads/test_dir/testing.txt"),
//    )
//}
