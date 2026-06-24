import SwiftUI

extension LocalizedStringResource {
    // MARK: - General
    static let appName = LocalizedStringResource("app_name", comment: "App name")
    static let formatsMenu = LocalizedStringResource("formats_menu", comment: "Toolbar formats menu")

    // MARK: - Drop zone
    static let dropImagesHere = LocalizedStringResource("drop_images_here", comment: "Drop zone title")
    static let orClickToBrowse = LocalizedStringResource("or_click_to_browse", comment: "Drop zone subtitle")
    static let noImagesAdded = LocalizedStringResource("no_images_added", comment: "Empty queue message")
    static let clear = LocalizedStringResource("clear", comment: "Clear queue button")

    // MARK: - Sidebar
    static let sectionOutput = LocalizedStringResource("section_output", comment: "Output section header")
    static let format = LocalizedStringResource("format", comment: "Format picker label")
    static let folder = LocalizedStringResource("folder", comment: "Folder picker label")
    static let sameAsSource = LocalizedStringResource("same_as_source", comment: "Same folder as source option")
    static let chooseFolder = LocalizedStringResource("choose_folder", comment: "Choose custom folder option")
    static let noFolderSelected = LocalizedStringResource("no_folder_selected", comment: "No custom folder chosen")
    static let browse = LocalizedStringResource("browse", comment: "Browse folder button")
    static let sectionQuality = LocalizedStringResource("section_quality", comment: "Quality section header")
    static let qualityHint = LocalizedStringResource("quality_hint", comment: "Quality slider help text")
    static let convert = LocalizedStringResource("convert", comment: "Convert button without count")
    static let openOutputFolder = LocalizedStringResource("open_output_folder", comment: "Open output folder button")

    // MARK: - Format settings
    static let noFormatsFound = LocalizedStringResource("no_formats_found", comment: "Empty format search")
    static let formatSearchHint = LocalizedStringResource("format_search_hint", comment: "Format search empty hint")
    static let visibleFormats = LocalizedStringResource("visible_formats", comment: "Format settings title")
    static let searchFormats = LocalizedStringResource("search_formats", comment: "Format search placeholder")
    static let done = LocalizedStringResource("done", comment: "Done button")
    static let presets = LocalizedStringResource("presets", comment: "Presets menu")
    static let commonFormats = LocalizedStringResource("common_formats", comment: "Common formats preset")
    static let selectAll = LocalizedStringResource("select_all", comment: "Select all formats")
    static let clearAll = LocalizedStringResource("clear_all", comment: "Clear all format selections")

    // MARK: - Settings
    static let sectionImageMagick = LocalizedStringResource("section_imagemagick", comment: "ImageMagick settings section")
    static let detected = LocalizedStringResource("detected", comment: "Detected binary label")
    static let notDetected = LocalizedStringResource("not_detected", comment: "Binary not found")
    static let customMagickPath = LocalizedStringResource("custom_magick_path", comment: "Custom path field label")
    static let magickPathPlaceholder = LocalizedStringResource("magick_path_placeholder", comment: "Default magick path placeholder")
    static let apply = LocalizedStringResource("apply", comment: "Apply button")
    static let refresh = LocalizedStringResource("refresh", comment: "Refresh button")
    static let imageMagickDocs = LocalizedStringResource("imagemagick_docs", comment: "ImageMagick documentation link")

    // MARK: - Setup overlay
    static let imageMagickRequired = LocalizedStringResource("imagemagick_required", comment: "Setup overlay title")
    static let installWithHomebrew = LocalizedStringResource("install_with_homebrew", comment: "Homebrew install label")
    static let customPathHint = LocalizedStringResource("custom_path_hint", comment: "Custom path hint in setup")
    static let openSettings = LocalizedStringResource("open_settings", comment: "Open settings button")
    static let retry = LocalizedStringResource("retry", comment: "Retry detection button")
}

enum L10n {
    static func convertingProgress(completed: Int, total: Int) -> String {
        String(localized: "converting_progress \(completed) \(total)")
    }

    static func convertImages(count: Int) -> String {
        String(localized: "convert_images \(count)")
    }

    static var missingOutputFolder: String {
        String(localized: "error_missing_output_folder")
    }

    static var imageMagickNotFound: String {
        String(localized: "error_imagemagick_not_found")
    }

    static var imageMagickNotFoundOnMac: String {
        String(localized: "error_imagemagick_not_found_mac")
    }

    static func listFormatsFailed() -> String {
        String(localized: "error_list_formats_failed")
    }

    static let brewInstallCommand = "brew install imagemagick"
}
