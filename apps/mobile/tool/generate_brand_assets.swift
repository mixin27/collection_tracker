import AppKit

struct Palette {
    static let lightTop = NSColor(calibratedRed: 0.10, green: 0.57, blue: 0.90, alpha: 1.0)
    static let lightBottom = NSColor(calibratedRed: 0.19, green: 0.34, blue: 0.82, alpha: 1.0)
    static let darkTop = NSColor(calibratedRed: 0.08, green: 0.24, blue: 0.50, alpha: 1.0)
    static let darkBottom = NSColor(calibratedRed: 0.05, green: 0.16, blue: 0.37, alpha: 1.0)

    static let orbTop = NSColor(calibratedRed: 0.54, green: 0.72, blue: 0.91, alpha: 0.18)
    static let orbBottom = NSColor(calibratedRed: 0.57, green: 0.79, blue: 0.97, alpha: 0.16)

    static let frame = NSColor(calibratedRed: 0.82, green: 0.85, blue: 0.89, alpha: 1.0)
    static let frameDark = NSColor(calibratedRed: 0.74, green: 0.78, blue: 0.84, alpha: 1.0)
    static let detail = NSColor(calibratedRed: 0.67, green: 0.75, blue: 0.86, alpha: 1.0)
    static let detailDark = NSColor(calibratedRed: 0.59, green: 0.68, blue: 0.79, alpha: 1.0)

    static let featureChip = NSColor(calibratedRed: 0.35, green: 0.54, blue: 0.83, alpha: 0.42)
    static let featureText = NSColor(calibratedRed: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
    static let featureSubText = NSColor(calibratedRed: 0.80, green: 0.89, blue: 0.98, alpha: 1.0)
}

func roundedRect(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawImage(width: Int, height: Int, _ draw: (_ rect: NSRect, _ ctx: CGContext) -> Void) -> NSImage {
    let image = NSImage(size: NSSize(width: width, height: height))
    image.lockFocus()
    defer { image.unlockFocus() }

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        fatalError("Unable to create graphics context.")
    }
    draw(NSRect(x: 0, y: 0, width: width, height: height), ctx)
    return image
}

func savePng(_ image: NSImage, to url: URL) throws {
    guard
        let tiff = image.tiffRepresentation,
        let rep = NSBitmapImageRep(data: tiff),
        let data = rep.representation(using: .png, properties: [:])
    else {
        throw NSError(
            domain: "BrandAssets",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "PNG encoding failed"]
        )
    }
    try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try data.write(to: url)
}

func drawBackground(in rect: NSRect, dark: Bool, cornerRadiusRatio: CGFloat = 0.22) {
    let clip = roundedRect(rect, radius: rect.width * cornerRadiusRatio)
    clip.addClip()

    let gradient = dark
        ? NSGradient(colorsAndLocations:
            (Palette.darkTop, 0.0),
            (Palette.darkBottom, 1.0)
        )!
        : NSGradient(colorsAndLocations:
            (Palette.lightTop, 0.0),
            (Palette.lightBottom, 1.0)
        )!
    gradient.draw(in: clip, angle: -18)

    Palette.orbTop.setFill()
    NSBezierPath(
        ovalIn: NSRect(
            x: rect.minX - rect.width * 0.22,
            y: rect.minY + rect.height * 0.50,
            width: rect.width * 0.78,
            height: rect.height * 0.78
        )
    ).fill()

    Palette.orbBottom.setFill()
    NSBezierPath(
        ovalIn: NSRect(
            x: rect.minX + rect.width * 0.62,
            y: rect.minY - rect.height * 0.20,
            width: rect.width * 0.56,
            height: rect.height * 0.56
        )
    ).fill()
}

