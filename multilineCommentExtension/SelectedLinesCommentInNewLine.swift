//
//  SelectedLinesCommentInNewLine.swift
//  multilineCommentExtension
//
//  Created by Andrew Vanyurin on 13/10/2017.
//  Copyright © 2017 Andrew Vanyurin. All rights reserved.
//

import Foundation
import XcodeKit

class SelectedLinesCommentInNewLine: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        for selection in invocation.buffer.selections {
            guard let selection = selection as? XCSourceTextRange
            else { return }

            let startLine = selection.start.line
            var endLine = selection.end.line
            
            //fix of wrong incoming columns
            if selection.start.column == 0 &&
                selection.end.column == 0 &&
                selection.start.line == selection.end.line {
                endLine += 2
            } else if selection.start.column == 0 &&
                selection.end.column == 0 &&
                selection.start.line < selection.end.line {
                endLine += 1
            } else if selection.start.line < selection.end.line {
                endLine += 2
            } else {
                endLine += 2
            }
            
            invocation.buffer.lines.insert(Constants.startSymbol, at: startLine)
            invocation.buffer.lines.insert(Constants.endSymbol, at: endLine)
        }
        
        completionHandler(nil)
    }
    
}
