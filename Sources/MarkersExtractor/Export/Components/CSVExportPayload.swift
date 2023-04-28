//
//  CSVExportPayload.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import Foundation

public struct CSVExportPayload: ExportPayload {
    let csvPath: URL
        
    init(projectName: String, outputURL: URL) {
        let csvName = "\(projectName).csv"
        csvPath = outputURL.appendingPathComponent(csvName)
    }
}
