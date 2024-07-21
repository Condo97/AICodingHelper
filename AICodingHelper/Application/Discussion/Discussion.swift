//
//  Discussion.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import Foundation


class Discussion: ObservableObject, Identifiable {
    
    var id = UUID()
    
    @Published var chats: [Chat]
    
    init(chats: [Chat]) {
        self.chats = chats
    }
    
}
