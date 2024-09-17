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
import OSLog

class ObjectDetectionViewModel: ObservableObject {
  @Published var classification: String?
  
  // Shared PhotoPickerViewModel
  @Published var photoPickerViewModel: PhotoPickerViewModel
  
  init(photoPickerViewModel: PhotoPickerViewModel) {
    self.photoPickerViewModel = photoPickerViewModel
  }
  
  @MainActor func classifyImage() {
    guard let image = photoPickerViewModel.selectedPhoto?.image, let cgImage = image.cgImage else {
      return
    }
    let request = VNClassifyImageRequest { [weak self] request, error in
      DispatchQueue.main.async {
        //process the request.results
        if let results = request.results as?
          [VNClassificationObservation] {
          let sortedResults = results
            .filter { $0.confidence > 0.01 }
            .sorted(by: { $0.confidence > $1.confidence })
            .map { "\($0.identifier) - \((Int($0.confidence * 100)))%" }
            .joined(separator: ", ")
          if !sortedResults.isEmpty {
              self?.classification = sortedResults
            } else {
              self?.classification = "Unknown"
          }
        }
        
      }
    }
#if targetEnvironment(simulator)
    request.usesCPUOnly = true 
#endif
    //What animals does the model know about
    if let objects = try? request.supportedIdentifiers() {
      for object in objects {
        logger.debug("Object: \(object)")
      }
    }
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try handler.perform([request])
    } catch {
      print("Failed to perform classification.\n\(error.localizedDescription)")
      self.classification = "Error"
    }
  }
}
