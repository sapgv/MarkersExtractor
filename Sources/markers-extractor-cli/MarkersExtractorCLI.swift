import ArgumentParser
import Foundation
import Logging
import MarkersExtractor

struct MarkersExtractorCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Tool to extract markers from FCPXML(D).",
        discussion: "https://github.com/TheAcharya/MarkersExtractor",
        version: "0.1.1"
    )
    
    @Option(
        help: ArgumentHelp(
            "Metadata export format.",
            valueName: MarkersExportFormat.allCases.map { $0.rawValue }.joined(separator: ",")
        )
    )
    var exportFormat: MarkersExportFormat = .csv
    
    @Option(
        help: ArgumentHelp(
            "Marker thumb image format. 'gif' is animated and additional options can be specified with --gif-fps and --gif-span.",
            valueName: MarkerImageFormat.allCases.map { $0.rawValue }.joined(separator: ",")
        )
    )
    var imageFormat: MarkerImageFormat = MarkersExtractor.Settings.Defaults.imageFormat
    
    @Option(
        help: ArgumentHelp(
            "Image quality percent for JPG.",
            valueName: "\(MarkersExtractor.Settings.Validation.imageQuality)"
        )
    )
    var imageQuality: Int = MarkersExtractor.Settings.Defaults.imageQuality
    
    @Option(help: ArgumentHelp("Limit image width keeping aspect ratio.", valueName: "w"))
    var imageWidth: Int?
    
    @Option(help: ArgumentHelp("Limit image height keeping aspect ratio.", valueName: "h"))
    var imageHeight: Int?
    
    @Option(
        help: ArgumentHelp(
            "Limit image size to % keeping aspect ratio. (default for GIF: \(MarkersExtractor.Settings.Defaults.imageSizePercentGIF))",
            valueName: "\(MarkersExtractor.Settings.Validation.imageSizePercent)"
        )
    )
    var imageSizePercent: Int?
    
    @Option(help: ArgumentHelp(
        "GIF frame rate.",
        valueName: "\(MarkersExtractor.Settings.Validation.gifFPS)")
    )
    var gifFPS: Double = MarkersExtractor.Settings.Defaults.gifFPS
    
    @Option(help: ArgumentHelp("GIF capture span around marker.", valueName: "sec"))
    var gifSpan: TimeInterval = MarkersExtractor.Settings.Defaults.gifSpan
    
    @Option(
        help: ArgumentHelp(
            "Marker naming mode. This affects Marker IDs and image filenames.",
            valueName: MarkerIDMode.allCases
                .map { $0.rawValue }.joined(separator: ",")
        )
    )
    var idNamingMode: MarkerIDMode = MarkersExtractor.Settings.Defaults.idNamingMode
    
    @Option(
        name: [.customLong("label")],
        help: ArgumentHelp(
            "Label to overlay on thumb images. This argument can be supplied more than once to apply multiple labels.",
            valueName: "\(CSVExportModel.Field.allCases.map { $0.rawValue }.joined(separator: ","))"
        )
    )
    var imageLabels: [CSVExportModel.Field] = []
    
    @Option(
        name: [.customLong("label-copyright")],
        help: ArgumentHelp(
            "Copyright label. Will be appended after other labels.",
            valueName: "text"
        )
    )
    var imageLabelCopyright: String?
    
    @Option(
        name: [.customLong("label-font")],
        help: ArgumentHelp("Font for image labels.", valueName: "name")
    )
    var imageLabelFont: String = MarkersExtractor.Settings.Defaults.imageLabelFont
    
    @Option(
        name: [.customLong("label-font-size")],
        help: ArgumentHelp(
            "Maximum font size for image labels, font size is automatically reduced to fit all labels.",
            valueName: "pt"
        )
    )
    var imageLabelFontMaxSize: Int = MarkersExtractor.Settings.Defaults.imageLabelFontMaxSize
    
    @Option(
        name: [.customLong("label-opacity")],
        help: ArgumentHelp(
            "Label opacity percent",
            valueName: "\(MarkersExtractor.Settings.Validation.imageLabelFontOpacity)"
        )
    )
    var imageLabelFontOpacity: Int = MarkersExtractor.Settings.Defaults.imageLabelFontOpacity
    
    @Option(
        name: [.customLong("label-font-color")],
        help: ArgumentHelp("Label font color", valueName: "#RRGGBB / #RGB")
    )
    var imageLabelFontColor: String = MarkersExtractor.Settings.Defaults.imageLabelFontColor
    
    @Option(
        name: [.customLong("label-stroke-color")],
        help: ArgumentHelp("Label stroke color", valueName: "#RRGGBB / #RGB")
    )
    var imageLabelFontStrokeColor: String = MarkersExtractor.Settings.Defaults
        .imageLabelFontStrokeColor
    
    @Option(
        name: [.customLong("label-stroke-width")],
        help: ArgumentHelp("Label stroke width, 0 to disable. (default: auto)", valueName: "w")
    )
    var imageLabelFontStrokeWidth: Int?
    
    @Option(
        name: [.customLong("label-align-horizontal")],
        help: ArgumentHelp(
            "Horizontal alignment of image labels.",
            valueName: MarkerLabelProperties.AlignHorizontal.allCases
                .map { $0.rawValue }.joined(separator: ",")
        )
    )
    var imageLabelAlignHorizontal: MarkerLabelProperties.AlignHorizontal = MarkersExtractor.Settings
        .Defaults.imageLabelAlignHorizontal
    
    @Option(
        name: [.customLong("label-align-vertical")],
        help: ArgumentHelp(
            "Vertical alignment of image labels.",
            valueName: MarkerLabelProperties.AlignVertical.allCases
                .map { $0.rawValue }.joined(separator: ",")
        )
    )
    var imageLabelAlignVertical: MarkerLabelProperties.AlignVertical = MarkersExtractor.Settings
        .Defaults.imageLabelAlignVertical
    
    @Flag(
        name: [.customLong("label-hide-names")],
        help: ArgumentHelp("Hide names of image labels.")
    )
    var imageLabelHideNames: Bool = MarkersExtractor.Settings.Defaults.imageLabelHideNames
    
    @Flag(help: "Create a file in output directory on successful export. The filename can be customized using --done-filename.")
    var createDoneFile = MarkersExtractor.Settings.Defaults.createDoneFile
    
    @Option(
        help: ArgumentHelp(
            "Done file filename. Has no effect unless --create-done-file flag is also supplied.",
            valueName: "filename.txt"
        )
    )
    var doneFilename: String = MarkersExtractor.Settings.Defaults.doneFilename
    
    @Option(help: "Log file path.", transform: URL.init(fileURLWithPath:))
    var log: URL?
    
    @Option(
        help: ArgumentHelp(
            "Log level.",
            valueName: Logger.Level.allCases.map { $0.rawValue }.joined(separator: ",")
        )
    )
    var logLevel: Logger.Level = .info
    
    @Flag(name: [.customLong("quiet")], help: "Disable log.")
    var logQuiet = false
    
    @Argument(help: "Input FCPXML file / FCPXMLD bundle.", transform: URL.init(fileURLWithPath:))
    var fcpxmlPath: URL
    
    @Argument(help: "Output directory.", transform: URL.init(fileURLWithPath:))
    var outputDir: URL
    
    mutating func validate() throws {
        if let log = log, !FileManager.default.isWritableFile(atPath: log.path) {
            throw ValidationError("Cannot write log file at \(log.path.quoted)")
        }
        
        if imageFormat == .animated(.gif), imageSizePercent == nil {
            imageSizePercent = MarkersExtractor.Settings.Defaults.imageSizePercentGIF
        }
    }
    
    mutating func run() throws {
        initLogging(logLevel: logQuiet ? nil : logLevel, logFile: log)
        
        let settings: MarkersExtractor.Settings
        
        do {
            settings = try MarkersExtractor.Settings(
                exportFormat: exportFormat,
                imageFormat: imageFormat,
                imageQuality: imageQuality,
                imageWidth: imageWidth,
                imageHeight: imageHeight,
                imageSizePercent: imageSizePercent,
                gifFPS: gifFPS,
                gifSpan: gifSpan,
                idNamingMode: idNamingMode,
                imageLabels: imageLabels,
                imageLabelCopyright: imageLabelCopyright,
                imageLabelFont: imageLabelFont,
                imageLabelFontMaxSize: imageLabelFontMaxSize,
                imageLabelFontOpacity: imageLabelFontOpacity,
                imageLabelFontColor: imageLabelFontColor,
                imageLabelFontStrokeColor: imageLabelFontStrokeColor,
                imageLabelFontStrokeWidth: imageLabelFontStrokeWidth,
                imageLabelAlignHorizontal: imageLabelAlignHorizontal,
                imageLabelAlignVertical: imageLabelAlignVertical,
                imageLabelHideNames: imageLabelHideNames,
                createDoneFile: createDoneFile,
                doneFilename: doneFilename,
                fcpxml: .init(.url(fcpxmlPath)),
                outputDir: outputDir
            )
        } catch MarkersExtractorError.validationError(let error) {
            throw ValidationError(error)
        }
        
        try MarkersExtractor.extract(settings)
    }
}

// MARK: Helpers

extension MarkersExtractorCLI {
    private func initLogging(logLevel: Logger.Level?, logFile: URL?) {
        LoggingSystem.bootstrap { label in
            guard let logLevel = logLevel else {
                return SwiftLogNoOpLogHandler()
            }

            var logHandlers: [LogHandler] = [
                ConsoleLogHandler.init(label: label)
            ]

            if let logFile = logFile {
                do {
                    logHandlers.append(try FileLogHandler.init(label: label, localFile: logFile))
                } catch {
                    print(
                        "Cannot write to log file \(logFile.lastPathComponent.quoted):"
                            + " \(error.localizedDescription)"
                    )
                }
            }

            for i in 0..<logHandlers.count {
                logHandlers[i].logLevel = logLevel
            }

            return MultiplexLogHandler(logHandlers)
        }
    }
    
    static func printHelpLabels() {
        print("List of available label headers:")
        for header in CSVExportModel.Field.allCases {
            print("    \(header.rawValue)")
        }
    }
}
