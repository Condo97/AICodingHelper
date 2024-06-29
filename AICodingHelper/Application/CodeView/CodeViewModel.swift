//
//  CodeViewModel.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/28/24.
//

import Foundation
import SwiftUI

class CodeViewModel: ObservableObject {
    
    @Published var filepath: String?
    @Published var openedFileText: String = ""
    @Published var openedFileTextSelection: Range<String.Index> = "".startIndex..<"".endIndex
    
    
    init(filepath: String?) {
        self.filepath = filepath
    }
    
    
}