func drawOpenBook(
    in rect: NSRect,
    stroke: NSColor,
    lineWidth: CGFloat,
    includeFingerDetails: Bool = true
) {
    let cx = rect.midX
    let topY = rect.minY + rect.height * 0.40
    let bottomY = rect.minY + rect.height * 0.74

    let leftTop = NSPoint(x: rect.minX + rect.width * 0.28, y: rect.minY + rect.height * 0.35)
    let leftOuter = NSPoint(x: rect.minX + rect.width * 0.20, y: bottomY)
    let leftInnerBottom = NSPoint(x: cx - rect.width * 0.06, y: rect.minY + rect.height * 0.71)

    let rightTop = NSPoint(x: rect.maxX - rect.width * 0.28, y: rect.minY + rect.height * 0.35)
    let rightOuter = NSPoint(x: rect.maxX - rect.width * 0.20, y: bottomY)
    let rightInnerBottom = NSPoint(x: cx + rect.width * 0.06, y: rect.minY + rect.height * 0.71)

    let leftPage = NSBezierPath()
    leftPage.move(to: NSPoint(x: cx - rect.width * 0.01, y: topY))
    leftPage.curve(
        to: leftTop,
        controlPoint1: NSPoint(x: cx - rect.width * 0.10, y: rect.minY + rect.height * 0.30),
        controlPoint2: NSPoint(x: leftTop.x + rect.width * 0.06, y: leftTop.y)
    )
    leftPage.line(to: leftOuter)
    leftPage.curve(
        to: leftInnerBottom,
        controlPoint1: NSPoint(x: leftOuter.x + rect.width * 0.10, y: rect.minY + rect.height * 0.66),
        controlPoint2: NSPoint(x: leftInnerBottom.x - rect.width * 0.06, y: leftInnerBottom.y)
    )

    let rightPage = NSBezierPath()
    rightPage.move(to: NSPoint(x: cx + rect.width * 0.01, y: topY))
    rightPage.curve(
        to: rightTop,
        controlPoint1: NSPoint(x: cx + rect.width * 0.10, y: rect.minY + rect.height * 0.30),
        controlPoint2: NSPoint(x: rightTop.x - rect.width * 0.06, y: rightTop.y)
    )
    rightPage.line(to: rightOuter)
    rightPage.curve(
        to: rightInnerBottom,
        controlPoint1: NSPoint(x: rightOuter.x - rect.width * 0.10, y: rect.minY + rect.height * 0.66),
        controlPoint2: NSPoint(x: rightInnerBottom.x + rect.width * 0.06, y: rightInnerBottom.y)
    )

    let topLeftLeaf = NSBezierPath()
    topLeftLeaf.move(to: NSPoint(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.30))
    topLeftLeaf.curve(
        to: NSPoint(x: cx - rect.width * 0.01, y: rect.minY + rect.height * 0.39),
        controlPoint1: NSPoint(x: rect.minX + rect.width * 0.36, y: rect.minY + rect.height * 0.27),
        controlPoint2: NSPoint(x: cx - rect.width * 0.10, y: rect.minY + rect.height * 0.35)
    )

    let topRightLeaf = NSBezierPath()
    topRightLeaf.move(to: NSPoint(x: rect.maxX - rect.width * 0.25, y: rect.minY + rect.height * 0.30))
    topRightLeaf.curve(
        to: NSPoint(x: cx + rect.width * 0.01, y: rect.minY + rect.height * 0.39),
        controlPoint1: NSPoint(x: rect.maxX - rect.width * 0.36, y: rect.minY + rect.height * 0.27),
        controlPoint2: NSPoint(x: cx + rect.width * 0.10, y: rect.minY + rect.height * 0.35)
    )

    let spine = NSBezierPath()
    spine.move(to: NSPoint(x: cx, y: rect.minY + rect.height * 0.39))
    spine.line(to: NSPoint(x: cx, y: rect.minY + rect.height * 0.75))

    stroke.setStroke()
    var paths = [leftPage, rightPage, topLeftLeaf, topRightLeaf, spine]
    if includeFingerDetails {
        let leftFinger = NSBezierPath()
        leftFinger.move(to: NSPoint(x: rect.minX + rect.width * 0.13, y: rect.minY + rect.height * 0.48))
        leftFinger.line(to: NSPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.50))
        leftFinger.move(to: NSPoint(x: rect.minX + rect.width * 0.13, y: rect.minY + rect.height * 0.52))
        leftFinger.line(to: NSPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.54))
        leftFinger.move(to: NSPoint(x: rect.minX + rect.width * 0.13, y: rect.minY + rect.height * 0.56))
        leftFinger.line(to: NSPoint(x: rect.minX + rect.width * 0.22, y: rect.minY + rect.height * 0.58))

        let rightFinger = NSBezierPath()
        rightFinger.move(to: NSPoint(x: rect.maxX - rect.width * 0.13, y: rect.minY + rect.height * 0.48))
        rightFinger.line(to: NSPoint(x: rect.maxX - rect.width * 0.22, y: rect.minY + rect.height * 0.50))
        rightFinger.move(to: NSPoint(x: rect.maxX - rect.width * 0.13, y: rect.minY + rect.height * 0.52))
        rightFinger.line(to: NSPoint(x: rect.maxX - rect.width * 0.22, y: rect.minY + rect.height * 0.54))
        rightFinger.move(to: NSPoint(x: rect.maxX - rect.width * 0.13, y: rect.minY + rect.height * 0.56))
        rightFinger.line(to: NSPoint(x: rect.maxX - rect.width * 0.22, y: rect.minY + rect.height * 0.58))
        paths.append(leftFinger)
        paths.append(rightFinger)
    }

    for path in paths {
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
    }
}

