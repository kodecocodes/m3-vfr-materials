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
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

class TextDetectionViewModel: ObservableObject {
  @Published var textRectangles: [(CGRect, String)] = []
  @Published var currentIndex: Int = 0
  @Published var maxTextHeight: CGFloat = 0
  
  // Shared PhotoPickerViewModel
  @Published var photoPickerViewModel: PhotoPickerViewModel
  
  init(photoPickerViewModel: PhotoPickerViewModel) {
    self.photoPickerViewModel = photoPickerViewModel
  }
  
  @MainActor func detectText() {
    currentIndex = 0
    
    guard let image = photoPickerViewModel.selectedPhoto?.image else { return }
    
    let textDetectionRequest = VNRecognizeTextRequest { [weak self] request, error in
      if let error = error {
        print("Text detection error: \(error)")
        return
      }
      self?.textRectangles = []
      //Process the observations
    }
    
    textDetectionRequest.recognitionLevel = .accurate
#if targetEnvironment(simulator)
    textDetectionRequest.usesCPUOnly = true
#endif
    guard let cgImage = image.cgImage else { return }
    let ciImage = CIImage(cgImage: cgImage)
    
    // Step 1: Adjust Exposure
    let exposureAdjustFilter = CIFilter.exposureAdjust()
    exposureAdjustFilter.inputImage = ciImage
    exposureAdjustFilter.ev = 1.0
    guard let exposureAdjustedImage = exposureAdjustFilter.outputImage
      else { return }
    
    // Step 2: Increase Contrast
    let contrastAdjustFilter = CIFilter.colorControls()
    contrastAdjustFilter.inputImage = exposureAdjustedImage
    contrastAdjustFilter.contrast = 4
    guard let processedImage = contrastAdjustFilter.outputImage else { return }
    
    let handler = VNImageRequestHandler(ciImage: processedImage, options: [:])
    
    do {
      try handler.perform([textDetectionRequest])
    } catch {
      print("Failed to perform detection: \(error)")
    }
  }
  
  func nextText() {
    if textRectangles.isEmpty { return }
    currentIndex = (currentIndex + 1) % textRectangles.count
  }
  
  func previousText() {
    if textRectangles.isEmpty { return }
    currentIndex = (currentIndex - 1 + textRectangles.count) % textRectangles.count
  }
  
  var currentText: (CGRect, String)? {
    guard !textRectangles.isEmpty else { return nil }
    return textRectangles[currentIndex]
  }
  
  func calculateMaxTextHeight() {
    // Extract all the text strings from textRectangles
    let texts = textRectangles.map { $0.1 }
    
    // This function calculates the max height for the texts
    let maxWidth = UIScreen.main.bounds.width - 32 // Assuming 16pt padding on each side
    let font = UIFont.systemFont(ofSize: 17)
    
    let maxHeight = texts.map { text -> CGFloat in
      let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
      let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
      print("Text: \(text)")
      print("Bounding box height: \(boundingBox.height)")
      return boundingBox.height
    }.max() ?? 0
    
    self.maxTextHeight = maxHeight + 32 // Add padding
    print("Calculated max text height: \(self.maxTextHeight)")
  }
}

