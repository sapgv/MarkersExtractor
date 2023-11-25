//
//  MarkerRole.swift
//  MarkersExtractor • https://github.com/TheAcharya/MarkersExtractor
//  Licensed under MIT License
//

import Foundation

public enum MarkerRole: Hashable, Equatable, Sendable {
    case video(String)
    case audio(String)
}

extension MarkerRole: CustomStringConvertible {
    public var description: String {
        stringValue
    }
    
    var stringValue: String {
        switch self {
        case let .video(string):
            return string
        case let .audio(string):
            return string
        }
    }
}

extension MarkerRole {
    var isVideo: Bool {
        guard case .video = self else {
            return false
        }
        return true
    }
    
    var isAudio: Bool {
        guard case .audio = self else {
            return false
        }
        return true
    }
}

extension Array where Element == MarkerRole {
    func flattenedString() -> String {
        map(\.stringValue)
            .joined(separator: ", ")
    }
}

// MARK: MarkerRoles

public struct MarkerRoles: Equatable, Hashable, Sendable {
    public var video: String?
    public var isVideoDefault: Bool
    public var audio: String?
    public var isAudioDefault: Bool
    
    public init(
        video: String? = nil,
        isVideoDefault: Bool = false,
        audio: String? = nil,
        isAudioDefault: Bool = false,
        collapseSubroles: Bool = false
    ) {
        self.video = video
        self.isVideoDefault = isVideoDefault
        self.audio = audio
        self.isAudioDefault = isAudioDefault
        if collapseSubroles { self.collapseSubroles() }
    }
}

// MARK: - Methods

extension MarkerRoles {
    /// Has a non-empty video role.
    public var isVideoEmpty: Bool {
        video == nil || video?.isEmpty == true
    }
    
    /// Has a defined (non-default) video role.
    public var isVideoDefined: Bool {
        !isVideoEmpty && !isVideoDefault
    }
    
    /// Has a non-empty audio role.
    public var isAudioEmpty: Bool {
        audio == nil || audio?.isEmpty == true
    }
    
    /// Has a defined (non-default) audio role.
    public var isAudioDefined: Bool {
        !isAudioEmpty && !isAudioDefault
    }
    
    static let notAssignedRole = "Not Assigned"
    
    public func videoFormatted() -> String {
        if let video = video, !video.isEmpty {
            return video
        }
        return Self.notAssignedRole
    }
    
    public func audioFormatted() -> String {
        if let audio = audio, !audio.isEmpty {
            return audio
        }
        return Self.notAssignedRole
    }
}

// MARK: - Subroles

extension MarkerRoles {
    /// Strip off subrole if subrole is redundantly generated by FCP.
    /// ie: A role of "Role.Role-1" would return "Role"
    public mutating func collapseSubroles() {
        if let v = video {
            video = Self.collapseSubrole(role: v)
        }
        if let a = audio {
            audio = Self.collapseSubrole(role: a)
        }
    }
    
    /// Strip off subrole if subrole is redundantly generated by FCP.
    /// ie: A role of "Role.Role-1" would return "Role"
    public func collapsedSubroles() -> Self {
        var copy = self
        copy.collapseSubroles()
        return copy
    }
    
    /// Strip off subrole if subrole is redundantly generated by FCP.
    /// ie: A role of "Role.Role-1" would return "Role"
    static func collapseSubrole(role: String) -> String {
        let pattern = #"^(.*)\.(.*)-([\d]{1,3})$"#
        let matches = role.regexMatches(captureGroupsFromPattern: pattern)
        guard matches.count == 4,
              let role = matches[1],
              let subrole = matches[2]
        else { return role }
        
        if role == subrole { return role }
        return role
    }
}

// MARK: - MarkerRoleType

public enum MarkerRoleType: String, CaseIterable, Equatable, Hashable, Sendable {
    case video
    case audio
}
