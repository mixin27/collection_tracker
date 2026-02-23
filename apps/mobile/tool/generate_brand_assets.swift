import AppKit

struct Palette {
    static let lightTop = NSColor(calibratedRed: 1.00, green: 0.91, blue: 0.76, alpha: 1)
    static let lightBottom = NSColor(calibratedRed: 1.00, green: 0.60, blue: 0.00, alpha: 1) // App orange #FF9800

    static let darkTop = NSColor(calibratedRed: 0.22, green: 0.14, blue: 0.04, alpha: 1)
    static let darkBottom = NSColor(calibratedRed: 0.13, green: 0.08, blue: 0.03, alpha: 1)

    static let ink = NSColor(calibratedRed: 0.20, green: 0.12, blue: 0.03, alpha: 1)
    static let inkSoft = NSColor(calibratedRed: 0.30, green: 0.18, blue: 0.06, alpha: 1)
    static let cream = NSColor(calibratedRed: 1.00, green: 0.96, blue: 0.90, alpha: 1)
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
        throw NSError(domain: "BrandAssets", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG encoding failed"])
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
}

func drawBackground(in rect: NSRect, dark: Bool) {
    let clip = roundedRect(rect, radius: rect.width * 0.22)
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

    gradient.draw(in: clip, angle: dark ? 95 : -18)

    let orbColor = dark
        ? NSColor.white.withAlphaComponent(0.06)
        : NSColor.white.withAlphaComponent(0.18)
    orbColor.setFill()
    NSBezierPath(
        ovalIn: NSRect(
            x: rect.minX - rect.width * 0.14,
            y: rect.minY + rect.height * 0.44,
            width: rect.width * 0.66,
            height: rect.height * 0.56
        )
    ).fill()
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
        .kern: 0.6,
    ]
    NSAttributedString(string: text, attributes: attributes).draw(in: rect)
}

func drawTextExactlyCentered(
    _ text: String,
    in rect: NSRect,
    size: CGFloat,
    weight: NSFont.Weight,
    color: NSColor,
    kerning: CGFloat = 0.0
) {
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .kern: kerning,
    ]
    let nsText = text as NSString
    let textSize = nsText.size(withAttributes: attributes)
    let drawPoint = NSPoint(
        x: rect.midX - textSize.width * 0.5,
        y: rect.midY - textSize.height * 0.5
    )
    nsText.draw(at: drawPoint, withAttributes: attributes)
}

func drawOpenBook(in rect: NSRect, stroke: NSColor, lineWidth: CGFloat) {
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

    stroke.setStroke()
    for path in [leftPage, rightPage, topLeftLeaf, topRightLeaf, spine, leftFinger, rightFinger] {
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

func drawBadgeMark(in rect: NSRect, includeWords: Bool, ink: NSColor) {
    let ringRect = rect.insetBy(dx: rect.width * 0.09, dy: rect.height * 0.09)
    let ring = NSBezierPath(ovalIn: ringRect)
    ring.lineWidth = ringRect.width * 0.032
    ring.lineJoinStyle = .round
    ink.setStroke()
    ring.stroke()

    let clockRect = NSRect(
        x: ringRect.midX - ringRect.width * 0.07,
        y: ringRect.minY + ringRect.height * 0.24,
        width: ringRect.width * 0.14,
        height: ringRect.width * 0.14
    )
    drawClock(in: clockRect, stroke: ink, lineWidth: ringRect.width * 0.012)

    let bookRect = NSRect(
        x: ringRect.minX + ringRect.width * 0.12,
        y: ringRect.minY + ringRect.height * 0.12,
        width: ringRect.width * 0.76,
        height: ringRect.height * 0.70
    )
    drawOpenBook(in: bookRect, stroke: ink, lineWidth: ringRect.width * 0.014)

    if includeWords {
        drawCenteredText(
            "COLLECTION",
            in: NSRect(
                x: ringRect.minX + ringRect.width * 0.08,
                y: ringRect.minY + ringRect.height * 0.75,
                width: ringRect.width * 0.84,
                height: ringRect.height * 0.14
            ),
            size: ringRect.width * 0.10,
            weight: .bold,
            color: ink
        )
        drawCenteredText(
            "TIME",
            in: NSRect(
                x: ringRect.minX + ringRect.width * 0.22,
                y: ringRect.minY + ringRect.height * 0.02,
                width: ringRect.width * 0.56,
                height: ringRect.height * 0.12
            ),
            size: ringRect.width * 0.10,
            weight: .bold,
            color: ink
        )
    }
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
    let cardRect = rect.insetBy(dx: rect.width * 0.055, dy: rect.height * 0.055)
    drawBackground(in: cardRect, dark: false)
    drawBadgeMark(in: rect, includeWords: true, ink: Palette.ink)
}

let iconDark = drawImage(width: 1024, height: 1024) { rect, _ in
    let cardRect = rect.insetBy(dx: rect.width * 0.055, dy: rect.height * 0.055)
    drawBackground(in: cardRect, dark: true)
    drawBadgeMark(in: rect, includeWords: true, ink: Palette.cream)
}

let iconForeground = drawImage(width: 432, height: 432) { rect, _ in
    // Keep foreground minimal for adaptive icon legibility.
    drawBadgeMark(in: rect, includeWords: false, ink: Palette.ink)
}

let featureGraphic = drawImage(width: 1024, height: 500) { rect, ctx in
    let bg = NSBezierPath(rect: rect)
    bg.addClip()
    let gradient = NSGradient(colorsAndLocations:
        (NSColor(calibratedRed: 1.00, green: 0.93, blue: 0.79, alpha: 1), 0.0),
        (NSColor(calibratedRed: 1.00, green: 0.66, blue: 0.15, alpha: 1), 1.0)
    )!
    gradient.draw(in: bg, angle: -14)

    NSColor.white.withAlphaComponent(0.16).setFill()
    NSBezierPath(ovalIn: NSRect(x: -100, y: 200, width: 380, height: 380)).fill()

    let emblemRect = NSRect(x: 60, y: 40, width: 420, height: 420)
    let emblemCard = roundedRect(emblemRect, radius: 56)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -5), blur: 22, color: NSColor.black.withAlphaComponent(0.18).cgColor)
    NSColor.white.withAlphaComponent(0.62).setFill()
    emblemCard.fill()
    ctx.restoreGState()

    drawBadgeMark(in: emblemRect, includeWords: true, ink: Palette.inkSoft)

    drawCenteredText(
        "Collection Time",
        in: NSRect(x: 520, y: 282, width: 470, height: 78),
        size: 50,
        weight: .bold,
        color: Palette.ink
    )
    drawCenteredText(
        "Collect, organize, and remember what matters.",
        in: NSRect(x: 520, y: 214, width: 470, height: 48),
        size: 20,
        weight: .medium,
        color: Palette.inkSoft
    )

    let tags = [
        ("Catalog", NSRect(x: 560, y: 118, width: 126, height: 44)),
        ("Track Value", NSRect(x: 698, y: 118, width: 142, height: 44)),
        ("Sync Ready", NSRect(x: 852, y: 118, width: 146, height: 44)),
    ]

    for (text, frame) in tags {
        NSColor.white.withAlphaComponent(0.34).setFill()
        roundedRect(frame, radius: frame.height * 0.48).fill()
        drawTextExactlyCentered(
            text,
            in: frame,
            size: 24,
            weight: .semibold,
            color: Palette.ink,
            kerning: 0.2
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
