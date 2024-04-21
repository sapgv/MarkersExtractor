//
//  TXTProfile Export.swift
//
//
//  Created by Grigory Sapogov on 21.04.2024.
//

import AVFoundation
import Foundation
import Logging
import OrderedCollections
import TextFileKit
import TimecodeKit

extension TXTProfile {
    public func prepareMarkers(
        markers: [Marker],
        idMode: MarkerIDMode,
        tcStringFormat: Timecode.StringFormat,
        payload: Payload,
        mediaInfo: ExportMarkerMediaInfo?
    ) -> [PreparedMarker] {
        markers.map {
            PreparedMarker(
                $0,
                idMode: idMode,
                mediaInfo: mediaInfo, tcStringFormat: tcStringFormat
            )
        }
    }
    
    public func writeManifests(
        _ preparedMarkers: [PreparedMarker],
        payload: Payload,
        noMedia: Bool
    ) throws {
        try txtWriteManifest(
            txtPath: payload.txtPath,
            noMedia: noMedia,
            preparedMarkers
        )
    }
    
    public func resultFileContent(payload: Payload) throws -> ExportResult.ResultDictionary {
        [
            .txtManifestPath: .url(payload.txtPath)
        ]
    }
    
    public func tableManifestFields(
        for marker: PreparedMarker,
        noMedia: Bool
    ) -> OrderedDictionary<ExportField, String> {
        var dict: OrderedDictionary<ExportField, String> = [:]
        
        dict[.position] = marker.position
        dict[.name] = marker.name
        
//        dict[.id] = marker.id
//        dict[.name] = marker.name
//        dict[.type] = marker.type
//        dict[.checked] = marker.checked
//        dict[.status] = marker.status
//        dict[.notes] = marker.notes
//        dict[.position] = marker.position
//        dict[.clipType] = marker.clipType
//        dict[.clipName] = marker.clipName
//        dict[.clipDuration] = marker.clipDuration
//        dict[.videoRole] = marker.videoRole
//        dict[.audioRole] = marker.audioRole.flat
//        dict[.eventName] = marker.eventName
//        dict[.projectName] = marker.projectName
//        dict[.libraryName] = marker.libraryName
//         no iconImage
        
//        if !noMedia {
//            dict[.imageFileName] = marker.imageFileName
//        }
        
        return dict
    }
    
    public func nestedManifestFields(
        for marker: PreparedMarker,
        noMedia: Bool
    ) -> OrderedDictionary<ExportField, ExportFieldValue> {
        var dict: OrderedDictionary<ExportField, ExportFieldValue> = [:]
        
        dict[.id] = .string(marker.id)
        dict[.name] = .string(marker.name)
        dict[.type] = .string(marker.type)
        dict[.checked] = .string(marker.checked)
        dict[.status] = .string(marker.status)
        dict[.notes] = .string(marker.notes)
        dict[.position] = .string(marker.position)
        dict[.clipType] = .string(marker.clipType)
        dict[.clipName] = .string(marker.clipName)
        dict[.clipDuration] = .string(marker.clipDuration)
        dict[.videoRole] = .string(marker.videoRole)
        dict[.audioRole] = .array(marker.audioRole.array)
        dict[.eventName] = .string(marker.eventName)
        dict[.projectName] = .string(marker.projectName)
        dict[.libraryName] = .string(marker.libraryName)
        // no iconImage
        
        if !noMedia {
            dict[.imageFileName] = .string(marker.imageFileName)
        }
        
        return dict
    }
    
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
