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
