//
//  TXT Export Utils.swift
//
//
//  Created by Grigory Sapogov on 21.04.2024.
//

import Foundation
import OrderedCollections
import TextFileKit

extension ExportProfile {
    func txtWriteManifest(
        txtPath: URL,
        noMedia: Bool,
        _ preparedMarkers: [PreparedMarker]
    ) throws {
        let rows = dictsToRows(preparedMarkers, noMedia: noMedia)
        
        guard let txtData = TextFile.TXT(table: rows).rawText.data(using: .utf8)
        else {
            throw MarkersExtractorError.extraction(.fileWrite(
                "Could not encode TXT file."
            ))
        }
        
        try txtData.write(to: txtPath)
    }
    
}

public extension TextFile {
    
    // tested with Google Sheets, Microsoft Excel, and Apple Numbers
    
    /// TSV (Tab-Separated Values) text file format.
    struct TXT: StringArrayTableRepresentable {
        // MARK: - Constants
        
        internal static let sepChar: Character = " "
        internal static let newLineChar: Character = "\n"
        
        public static let fileExtension = "txt"
        
        // MARK: - Variables
        
        public var table: StringTable = []
        
        // MARK: - Init
        
        public init(table: StringTable = []) {
            self.table = table
        }
        
        public init(rawText: String) {
            table = Self.parseTXT(text: rawText)
        }
        
        // MARK: - RawText
        
        public var rawText: String {
            table.map { row in
                row.map { textString in
                    var outString = textString
                    var needsQuoteWrapping = false
                    
                    // wrap string in double-quotes if it contains a tab or a newline
                    if outString.contains("\t")
                        || outString.contains(Self.newLineChar)
                    { needsQuoteWrapping = true }
                    
                    // escape double-quotes
                    // (only necessary if the string needs to be wrote-wrapped for another reason (ie: string contains a tab char))
                    if outString.contains("\""),
                       needsQuoteWrapping
                    {
                        outString = outString.replacingOccurrences(of: "\"", with: "\"\"")
                    }
                    
                    if needsQuoteWrapping {
                        outString = outString.quoted
                    }
                    
                    return outString
                }
                .joined(separator: String(Self.sepChar))
            }
            .joined(separator: String(Self.newLineChar))
        }
    }
}

extension TextFile.TXT {
    internal static func parseTXT(text: String) -> StringTable {
        // prep
        
        let text = text + String(newLineChar) // append newline to assist the parser
        
        var result: StringTable = []
        
        // flags and registers
        var quoteOpen = false
        var previousCharWasMidstreamQuote = false
        var fieldString = ""
        var record: [String] = []
        
        // parse
        
        for char in text {
            // helpers
            
            func closeField() {
                record.append(fieldString)
                fieldString = ""
                quoteOpen = false
            }
            
            func closeRecord() {
                // if empty line, don't add it
                if record.count == 1, record[0] == "" {
                    record = []
                    return
                }
                
                if !record.isEmpty {
                    result.append(record)
                    record = []
                }
            }
            
            // char
            
            switch char {
            case sepChar:
                // close quoted field if preceding char was a quote
                if previousCharWasMidstreamQuote == true { quoteOpen = false }
                
                // close field, if we're not in the middle of a quoted field
                if !quoteOpen {
                    closeField()
                } else {
                    fieldString.append(char)
                }
                
                previousCharWasMidstreamQuote = false
                
            case "\"":
                // consider it a quoted field if a quote is the first character
                if !quoteOpen, fieldString.isEmpty {
                    quoteOpen = true
                    continue
                }
                
                if !fieldString.isEmpty {
                    if quoteOpen {
                        if previousCharWasMidstreamQuote {
                            fieldString += "\""
                            previousCharWasMidstreamQuote = false
                        } else {
                            previousCharWasMidstreamQuote = true
                        }
                    } else {
                        fieldString.append(char)
                        previousCharWasMidstreamQuote = false
                    }
                }
                
            case newLineChar:
                // close record, if we're not in the middle of a quoted field
                if !quoteOpen || (quoteOpen && previousCharWasMidstreamQuote) {
                    closeField()
                    closeRecord()
                } else {
                    fieldString.append(char)
                }
                
                previousCharWasMidstreamQuote = false
                
            default:
                fieldString.append(char)
                
                previousCharWasMidstreamQuote = false
            }
        }
        
        // return
        
        return result
    }
}
