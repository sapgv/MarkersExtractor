//
//  ExportProfile Export.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import AVFoundation
import Foundation
import Logging
import OrderedCollections
import TimecodeKit

extension ExportProfile {
    public static func export(
        markers: [Marker],
        idMode: MarkerIDMode,
        videoPath: URL,
        outputPath: URL,
        payload: Payload,
        imageSettings: ExportImageSettings<Field>,
        createDoneFile: Bool,
        doneFilename: String
    ) throws {
        let logger = Logger(label: "markersExport")
        
        var videoPath: URL = videoPath
        let videoPlaceholder: TemporaryMediaFile
        
        let isVideoPresent = isVideoPresent(in: videoPath)
        let isSingleFrame = !isVideoPresent
            && imageSettings.labelFields.isEmpty
            && imageSettings.labelCopyright == nil
        
        if !isVideoPresent {
            logger.info("Media file has no video track, using video placeholder for markers.")
            
            if let markerVideoPlaceholderData = EmbeddedResource.marker_video_placeholder_mov.data {
                videoPlaceholder = try TemporaryMediaFile(withData: markerVideoPlaceholderData)
                videoPath = videoPlaceholder.url!
            } else {
                logger.warning("Could not locate or read video placeholder file.")
            }
        }
        
        // prepare markers
        
        let preparedMarkers = prepareMarkers(
            markers: markers,
            idMode: idMode,
            payload: payload,
            imageSettings: imageSettings,
            isSingleFrame: isSingleFrame
        )
        
        // icons
        
        logger.info("Exporting marker icons.")
        
        do {
            try exportIcons(from: markers, to: outputPath)
        } catch {
            throw MarkersExtractorError.runtimeError("Failed to write marker icons.")
        }
        
        // thumbnail images
        
        logger.info("Generating \(imageSettings.format.rawValue.uppercased()) images for markers.")
        
        let imageLabelText = makeImageLabelText(
            preparedMarkers: preparedMarkers,
            imageLabelFields: imageSettings.labelFields,
            imageLabelCopyright: imageSettings.labelCopyright,
            includeHeaders: !imageSettings.imageLabelHideNames
        )
        
        let timecodes = makeTimecodes(
            markers: markers,
            preparedMarkers: preparedMarkers,
            isVideoPresent: isVideoPresent,
            isSingleFrame: isSingleFrame
        )
        
        switch imageSettings.format {
        case let .still(stillImageFormat):
            try writeStillImages(
                timecodes: timecodes,
                video: videoPath,
                outputPath: outputPath,
                imageFormat: stillImageFormat,
                imageJPGQuality: imageSettings.quality,
                imageDimensions: imageSettings.dimensions,
                imageLabelText: imageLabelText,
                imageLabelProperties: imageSettings.labelProperties
            )
        case let .animated(animatedImageFormat):
            try writeAnimatedImages(
                timecodes: timecodes,
                video: videoPath,
                outputPath: outputPath,
                gifFPS: imageSettings.gifFPS,
                gifSpan: imageSettings.gifSpan,
                gifDimensions: imageSettings.dimensions,
                imageFormat: animatedImageFormat,
                imageLabelText: imageLabelText,
                imageLabelProperties: imageSettings.labelProperties
            )
        }
        
        // metadata manifest file
        
        try writeManifest(preparedMarkers, payload: payload)
        
        // done file
        
        if createDoneFile {
            logger.info("Creating \(doneFilename.quoted) done file at \(outputPath.path.quoted).")
            let doneFileData = try doneFileContent(payload: payload)
            try saveDoneFile(at: outputPath, fileName: doneFilename, data: doneFileData)
        }
    }
    
    // MARK: Helpers
    
    private static func makeImageLabelText(
        preparedMarkers: [PreparedMarker],
        imageLabelFields: [Field],
        imageLabelCopyright: String?,
        includeHeaders: Bool
    ) -> [String] {
        var imageLabelText: [String] = []
        
        if !imageLabelFields.isEmpty {
            imageLabelText.append(
                contentsOf: makeLabels(
                    headers: imageLabelFields,
                    includeHeaders: includeHeaders,
                    preparedMarkers: preparedMarkers
                )
            )
        }
        
        if let copyrightText = imageLabelCopyright {
            if imageLabelText.isEmpty {
                imageLabelText = preparedMarkers.map { _ in copyrightText }
            } else {
                imageLabelText = imageLabelText.map { "\($0)\n\(copyrightText)" }
            }
        }
        
        return imageLabelText
    }
    
    private static func makeLabels(
        headers: [Field],
        includeHeaders: Bool,
        preparedMarkers: [PreparedMarker]
    ) -> [String] {
        preparedMarkers
            .map { manifestFields(for: $0) }
            .map { markerDict in
                headers
                    .map {
                        (includeHeaders ? "\($0.name): " : "")
                            + "\(markerDict[$0] ?? "")"
                    }
                    .joined(separator: "\n")
            }
    }
    
    /// Returns an ordered dictionary keyed by marker image filename with a value of timecode
    /// position.
    private static func makeTimecodes(
        markers: [Marker],
        preparedMarkers: [PreparedMarker],
        isVideoPresent: Bool,
        isSingleFrame: Bool
    ) -> OrderedDictionary<String, Timecode> {
        let imageFileNames = preparedMarkers.map { $0.imageFileName }
        
        // if no video - grabbing first frame from video placeholder
        let markerTimecodes = markers.map {
            isVideoPresent ? $0.position : .init(at: $0.frameRate())
        }
        
        var markerPairs = zip(imageFileNames, markerTimecodes).map { ($0, $1) }
        
        // if no video and no labels - only one frame needed for all markers
        if isSingleFrame {
            markerPairs = [markerPairs[0]]
        }
        
        return OrderedDictionary(uniqueKeysWithValues: markerPairs)
    }
    
    private static func exportIcons(from markers: [Marker], to outputDir: URL) throws {
        let icons = Set(markers.map { Icon($0.type) })
        
        for icon in icons {
            if icon is EmptyExportIcon { continue }
            let targetURL = outputDir.appendingPathComponent(icon.fileName)
            try icon.data.write(to: targetURL)
        }
    }
    
    private static func saveDoneFile(
        at outputPath: URL,
        fileName: String,
        data: Data
    ) throws {
        let doneFile = outputPath.appendingPathComponent(fileName)
        
        do {
            try data.write(to: doneFile)
        } catch {
            throw MarkersExtractorError.runtimeError(
                "Failed to create done file \(doneFile.path.quoted): \(error.localizedDescription)"
            )
        }
    }
    
    private static func isVideoPresent(in videoPath: URL) -> Bool {
        let asset = AVAsset(url: videoPath)
        
        return asset.firstVideoTrack != nil
    }
}
