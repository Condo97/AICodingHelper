//
//  FocusViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import Foundation


class FocusViewModel: ObservableObject {
    
    @Published var focus: FocusableContent = .browser
    
}
