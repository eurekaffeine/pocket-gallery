import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

private let locales = ["en", "zh-hans", "zh-hant", "ja-jp", "ko", "de", "fr", "es", "it"]
private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let publicRoot = root.appendingPathComponent("docs/.vuepress/public")
private let skinRoot = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Android/sdk/skins/pixel_10_pro_xl")

func load(_ url: URL) throws -> CGImage {
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
        throw NSError(domain: "DeviceCompositor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot load \(url.path)"])
    }
    return image
}

func context(width: Int, height: Int) throws -> CGContext {
    guard let ctx = CGContext(
        data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        throw NSError(domain: "DeviceCompositor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create bitmap context"])
    }
    ctx.clear(CGRect(x: 0, y: 0, width: width, height: height))
    ctx.interpolationQuality = .high
    return ctx
}

func drawTopLeft(_ image: CGImage, in rect: CGRect, on ctx: CGContext, canvasHeight: CGFloat) {
    let coreGraphicsRect = CGRect(x: rect.minX, y: canvasHeight - rect.maxY, width: rect.width, height: rect.height)
    ctx.draw(image, in: coreGraphicsRect)
}

func roundedRectPath(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, radius: CGFloat, canvasHeight: CGFloat) -> CGPath {
    CGPath(roundedRect: CGRect(x: x, y: canvasHeight - y - height, width: width, height: height), cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func savePNG(_ image: CGImage, to url: URL) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw NSError(domain: "DeviceCompositor", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create PNG destination"])
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw NSError(domain: "DeviceCompositor", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot save \(url.path)"])
    }
}

func currentFrameBuffer(for locale: String) throws -> CGImage {
    let rawCapture = publicRoot.appendingPathComponent("device-captures/\(locale)/pixel-10-pro-xl-raw.png")
    if FileManager.default.fileExists(atPath: rawCapture.path) {
        return try load(rawCapture)
    }

    // The checked-in WebP is already framed. Its display crop is still a pixel-exact
    // copy of the real emulator framebuffer, so it is safe to recover for reruns.
    let framed = try load(publicRoot.appendingPathComponent("device-captures/\(locale)/pixel-10-pro-xl.webp"))
    guard framed.width >= 1404, framed.height >= 3047,
          let recovered = framed.cropping(to: CGRect(x: 60, y: framed.height - 55 - 2992, width: 1344, height: 2992)) else {
        throw NSError(domain: "DeviceCompositor", code: 5, userInfo: [NSLocalizedDescriptionKey: "Cannot recover Pixel framebuffer for \(locale)"])
    }
    return recovered
}

func composePixel(frameBuffer: CGImage, back: CGImage, foreground: CGImage) throws -> CGImage {
    let width = 1472
    let height = 3111
    let ctx = try context(width: width, height: height)

    // The emulator display is 1344 x 2992 at (60, 55), with a 108 px corner radius.
    ctx.saveGState()
    ctx.addPath(roundedRectPath(x: 60, y: 55, width: 1344, height: 2992, radius: 108, canvasHeight: CGFloat(height)))
    ctx.clip()
    drawTopLeft(frameBuffer, in: CGRect(x: 60, y: 55, width: 1344, height: 2992), on: ctx, canvasHeight: CGFloat(height))
    ctx.restoreGState()

    // The skin back plate includes semi-opaque gray corner pixels outside the phone.
    // Clip it to the physical body so the exported exterior stays transparent.
    ctx.saveGState()
    ctx.addPath(roundedRectPath(x: 0, y: 0, width: 1472, height: 3111, radius: 185, canvasHeight: CGFloat(height)))
    ctx.clip()
    drawTopLeft(back, in: CGRect(x: 0, y: 0, width: 1472, height: 3111), on: ctx, canvasHeight: CGFloat(height))
    ctx.restoreGState()

    // Foreground supplies the camera cutout and inner glass edge.
    drawTopLeft(foreground, in: CGRect(x: 60, y: 55, width: 1344, height: 2992), on: ctx, canvasHeight: CGFloat(height))

    guard let image = ctx.makeImage() else { throw NSError(domain: "DeviceCompositor", code: 6) }
    return image
}

do {
    let back = try load(skinRoot.appendingPathComponent("back.webp"))
    let foreground = try load(skinRoot.appendingPathComponent("mask.webp"))

    for locale in locales {
        let frameBuffer = try currentFrameBuffer(for: locale)
        let pixel = try composePixel(frameBuffer: frameBuffer, back: back, foreground: foreground)
        try savePNG(pixel, to: publicRoot.appendingPathComponent("device-captures/\(locale)/pixel-10-pro-xl.png"))
    }

    print("Composed \(locales.count) Pixel frame PNGs. Compose final heroes with ffmpeg to preserve source orientation.")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
