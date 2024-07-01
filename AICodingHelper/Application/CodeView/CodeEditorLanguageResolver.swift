//
//  CodeEditorLanguageResolver.swift
//  AICodingHelper
//
//  Created by Alex Coundouriotis on 6/26/24.
//

import CodeEditor
import Foundation

class CodeEditorLanguageResolver {
  
  private static let extensionToLanguageMap: [String: CodeEditor.Language] = [
    "log": .accesslog,
    "as": .actionscript,
    "adb": .ada, "ads": .ada,
    "conf": .apache,
    "applescript": .applescript,
    "sh": .bash,
    "bas": .basic,
    "c": .c,
    "cpp": .cpp, "cc": .cpp, "cxx": .cpp,
    "cs": .cs,
    "css": .css,
    "diff": .diff,
    "dockerfile": .dockerfile,
    "go": .go,
    "http": .http,
    "java": .java,
    "js": .javascript,
    "json": .json,
    "lua": .lua,
    "md": .markdown,
    "Makefile": .makefile,
    "nginxconf": .nginx,
    "m": .objectivec,
    "pgsql": .pgsql,
    "php": .php,
    "py": .python,
    "rb": .ruby,
    "rs": .rust,
    "bash": .shell,
    "st": .smalltalk,
    "sql": .sql,
    "swift": .swift,
    "tcl": .tcl,
    "tex": .tex,
    "twig": .twig,
    "ts": .typescript,
    "vb": .vbnet,
    "vbs": .vbscript,
    "xml": .xml,
    "yaml": .yaml, "yml": .yaml,
  ]
    
    // List of all languages
    static var allLanguages: [CodeEditor.Language?] {
        [
          .accesslog, .actionscript, .ada, .apache, .applescript, .bash,
          .basic, .brainfuck, .c, .cpp, .cs, .css, .diff, .dockerfile,
          .go, .http, .java, .javascript, .json, .lua, .markdown,
          .makefile, .nginx, .objectivec, .pgsql, .php, .python, .ruby,
          .rust, .shell, .smalltalk, .sql, .swift, .tcl, .tex, .twig,
          .typescript, .vbnet, .vbscript, .xml, .yaml
        ]
    }
  
  static func language(for fileExtension: String) -> CodeEditor.Language {
      return extensionToLanguageMap[fileExtension] ?? .tex
  }
}