func drawClock(in rect: NSRect, stroke: NSColor, lineWidth: CGFloat) {
    let circle = NSBezierPath(ovalIn: rect)
    circle.lineWidth = lineWidth
    stroke.setStroke()
    circle.stroke()

    let cx = rect.midX
    let cy = rect.midY

    let hands = NSBezierPath()
    hands.lineWidth = lineWidth
    hands.lineCapStyle = .round
    hands.move(to: NSPoint(x: cx, y: cy))
    hands.line(to: NSPoint(x: cx, y: rect.maxY - rect.height * 0.24))
    hands.move(to: NSPoint(x: cx, y: cy))
    hands.line(to: NSPoint(x: rect.maxX - rect.width * 0.28, y: cy))
    hands.stroke()
}

func drawWingedBookTimeMark(
    in rect: NSRect,
    stroke: NSColor,
    includeRing: Bool,
    lineWidthScale: CGFloat = 1.0
) {
    let emblemRect = includeRing ? rect.insetBy(dx: rect.width * 0.08, dy: rect.height * 0.08) : rect
    if includeRing {
        let ring = NSBezierPath(ovalIn: emblemRect)
        ring.lineWidth = emblemRect.width * 0.028 * lineWidthScale
        ring.lineJoinStyle = .round
        stroke.setStroke()
        ring.stroke()
    }

    let symbolRect = includeRing
        ? NSRect(
            x: emblemRect.minX + emblemRect.width * 0.12,
            y: emblemRect.minY + emblemRect.height * 0.12,
            width: emblemRect.width * 0.76,
            height: emblemRect.height * 0.70
        )
        : NSRect(
            x: emblemRect.minX + emblemRect.width * 0.08,
            y: emblemRect.minY + emblemRect.height * 0.08,
            width: emblemRect.width * 0.84,
            height: emblemRect.height * 0.76
        )

    drawOpenBook(
        in: symbolRect,
        stroke: stroke,
        lineWidth: emblemRect.width * 0.014 * lineWidthScale,
        includeFingerDetails: true
    )

    let clockRect = NSRect(
        x: symbolRect.midX - symbolRect.width * 0.10,
        y: symbolRect.minY + symbolRect.height * 0.10,
        width: symbolRect.width * 0.20,
        height: symbolRect.width * 0.20
    )
    drawClock(
        in: clockRect,
        stroke: stroke,
        lineWidth: emblemRect.width * 0.012 * lineWidthScale
    )
}

func drawBrandMark(in rect: NSRect, dark: Bool) {
    let stroke = dark ? Palette.frameDark : Palette.frame
    drawWingedBookTimeMark(
        in: rect,
        stroke: stroke,
        includeRing: false
    )
}

func drawCenteredText(
    _ text: String,
    in rect: NSRect,
    size: CGFloat,
    weight: NSFont.Weight,
    color: NSColor
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: 0.2,
    ]
    NSAttributedString(string: text, attributes: attributes).draw(in: rect)
}

func drawTextExactlyCentered(
    _ text: String,
    in rect: NSRect,
    size: CGFloat,
    weight: NSFont.Weight,
    color: NSColor
) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .kern: 0.0,
    ]
    let nsText = text as NSString
    let textSize = nsText.size(withAttributes: attributes)
    let drawPoint = NSPoint(
        x: rect.midX - textSize.width * 0.5,
        y: rect.midY - textSize.height * 0.5
    )
    nsText.draw(at: drawPoint, withAttributes: attributes)
}

