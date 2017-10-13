//
//  SelectedRange.swift
//  multilineCommentExtension
//
//  Created by Andrew Vanyurin on 13/10/2017.
//  Copyright © 2017 Andrew Vanyurin. All rights reserved.
//

import Foundation
import XcodeKit

class SelectedRange: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        for selection in invocation.buffer.selections {
            guard let selection = selection as? XCSourceTextRange,
                  var startString = invocation.buffer.lines[selection.start.line] as? String,
                  selection.end.line == selection.start.line,
                  selection.end.column - selection.start.column > 0
            else {
                completionHandler(nil)
                return
            }

            let from = startString.index(startString.startIndex, offsetBy: selection.start.column)
            let to = startString.index(startString.startIndex, offsetBy: selection.end.column)
            
            let selectedSubstring = startString[from ..< to]
            let newString = Constants.startSymbolWithSpase + selectedSubstring + Constants.endSymbolWithSpase
            
            startString.replaceSubrange(from ..< to, with: newString)
            
            invocation.buffer.lines[selection.start.line] = startString
            selection.end.column += Constants.startSymbolWithSpase.count + Constants.endSymbolWithSpase.count
        }
        
        completionHandler(nil)
    }
    
}
