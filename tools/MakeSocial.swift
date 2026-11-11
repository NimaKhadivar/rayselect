// Draws the 1280×640 social preview (GitHub, Telegram, and other link cards).
// Usage: swift MakeSocial.swift icon.png out.png
import AppKit

let args = CommandLine.arguments
let icon = NSImage(contentsOfFile: args[1])!
let width = 1280, height = 640
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                           bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext
let full = CGRect(x: 0, y: 0, width: width, height: height)

// Base and the cyan glow from the app's "connected" state.
NSColor(srgbRed: 0.067, green: 0.067, blue: 0.071, alpha: 1).setFill()
full.fill()
let space = CGColorSpaceCreateDeviceRGB()
let cyan = NSColor(srgbRed: 0.33, green: 0.85, blue: 0.96, alpha: 1)
let glow = CGGradient(colorsSpace: space, colors: [cyan.withAlphaComponent(0.30).cgColor, cyan.withAlphaComponent(0).cgColor] as CFArray, locations: [0, 1])!
let orbCenter = CGPoint(x: 330, y: 320)
ctx.drawRadialGradient(glow, startCenter: orbCenter, startRadius: 0, endCenter: orbCenter, endRadius: 360, options: [])

// Light rays behind the icon.
ctx.saveGState()
for i in 0..<24 {
    let angle = CGFloat(i) * .pi * 2 / 24
    ctx.move(to: orbCenter)
    ctx.addLine(to: CGPoint(x: orbCenter.x + cos(angle) * 900, y: orbCenter.y + sin(angle) * 900))
    ctx.addLine(to: CGPoint(x: orbCenter.x + cos(angle + 0.035) * 900, y: orbCenter.y + sin(angle + 0.035) * 900))
    ctx.closePath()
}
ctx.setFillColor(cyan.withAlphaComponent(0.05).cgColor)
ctx.fillPath()
ctx.restoreGState()

// Ripples and the filled ring, like the orb when connected.
for (radius, alpha) in [(250.0, 0.10), (215.0, 0.18)] {
    ctx.setStrokeColor(cyan.withAlphaComponent(alpha).cgColor)
    ctx.setLineWidth(2)
    ctx.strokeEllipse(in: CGRect(x: orbCenter.x - radius, y: orbCenter.y - radius, width: radius * 2, height: radius * 2))
}
ctx.setShadow(offset: .zero, blur: 24, color: cyan.withAlphaComponent(0.7).cgColor)
ctx.setStrokeColor(cyan.cgColor)
ctx.setLineWidth(10)
ctx.strokeEllipse(in: CGRect(x: orbCenter.x - 172, y: orbCenter.y - 172, width: 344, height: 344))
ctx.setShadow(offset: .zero, blur: 0, color: nil)

// The app icon in the middle of the ring.
let iconSize: CGFloat = 250
icon.draw(in: CGRect(x: orbCenter.x - iconSize / 2, y: orbCenter.y - iconSize / 2, width: iconSize, height: iconSize))

// Text.
func draw(_ text: String, size: CGFloat, weight: NSFont.Weight, color: NSColor, x: CGFloat, y: CGFloat) {
    let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color, .kern: -size * 0.02]
    NSAttributedString(string: text, attributes: attributes).draw(at: CGPoint(x: x, y: y))
}
let ink = NSColor(srgbRed: 0.95, green: 0.95, blue: 0.96, alpha: 1)
let muted = NSColor(srgbRed: 0.60, green: 0.60, blue: 0.64, alpha: 1)
let accent = NSColor(srgbRed: 0.49, green: 0.70, blue: 1.0, alpha: 1)
draw("RaySelect", size: 96, weight: .bold, color: ink, x: 640, y: 350)
draw("One click. Your whole computer", size: 38, weight: .semibold, color: cyan, x: 644, y: 290)
draw("through Xray.", size: 38, weight: .semibold, color: cyan, x: 644, y: 242)
draw("VLESS · REALITY · VMess · Trojan · Shadowsocks", size: 22, weight: .medium, color: muted, x: 646, y: 176)
draw("Hysteria2 · WireGuard · Kill switch · Ad blocking", size: 22, weight: .medium, color: muted, x: 646, y: 144)
draw("Free for macOS and Windows", size: 24, weight: .semibold, color: accent, x: 646, y: 82)

NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
