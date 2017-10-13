//
//  SelectedLines.swift
//  multilineCommentExtension
//
//  Created by Andrew Vanyurin on 13/10/2017.
//  Copyright © 2017 Andrew Vanyurin. All rights reserved.
//

import Foundation
import XcodeKit

class SelectedLines: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        for selection in invocation.buffer.selections {
            guard let selection = selection as? XCSourceTextRange,
                  var startString = invocation.buffer.lines[selection.start.line] as? String,
                  var endString = invocation.buffer.lines[selection.end.line] as? String
            else { return }

            startString = Constants.startSymbolWithSpase + startString
            invocation.buffer.lines[selection.start.line] = startString
            if selection.start.line == selection.end.line {
                endString = startString
            }
            endString = String(endString.characters.filter { !"\n".characters.contains($0) })
            invocation.buffer.lines[selection.end.line] = endString + Constants.endSymbolWithSpase
        }
        
        completionHandler(nil)
    }
    
}
