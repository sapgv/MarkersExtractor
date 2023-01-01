//
//  ExportProfile.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import Foundation
import OrderedCollections

public protocol ExportProfile
    where PreparedMarker.Field == Field
{
    associatedtype Field: ExportField
    associatedtype Payload: ExportPayload
    associatedtype PreparedMarker: ExportMarker
    associatedtype Icon: ExportIcon
    
    /// Exports markers to disk.
    /// Writes metadata files, images, and any other resources necessary.
    static func export(
        markers: [Marker],
        idMode: MarkerIDMode,
        videoPath: URL,
        outputPath: URL,
        payload: Payload,
        imageSettings: ExportImageSettings<Field>,
        createDoneFile: Bool,
        doneFilename: String
    ) throws
    
    /// Converts raw FCP markers to the native format needed for export.
    static func prepareMarkers(
        markers: [Marker],
        idMode: MarkerIDMode,
        payload: Payload,
        imageSettings: ExportImageSettings<Field>,
        isSingleFrame: Bool
    ) -> [PreparedMarker]
    
    /// Encode and write metadata manifest file to disk. (Such as csv file)
    static func writeManifest(
        _ preparedMarkers: [PreparedMarker],
        payload: Payload
    ) throws
    
    static func doneFileContent(payload: Payload) throws -> Data
    
    static func manifestFields(for marker: PreparedMarker) -> OrderedDictionary<Field, String>
}
