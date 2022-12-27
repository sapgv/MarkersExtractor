import CoreMedia
import TimecodeKit

struct Marker {
    var type: MarkerType
    var name: String
    var notes: String
    var role: String
    var status: MarkerStatus
    var checked: Bool
    var position: Timecode
    var parentClipName: String
    var parentClipDuration: Timecode
    var parentEventName: String
    var parentProjectName: String
    var parentLibraryName: String
    var nameMode: MarkerIDMode
    
    var id: String {
        switch nameMode {
        case .projectTimecode:
            return "\(parentProjectName)_\(positionTimecodeString)"
        case .name:
            return name
        case .notes:
            return notes
        }
    }
    
    var idPathSafe: String {
        id
            .replacingOccurrences(of: ";", with: "_") // used in drop-frame timecode
            .replacingOccurrences(of: ":", with: "_")
    }
    
    var frameRate: TimecodeFrameRate {
        position.frameRate
    }
    
    var positionTimecodeString: String {
        position.stringValue
    }

    var parentClipDurationTimecodeString: String {
        parentClipDuration.stringValue
    }

    var icon: MarkerIcon {
        switch type {
        case .standard:
            return .standard
        case .todo:
            return checked ? .completed : .todo
        case .chapter:
            return .chapter
        }
    }
}

extension Marker: Comparable {
    static func < (lhs: Marker, rhs: Marker) -> Bool {
        lhs.position < rhs.position
    }
}
