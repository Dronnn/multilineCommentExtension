import Foundation
import XcodeKit

// MARK: - Comment Selection (inline)

class CommentSelection: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer

        for selectionIndex in 0..<buffer.selections.count {
            guard let selection = buffer.selections[selectionIndex] as? XCSourceTextRange else { continue }

            let startLine = selection.start.line
            let endLine = selection.end.line

            guard startLine >= 0, startLine < buffer.lines.count else { continue }

            // Single line, no column range (cursor on a line) — wrap entire line
            if startLine == endLine && selection.start.column == 0 && selection.end.column == 0 {
                guard let line = buffer.lines[startLine] as? String else { continue }
                let stripped = line.hasSuffix("\n") ? String(line.dropLast()) : line
                buffer.lines[startLine] = "/* \(stripped) */\n"
                selection.end.column = ("/* \(stripped) */").count
                continue
            }

            if startLine == endLine {
                // Single-line selection with column range
                guard let line = buffer.lines[startLine] as? String else { continue }
                var chars = Array(line)
                let insertEnd = min(selection.end.column, chars.count)
                let insertStart = min(selection.start.column, chars.count)

                let suffixChars = Array(" */")
                chars.insert(contentsOf: suffixChars, at: insertEnd)

                let prefixChars = Array("/* ")
                chars.insert(contentsOf: prefixChars, at: insertStart)

                buffer.lines[startLine] = String(chars)
                selection.end.column = insertEnd + prefixChars.count + suffixChars.count
            } else {
                // Multi-line selection
                guard endLine < buffer.lines.count else { continue }

                // Wrap last line end with */
                if let lastLine = buffer.lines[endLine] as? String {
                    let stripped = lastLine.hasSuffix("\n") ? String(lastLine.dropLast()) : lastLine
                    buffer.lines[endLine] = "\(stripped) */\n"
                    selection.end.column = ("\(stripped) */").count
                }

                // Wrap first line start with /*
                if let firstLine = buffer.lines[startLine] as? String {
                    buffer.lines[startLine] = "/* \(firstLine)"
                }
            }
        }

        completionHandler(nil)
    }
}

// MARK: - Block Comment (new lines above/below)

class BlockComment: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer

        for selectionIndex in 0..<buffer.selections.count {
            guard let selection = buffer.selections[selectionIndex] as? XCSourceTextRange else { continue }

            var startLine = selection.start.line
            var endLine = selection.end.line

            // Edge case: Xcode places cursor at column 0 of the line after the selection
            if selection.start.column == 0 && selection.end.column == 0 && startLine < endLine {
                endLine -= 1
            }

            guard startLine >= 0, endLine >= startLine, endLine < buffer.lines.count else { continue }

            buffer.lines.insert("/*\n", at: startLine)
            buffer.lines.insert("*/\n", at: endLine + 2)
        }

        completionHandler(nil)
    }
}

// MARK: - Uncomment

class Uncomment: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) {
        let buffer = invocation.buffer

        for selectionIndex in 0..<buffer.selections.count {
            guard let selection = buffer.selections[selectionIndex] as? XCSourceTextRange else { continue }

            let startLine = selection.start.line
            var endLine = selection.end.line

            guard startLine >= 0, startLine < buffer.lines.count else { continue }
            guard endLine >= startLine, endLine < buffer.lines.count else { continue }

            let startLineContent = (buffer.lines[startLine] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let endLineContent = (buffer.lines[endLine] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

            // Check for block comment (/* and */ on their own lines)
            if startLineContent == "/*" && endLineContent == "*/" {
                buffer.lines.removeObject(at: endLine)
                buffer.lines.removeObject(at: startLine)
                continue
            }

            // Check if */ is on the line before end (for edge cases)
            if startLineContent == "/*" && endLine - 1 >= 0 {
                let prevLineContent = (buffer.lines[endLine - 1] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                if prevLineContent == "*/" {
                    buffer.lines.removeObject(at: endLine - 1)
                    buffer.lines.removeObject(at: startLine)
                    continue
                }
            }

            // Inline comment removal
            if let firstLine = buffer.lines[startLine] as? String {
                var modified = firstLine
                if let range = modified.range(of: "/* ") {
                    modified.removeSubrange(range)
                } else if let range = modified.range(of: "/*") {
                    modified.removeSubrange(range)
                }
                buffer.lines[startLine] = modified
            }

            // Recalculate endLine index (it hasn't changed for inline)
            endLine = min(endLine, buffer.lines.count - 1)
            if let lastLine = buffer.lines[endLine] as? String {
                var modified = lastLine
                if let range = modified.range(of: " */", options: .backwards) {
                    modified.removeSubrange(range)
                } else if let range = modified.range(of: "*/", options: .backwards) {
                    modified.removeSubrange(range)
                }
                buffer.lines[endLine] = modified
            }
        }

        completionHandler(nil)
    }
}
