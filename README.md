# Converto

A simple, open-source macOS app for bulk image format conversion. Drop images, pick an output format and quality, and convert them all at once using [ImageMagick](https://imagemagick.org).

## Features

- Drag-and-drop or browse for multiple images
- Output format picker (configurable list of visible formats)
- Output folder: same as source or a custom directory
- Quality slider (0–100) mapped to ImageMagick `-quality`
- Parallel batch conversion (up to 4 concurrent jobs)
- Per-file status and error reporting

## Requirements

- macOS 14 or later
- Xcode 15 or later (to build)
- [ImageMagick 7](https://imagemagick.org) (`magick` command)

Install ImageMagick with Homebrew:

```bash
brew install imagemagick
```

Format support (HEIC, AVIF, WebP, etc.) depends on your ImageMagick build. The Homebrew formula typically includes common delegates.

## Build & Run

1. Clone this repository
2. Open `Converto.xcodeproj` in Xcode
3. Select the **Converto** scheme and press **Run** (⌘R)

## Usage

1. Drop images onto the main area or click to browse
2. In the sidebar, choose **output format**, **output folder**, and **quality**
3. Click **Convert**
4. Use **Formats…** in the toolbar to choose which formats appear in the picker (defaults: PNG, JPEG, GIF, WebP, HEIC, SVG, TIFF, AVIF)

If ImageMagick is not found, use **Converto → Settings** to set a custom path to the `magick` binary.

## How it works

Converto is a native SwiftUI shell around the ImageMagick CLI:

```bash
magick input.jpg -quality 85 output.webp
```

The app discovers writable formats via `magick -list format` and runs conversions in parallel with bounded concurrency.

## License

This application is licensed under the [MIT License](LICENSE).

ImageMagick is licensed separately; see [ImageMagick License](https://imagemagick.org/script/license.php).
