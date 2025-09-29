/// Copyright (c) 2024 Kodeco Inc.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import Combine
import Vision
import OSLog

let logger = Logger() as Logger

class ImageViewModel: ObservableObject {
  @Published var faceRectangles: [CGRect] = []
  @Published var currentIndex: Int = 0
  @Published var errorMessage: String? = nil
  
  // Shared PhotoPickerViewModel
  @Published var photoPickerViewModel: PhotoPickerViewModel
  
  init(photoPickerViewModel: PhotoPickerViewModel) {
    self.photoPickerViewModel = photoPickerViewModel
  }
  
  @MainActor func detectFaces() {
    currentIndex = 0
    guard let image = photoPickerViewModel.selectedPhoto?.image else {
      DispatchQueue.main.async {
        self.errorMessage = "No image available"
      }
      return
    }
    
    guard let cgImage = image.cgImage else {
      DispatchQueue.main.async {
        self.errorMessage = "Failed to convert UIImage to CGImage"
      }
      return
    }
    
    let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
      if let error = error {
        DispatchQueue.main.async {
          self?.errorMessage = "Face detection error: \(error.localizedDescription)"
        }
        return
      }
      
      let rectangles: [CGRect] = request.results?.compactMap {
        guard let observation = $0 as? VNFaceObservation else { return nil }
        return observation.boundingBox
      } ?? []
      
      DispatchQueue.main.async {
        self?.faceRectangles = rectangles
        self?.errorMessage = rectangles.isEmpty ? "No faces detected" : nil
      }
    }
    
#if targetEnvironment(simulator)
    let supportedDevices = try! faceDetectionRequest.supportedComputeStageDevices
    if let mainStage = supportedDevices[.main] {
      if let cpuDevice = mainStage.first(where: { device in
        device.description.contains("CPU")
      }) {
        faceDetectionRequest.setComputeDevice(cpuDevice, for: .main)
      }
    }
#endif

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    do {
      try handler.perform([faceDetectionRequest])
    } catch {
      DispatchQueue.main.async {
        self.errorMessage = "Failed to perform detection: \(error.localizedDescription)"
      }
    }
  }
  
  func nextFace() {
    if faceRectangles.isEmpty { return }
    currentIndex = (currentIndex + 1) % faceRectangles.count
  }
  
  func previousFace() {
    if faceRectangles.isEmpty { return }
    currentIndex = (currentIndex - 1 + faceRectangles.count) % faceRectangles.count
  }
  
  var currentFace: CGRect? {
    guard !faceRectangles.isEmpty else { return nil }
    return faceRectangles[currentIndex]
  }
  
  func adjustOrientation(orient: UIImage.Orientation) -> UIImage.Orientation {
    switch orient {
    case .up: return .downMirrored
    case .upMirrored: return .up
      
    case .down: return .upMirrored
    case .downMirrored: return .down
      
    case .left: return .rightMirrored
    case .rightMirrored: return .left
      
    case .right: return .leftMirrored //check
    case .leftMirrored: return .right
      
    @unknown default: return orient
    }
  }
  
  func drawVisionRect(on image: UIImage?, visionRect: CGRect?) -> UIImage? {
    guard let image = image, let cgImage = image.cgImage else {
      return nil
    }
    guard let visionRect = visionRect else { return image }
    
    // Get image size and prepare the context
    let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
    
    UIGraphicsBeginImageContextWithOptions(imageSize, false, image.scale)
    
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    
    //    // Adjust the context based on the image orientation
    //    switch image.imageOrientation {
    //    case .right:
    //        context.translateBy(x: imageSize.width, y: 0)
    //        context.rotate(by: .pi / 2)
    //    case .left:
    //        context.translateBy(x: 0, y: imageSize.height)
    //        context.rotate(by: -.pi / 2)
    //    case .down:
    //        context.translateBy(x: imageSize.width, y: imageSize.height)
    //        context.rotate(by: .pi)
    //    case .upMirrored:
    //        context.translateBy(x: imageSize.width, y: 0)
    //        context.scaleBy(x: -1, y: 1)
    //    case .downMirrored:
    //        context.translateBy(x: 0, y: imageSize.height)
    //        context.scaleBy(x: 1, y: -1)
    //    case .leftMirrored:
    //        context.translateBy(x: imageSize.height, y: 0)
    //        context.scaleBy(x: -1, y: 1)
    //        context.rotate(by: .pi / 2)
    //    case .rightMirrored:
    //        context.translateBy(x: imageSize.width, y: imageSize.height)
    //        context.scaleBy(x: -1, y: 1)
    //        context.rotate(by: -.pi / 2)
    //    default:
    //        break
    //    }
    
    // Draw the original image
    context.draw(cgImage, in: CGRect(origin: .zero, size: imageSize))
    
    // Calculate the rectangle using VNImageRectForNormalizedRect
    let correctedRect = VNImageRectForNormalizedRect(visionRect, Int(imageSize.width), Int(imageSize.height))
    
    // Draw the vision rectangle on the image
    UIColor.red.withAlphaComponent(0.3).setFill()
    let rectPath = UIBezierPath(rect: correctedRect)
    rectPath.fill()
    
    UIColor.red.setStroke()
    rectPath.lineWidth = 2.0
    rectPath.stroke()
    
    // Get the resulting UIImage
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    
    logger.debug("original orientation is \(image.imageOrientation.rawValue)")
    // End image context
    UIGraphicsEndImageContext()
    let correctlyOrientedImage = UIImage(cgImage: newImage!.cgImage!, scale: image.scale, orientation: adjustOrientation(orient: image.imageOrientation))
    
    logger.debug("final orientation \(correctlyOrientedImage.imageOrientation.rawValue)")
    
    return correctlyOrientedImage
  }
}
