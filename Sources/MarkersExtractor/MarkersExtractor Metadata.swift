//
//  MarkersExtractor Metadata.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import Foundation
import DAWFileKit
import TimecodeKit

extension MarkersExtractor {
    func startTimecode(forProject project: FinalCutPro.FCPXML.Project) -> Timecode {
        if let tc = project.startTimecode {
            logger.info("Project start timecode: \(tc.stringValue(format: timecodeStringFormat)) @ \(tc.frameRate.stringValueVerbose).")
            return tc
        } else if let frameRate = project.frameRate {
            let tc = Timecode(.zero, at: frameRate, base: .max100SubFrames)
            logger.warning(
                "Could not determine project start timecode. Defaulting to \(tc.stringValue(format: timecodeStringFormat)) @ \(tc.frameRate.stringValueVerbose)."
            )
            return tc
        } else {
            let tc = Timecode(.zero, at: .fps30, base: .max100SubFrames)
            logger.warning(
                "Could not determine project start timecode. Defaulting to \(tc.stringValue(format: timecodeStringFormat)) @ \(tc.frameRate.stringValueVerbose)."
            )
            return tc
        }
    }
    
    var timecodeStringFormat: Timecode.StringFormat {
        s.enableSubframes ? [.showSubFrames] : .default()
    }
}

extension MarkersExtractor {
    static let elementContext: FCPXMLElementContextBuilder = .group([
        .default,
        MarkerContext()
    ])
    
    struct MarkerContext: FCPXMLElementContextBuilder {
        init() { }
        
        var contextBuilder: FinalCutPro.FCPXML.ElementContextClosure {
            { xmlLeaf, resources, tools in
                var dict: FinalCutPro.FCPXML.ElementContext = [:]
                
                dict[.resource] = tools.resource
                dict[.mediaFilename] = tools.mediaURL?.lastPathComponent
                
                return dict
            }
        }
    }
}
// MARK: - Dictionary Keys

extension FinalCutPro.FCPXML.ContextKey {
    fileprivate enum Key: String {
        case resource
        case mediaFilename
    }
    
    /// The absolute start timecode of the element.
    public static var resource: FinalCutPro.FCPXML.ContextKey<FinalCutPro.FCPXML.AnyResource> {
        .init(key: Key.resource)
    }
    
    public static var mediaFilename: FinalCutPro.FCPXML.ContextKey<String> {
        .init(key: Key.mediaFilename)
    }
}
