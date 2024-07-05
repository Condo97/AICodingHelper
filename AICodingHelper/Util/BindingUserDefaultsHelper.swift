//
//  BindingUserDefaultsHelper.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 7/3/24.
//

import Foundation
import SwiftUI


class BindingUserDefaultsHelper {
    
    static var generateOptionCopyCurrentFilesToTempFile: Binding<Bool> {
        Binding(
            get: {
                UserDefaultsHelper.generateOptionCopyCurrentFilesToTempFile
            },
            set: { value in
                UserDefaultsHelper.generateOptionCopyCurrentFilesToTempFile = value
            })
    }
    
    static var generateOptionUseEntireProjectAsContext: Binding<Bool> {
        Binding(
            get: {
                UserDefaultsHelper.generateOptionUseEntireProjectAsContext
            },
            set: { value in
                UserDefaultsHelper.generateOptionUseEntireProjectAsContext = value
            })
    }
    
}