func projectRoot(from scriptPath: String) -> URL {
    var url = URL(fileURLWithPath: scriptPath).deletingLastPathComponent()
    // tool -> mobile -> apps -> workspace root
    url.deleteLastPathComponent()
    url.deleteLastPathComponent()
    url.deleteLastPathComponent()
    return url
}

let root = projectRoot(from: #filePath)
let appDir = root.appendingPathComponent("apps/mobile")

let iconLightURL = appDir.appendingPathComponent("assets/icons/logo_light.png")
let iconDarkURL = appDir.appendingPathComponent("assets/icons/logo_dark.png")
let iconForegroundURL = appDir.appendingPathComponent("assets/icons/logo_foreground.png")
let featureURL = appDir.appendingPathComponent("assets/branding/play_store_feature_graphic.png")

let iconLight = drawImage(width: 1024, height: 1024) { rect, _ in
    let cardRect = rect
    drawBackground(in: cardRect, dark: false, cornerRadiusRatio: 0.30)
    drawBrandMark(
        in: cardRect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.12),
        dark: false
    )
}

let iconDark = drawImage(width: 1024, height: 1024) { rect, _ in
    let cardRect = rect
    drawBackground(in: cardRect, dark: true, cornerRadiusRatio: 0.30)
    drawBrandMark(
        in: cardRect.insetBy(dx: rect.width * 0.12, dy: rect.height * 0.12),
        dark: true
    )
}

let iconForeground = drawImage(width: 432, height: 432) { rect, _ in
    drawWingedBookTimeMark(
        in: rect.insetBy(dx: rect.width * 0.02, dy: rect.height * 0.02),
        stroke: NSColor(calibratedRed: 0.93, green: 0.95, blue: 0.98, alpha: 1.0),
        includeRing: false,
        lineWidthScale: 1.08
    )
}

let featureGraphic = drawImage(width: 1024, height: 500) { rect, _ in
    let clip = NSBezierPath(rect: rect)
    clip.addClip()

    let gradient = NSGradient(colorsAndLocations:
        (Palette.darkTop, 0.0),
        (NSColor(calibratedRed: 0.18, green: 0.41, blue: 0.79, alpha: 1.0), 1.0)
    )!
    gradient.draw(in: clip, angle: -16)

    Palette.orbTop.setFill()
    NSBezierPath(ovalIn: NSRect(x: -90, y: 210, width: 360, height: 360)).fill()
    Palette.orbBottom.setFill()
    NSBezierPath(ovalIn: NSRect(x: 690, y: -120, width: 420, height: 420)).fill()

    let iconRect = NSRect(x: 70, y: 40, width: 340, height: 340)
    NSGraphicsContext.saveGraphicsState()
    let iconClip = roundedRect(iconRect, radius: 56)
    iconClip.addClip()
    drawBackground(in: iconRect, dark: false)
    drawBrandMark(in: iconRect, dark: false)
    NSGraphicsContext.restoreGraphicsState()

    drawCenteredText(
        "Collectra",
        in: NSRect(x: 450, y: 274, width: 520, height: 84),
        size: 68,
        weight: .bold,
        color: Palette.featureText
    )
    drawCenteredText(
        "Catalog your things with clarity and confidence.",
        in: NSRect(x: 450, y: 212, width: 520, height: 52),
        size: 20,
        weight: .semibold,
        color: Palette.featureSubText
    )

    let tags = [
        ("Catalog", NSRect(x: 490, y: 118, width: 140, height: 44)),
        ("Track Value", NSRect(x: 642, y: 118, width: 148, height: 44)),
        ("Sync Ready", NSRect(x: 802, y: 118, width: 146, height: 44)),
    ]

    for (text, frame) in tags {
        Palette.featureChip.setFill()
        roundedRect(frame, radius: frame.height * 0.48).fill()
        drawTextExactlyCentered(
            text,
            in: frame,
            size: 20,
            weight: .semibold,
            color: Palette.featureText
        )
    }
}

do {
    try savePng(iconLight, to: iconLightURL)
    try savePng(iconDark, to: iconDarkURL)
    try savePng(iconForeground, to: iconForegroundURL)
    try savePng(featureGraphic, to: featureURL)
    print("Generated brand assets:")
    print("- \(iconLightURL.path)")
    print("- \(iconDarkURL.path)")
    print("- \(iconForegroundURL.path)")
    print("- \(featureURL.path)")
} catch {
    fputs("Failed to generate assets: \(error)\n", stderr)
    exit(1)
}
