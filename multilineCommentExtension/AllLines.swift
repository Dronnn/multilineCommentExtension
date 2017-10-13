//
//  AllLines.swift
//  multilineCommentExtension
//
//  Created by Andrew Vanyurin on 13/10/2017.
//  Copyright © 2017 Andrew Vanyurin. All rights reserved.
//

import Foundation
import XcodeKit

class AllLines: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        invocation.buffer.lines.insert(Constants.startSymbol, at: 0)
        invocation.buffer.lines.insert(Constants.endSymbol, at: invocation.buffer.lines.count)
        
        completionHandler(nil)
    }
    
}
