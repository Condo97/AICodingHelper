//
//  Chat.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/20/24.
//

import Foundation


class Chat: ObservableObject, Identifiable, Equatable {
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
    
    var id = UUID()
    
    @Published var role: CompletionRole
    @Published var message: Any
    @Published var referenceFilepaths: [String]?
    
    init(role: CompletionRole, message: Any, referenceFilepaths: [String]? = nil) {
        self.role = role
        self.message = message
        self.referenceFilepaths = referenceFilepaths
    }
    
}
