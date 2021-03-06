//
//  Extensions.swift
//  megha
//
//  Created by Karthikeyan K on 18/05/21.
//

import Foundation

import CoreGraphics
import Foundation
import UIKit

extension UIImage {

  public func scaledData(with size: CGSize) -> Data? {
    guard let cgImage = self.cgImage, cgImage.width > 0, cgImage.height > 0 else { return nil }

    let bitmapInfo = CGBitmapInfo(
      rawValue: CGImageAlphaInfo.none.rawValue
    )
    let width = Int(size.width)
    guard let context = CGContext(
      data: nil,
      width: width,
      height: Int(size.height),
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: width * 1,
      space: CGColorSpaceCreateDeviceGray(),
      bitmapInfo: bitmapInfo.rawValue)
      else {
        return nil
    }
    context.draw(cgImage, in: CGRect(origin: .zero, size: size))
    guard let scaledBytes = context.makeImage()?.dataProvider?.data as Data? else { return nil }
    let scaledFloats = scaledBytes.map { Float32($0) / Constant.maxRGBValue }

    return Data(copyingBufferOf: scaledFloats)
  }

}

extension Data {
  init<T>(copyingBufferOf array: [T]) {
    self = array.withUnsafeBufferPointer(Data.init)
  }

  func toArray<T>(type: T.Type) -> [T] where T: ExpressibleByIntegerLiteral {
    var array = Array<T>(repeating: 0, count: self.count/MemoryLayout<T>.stride)
    _ = array.withUnsafeMutableBytes { copyBytes(to: $0) }
    return array
  }
}

private enum Constant {
  static let maxRGBValue: Float32 = 255.0
}
