//
//  DecommentLines.swift
//  multilineCommentExtension
//
//  Created by Andrew Vanyurin on 13/10/2017.
//  Copyright © 2017 Andrew Vanyurin. All rights reserved.
//

import Foundation
import XcodeKit

class DecommentLines: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        for selection in invocation.buffer.selections {
            guard let selection = selection as? XCSourceTextRange,
                  var startString = invocation.buffer.lines[selection.start.line] as? String,
                  var endString = invocation.buffer.lines[selection.end.line] as? String
            else { return }
            
            startString = startString.replacingOccurrences(of: "/*", with: "  ", options: .literal, range: nil)
            startString = startString.replacingOccurrences(of: "*/", with: "  ", options: .literal, range: nil)
            
            endString = endString.replacingOccurrences(of: "/*", with: "  ", options: .literal, range: nil)
            endString = endString.replacingOccurrences(of: "*/", with: "  ", options: .literal, range: nil)
            
            invocation.buffer.lines[selection.start.line] = startString
            invocation.buffer.lines[selection.end.line] = endString
        }
        
        completionHandler(nil)
    }
    
}
