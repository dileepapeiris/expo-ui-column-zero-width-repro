// Puts two captures side by side, with a label above each.
//   swift scripts/compose.swift image <left.png> <right.png> <out.png> <left label> <right label>
//   swift scripts/compose.swift video <left.mp4> <right.mp4> <out.mp4> <left label> <right label>
//   swift scripts/compose.swift gif   <left.mp4> <right.mp4> <out.gif> <left label> <right label> [fps] [scale]
import AVFoundation
import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let gap: CGFloat = 24
let labelHeight: CGFloat = 110

func loadImage(_ path: String) -> CGImage {
  guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
        let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    fatalError("cannot read \(path)")
  }
  return image
}

func drawLabel(_ text: String, in rect: CGRect, context: CGContext) {
  let font = CTFontCreateWithName("Helvetica-Bold" as CFString, 64, nil)
  let attributes = [
    kCTFontAttributeName: font,
    kCTForegroundColorAttributeName: CGColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
  ] as CFDictionary
  let line = CTLineCreateWithAttributedString(CFAttributedStringCreate(nil, text as CFString, attributes))
  let bounds = CTLineGetBoundsWithOptions(line, [])
  context.textPosition = CGPoint(x: rect.midX - bounds.width / 2, y: rect.midY - bounds.height / 2 + 8)
  CTLineDraw(line, context)
}

func compose(_ left: CGImage, _ right: CGImage, labels: (String, String), scale: CGFloat = 1) -> CGImage {
  let width = CGFloat(left.width + right.width) + gap
  let height = CGFloat(max(left.height, right.height)) + labelHeight
  let outWidth = Int(width * scale), outHeight = Int(height * scale)
  let space = CGColorSpace(name: CGColorSpace.sRGB)!
  let context = CGContext(data: nil, width: outWidth, height: outHeight, bitsPerComponent: 8, bytesPerRow: 0,
                          space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
  context.scaleBy(x: scale, y: scale)
  context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
  context.fill(CGRect(x: 0, y: 0, width: width, height: height))
  let leftWidth = CGFloat(left.width)
  context.draw(left, in: CGRect(x: 0, y: 0, width: leftWidth, height: CGFloat(left.height)))
  context.draw(right, in: CGRect(x: leftWidth + gap, y: 0, width: CGFloat(right.width), height: CGFloat(right.height)))
  drawLabel(labels.0, in: CGRect(x: 0, y: height - labelHeight, width: leftWidth, height: labelHeight), context: context)
  drawLabel(labels.1, in: CGRect(x: leftWidth + gap, y: height - labelHeight, width: CGFloat(right.width), height: labelHeight), context: context)
  return context.makeImage()!
}

func writeImage(_ image: CGImage, to path: String) {
  let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.png.identifier as CFString, 1, nil)!
  CGImageDestinationAddImage(destination, image, nil)
  CGImageDestinationFinalize(destination)
}

/// Frames of a video at a fixed rate.
func frames(of path: String, fps: Double, duration: Double) -> [CGImage] {
  let asset = AVURLAsset(url: URL(fileURLWithPath: path))
  let generator = AVAssetImageGenerator(asset: asset)
  generator.appliesPreferredTrackTransform = true
  generator.requestedTimeToleranceBefore = .zero
  generator.requestedTimeToleranceAfter = CMTime(seconds: 0.5 / fps, preferredTimescale: 600)
  var result: [CGImage] = []
  var t = 0.0
  while t < duration {
    let time = CMTime(seconds: t, preferredTimescale: 600)
    if let image = try? generator.copyCGImage(at: time, actualTime: nil) {
      result.append(image)
    } else if let last = result.last {
      result.append(last)
    }
    t += 1 / fps
  }
  return result
}

func seconds(of path: String) -> Double {
  CMTimeGetSeconds(AVURLAsset(url: URL(fileURLWithPath: path)).duration)
}

func writeGif(_ images: [CGImage], fps: Double, to path: String) {
  let destination = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, UTType.gif.identifier as CFString, images.count, nil)!
  CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
  for image in images {
    let props = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1 / fps]] as CFDictionary
    CGImageDestinationAddImage(destination, image, props)
  }
  CGImageDestinationFinalize(destination)
}
