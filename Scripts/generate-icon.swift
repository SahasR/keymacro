#!/usr/bin/swift
import AppKit

func makeIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let img = NSImage(size: NSSize(width: s, height: s))
    img.lockFocus()

    // Rounded rect clip (macOS icon shape)
    let radius = s * 0.225
    let bgPath = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: s, height: s), xRadius: radius, yRadius: radius)
    bgPath.setClip()

    // Deep indigo background
    NSColor(red: 0.13, green: 0.11, blue: 0.32, alpha: 1).setFill()
    bgPath.fill()

    // Subtle inner glow / lighter top half
    let gradStart = NSColor(red: 0.28, green: 0.22, blue: 0.55, alpha: 0.55)
    let gradEnd   = NSColor(red: 0.0,  green: 0.0,  blue: 0.0,  alpha: 0.0)
    if let gradient = NSGradient(starting: gradStart, ending: gradEnd) {
        gradient.draw(in: NSRect(x: 0, y: 0, width: s, height: s), angle: 90)
    }

    // Draw ⌘ symbol centered
    let symbol = "⌘"
    let fontSize = s * 0.56
    let font = NSFont.systemFont(ofSize: fontSize, weight: .thin)
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white.withAlphaComponent(0.93)
    ]
    let aStr = NSAttributedString(string: symbol, attributes: attrs)
    let sz = aStr.size()
    // Slightly raise vertically to optically center ⌘
    let origin = NSPoint(x: (s - sz.width) / 2, y: (s - sz.height) / 2 - s * 0.02)
    aStr.draw(at: origin)

    img.unlockFocus()
    return img
}

let iconSizes: [(String, Int)] = [
    ("icon_16x16",      16),
    ("icon_16x16@2x",   32),
    ("icon_32x32",      32),
    ("icon_32x32@2x",   64),
    ("icon_128x128",    128),
    ("icon_128x128@2x", 256),
    ("icon_256x256",    256),
    ("icon_256x256@2x", 512),
    ("icon_512x512",    512),
    ("icon_512x512@2x", 1024),
]

guard CommandLine.arguments.count > 1 else {
    fputs("Usage: generate-icon.swift <output-iconset-dir>\n", stderr)
    exit(1)
}

let outDir = CommandLine.arguments[1]
let fm = FileManager.default
try! fm.createDirectory(atPath: outDir, withIntermediateDirectories: true)

for (name, size) in iconSizes {
    let img = makeIcon(size: size)
    guard let tiff = img.tiffRepresentation,
          let rep  = NSBitmapImageRep(data: tiff),
          let png  = rep.representation(using: .png, properties: [:]) else {
        fputs("Failed to generate \(name)\n", stderr)
        continue
    }
    let path = "\(outDir)/\(name).png"
    try! png.write(to: URL(fileURLWithPath: path))
    print("  \(name).png")
}
