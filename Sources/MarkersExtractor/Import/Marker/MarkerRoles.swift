//
//  MarkerRole.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import Foundation
import DAWFileKit

/// Marker Roles for an element.
///
/// Note that role names cannot include a dot (`.`) or a question mark (`?`).
/// This is enforced by Final Cut Pro because they are reserved characters for encoding the string
/// in FCPXML.
public struct MarkerRoles: Equatable, Hashable, Sendable {
    public var video: FinalCutPro.FCPXML.VideoRole?
    public var isVideoDefault: Bool
    
    public var audio: FinalCutPro.FCPXML.AudioRole?
    public var isAudioDefault: Bool
    
    public var caption: FinalCutPro.FCPXML.CaptionRole?
    public var isCaptionDefault: Bool
    
    // TODO: add caption role
    
    public init(
        video: FinalCutPro.FCPXML.VideoRole? = nil,
        isVideoDefault: Bool = false,
        audio: FinalCutPro.FCPXML.AudioRole? = nil,
        isAudioDefault: Bool = false,
        caption: FinalCutPro.FCPXML.CaptionRole? = nil,
        isCaptionDefault: Bool = false,
        collapseSubroles: Bool = false
    ) {
        if collapseSubroles {
            self.video = video?.collapsedSubRole()
        } else {
            self.video = video
        }
        self.isVideoDefault = isVideoDefault
        
        if collapseSubroles {
            self.audio = audio?.collapsedSubRole()
        } else {
            self.audio = audio
        }
        self.isAudioDefault = isAudioDefault
        
        // caption sub-roles can't be collapsed because they only have a main role
        self.caption = caption
        self.isCaptionDefault = isCaptionDefault
    }
    
    @_disfavoredOverload
    public init(
        video rawVideoRole: String? = nil,
        isVideoDefault: Bool = false,
        audio rawAudioRole: String? = nil,
        isAudioDefault: Bool = false,
        caption rawCaptionRole: String? = nil,
        isCaptionDefault: Bool = false,
        collapseSubroles: Bool = false
    ) {
        var videoRole: FinalCutPro.FCPXML.VideoRole? = nil
        if let rawVideoRole = rawVideoRole {
            videoRole = FinalCutPro.FCPXML.VideoRole(rawValue: rawVideoRole)
        }
        
        var audioRole: FinalCutPro.FCPXML.AudioRole? = nil
        if let rawAudioRole = rawAudioRole {
            audioRole = FinalCutPro.FCPXML.AudioRole(rawValue: rawAudioRole)
        }
        
        var captionRole: FinalCutPro.FCPXML.CaptionRole? = nil
        if let rawCaptionRole = rawCaptionRole {
            captionRole = FinalCutPro.FCPXML.CaptionRole(rawValue: rawCaptionRole)
        }
        
        self.init(
            video: videoRole,
            isVideoDefault: isVideoDefault,
            audio: audioRole,
            isAudioDefault: isAudioDefault,
            caption: captionRole,
            isCaptionDefault: isCaptionDefault,
            collapseSubroles: collapseSubroles
        )
    }
}

// MARK: - Convenience Properties

extension MarkerRoles {
    /// Has a non-empty video role.
    public var isVideoEmpty: Bool {
        video == nil || video?.rawValue.isEmpty == true
    }
    
    /// Has a defined (non-default) video role.
    public var isVideoDefined: Bool {
        !isVideoEmpty && !isVideoDefault
    }
    
    /// Has a non-empty audio role.
    public var isAudioEmpty: Bool {
        audio == nil || audio?.rawValue.isEmpty == true
    }
    
    /// Has a defined (non-default) audio role.
    public var isAudioDefined: Bool {
        !isAudioEmpty && !isAudioDefault
    }
    
    /// Has a non-empty caption role.
    public var isCaptionEmpty: Bool {
        caption == nil || caption?.rawValue.isEmpty == true
    }
    
    /// Has a defined (non-default) caption role.
    public var isCaptionDefined: Bool {
        !isCaptionEmpty && !isCaptionDefault
    }
}

// MARK: - String Formatting

extension MarkerRoles {
    static let notAssignedRoleString = "Not Assigned"
    
    /// Video role formatted for user display.
    public func videoFormatted() -> String {
        if let video = video, !video.rawValue.isEmpty {
            return video.rawValue
        }
        return Self.notAssignedRoleString
    }
    
    /// Audio role formatted for user display.
    public func audioFormatted() -> String {
        if let audio = audio, !audio.rawValue.isEmpty {
            return audio.rawValue
        }
        return Self.notAssignedRoleString
    }
    
    /// Caption role formatted for user display.
    public func captionFormatted() -> String {
        if let caption = caption, !caption.rawValue.isEmpty {
            // never use raw `captionFormat` string for user display, only use main role
            return caption.role
        }
        return Self.notAssignedRoleString
    }
}

// MARK: - Subroles

extension MarkerRoles {
    /// Strip off subrole if subrole is redundantly generated by FCP.
    /// ie: A role of "Role.Role-1" would return "Role".
    /// Only applies to audio and video roles. Has no effect on caption roles.
    public mutating func collapseSubroles() {
        video = video?.collapsedSubRole()
        audio = audio?.collapsedSubRole()
        // caption roles can't be collapsed
    }
    
    /// Strip off subrole if subrole is redundantly generated by FCP.
    /// ie: A role of "Role.Role-1" would return "Role".
    /// Only applies to audio and video roles. Has no effect on caption roles.
    public func collapsedSubroles() -> Self {
        var copy = self
        copy.collapseSubroles()
        return copy
    }
}