//
//  CSVExportProfile Export.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import AVFoundation
import CodableCSV
import Foundation
import Logging
import OrderedCollections
import TimecodeKit

extension CSVExportProfile {
    public static func export(
        markers: [Marker],
        idMode: MarkerIDMode,
        csvPath: URL,
        videoPath: URL,
        outputPath: URL,
        imageSettings: ExportImageSettings<Field>
    ) throws {
        try export(
            markers: markers,
            idMode: idMode,
            videoPath: videoPath,
            outputPath: outputPath,
            payload: Payload(csvPath: csvPath),
            imageSettings: imageSettings
        )
    }
    
    public static func prepareMarkers(
        markers: [Marker],
        idMode: MarkerIDMode,
        payload: Payload,
        imageSettings: ExportImageSettings<Field>,
        isSingleFrame: Bool
    ) -> [PreparedMarker] {
        markers.map {
            PreparedMarker(
                $0,
                idMode: idMode,
                imageFormat: imageSettings.format,
                isSingleFrame: isSingleFrame
            )
        }
    }
    
    public static func writeManifest(
        _ preparedMarkers: [PreparedMarker],
        payload: Payload
    ) throws {
        let rows = dictsToRows(preparedMarkers)
        let csvData = try CSVWriter.encode(rows: rows, into: Data.self)
        try csvData.write(to: payload.csvPath)
    }
    
    // MARK: Helpers
    
    private static func dictsToRows(
        _ preparedMarkers: [PreparedMarker]
    ) -> [[String]] {
        let dicts = preparedMarkers.map { $0.dictionaryRepresentation() }
        guard !dicts.isEmpty else { return [] }
        
        var result = [Array(dicts[0].keys.map { $0.name })]
        
        for row in dicts {
            result += [Array(row.values)]
        }
        
        return result
    }
}