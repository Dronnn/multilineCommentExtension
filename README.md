# Multiline Comment Extension

An Xcode Source Editor Extension for macOS that adds `/* */` block commenting to Xcode. Xcode only provides `//` line comments out of the box -- this extension fills the gap.

## Commands

### Comment Selection

Wraps the selected text with `/* */` inline (on the same lines).

Single line:
```
let x = 1
```
becomes:
```
/* let x = 1 */
```

Multiple lines: `/*` is inserted at the start of the first selected line, `*/` at the end of the last selected line.

### Block Comment

Inserts `/*` on a new line above the selection and `*/` on a new line below.

```
/*
let x = 1
let y = 2
*/
```

### Uncomment

Removes `/*` and `*/` markers from the selection. Works for both inline and block comment styles.

## Installation

1. Build the project in Xcode (`Cmd+B`)
2. Run the app (`Cmd+R`)
3. Go to **System Settings > Privacy & Security > Extensions > Xcode Source Editor**
4. Enable **multilineComment**
5. Restart Xcode
6. The commands appear under **Editor > multilineComment**

## Usage

1. Select text in Xcode
2. Go to **Editor > multilineComment** and choose a command

**Tip:** Assign keyboard shortcuts via **Xcode > Settings > Key Bindings** -- search for "multilineComment".

## Requirements

- macOS 10.12+
- Xcode 9+
