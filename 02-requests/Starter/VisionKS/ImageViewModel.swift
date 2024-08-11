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


      //process the results
    }

#if targetEnvironment(simulator)
    faceDetectionRequest.usesCPUOnly = true
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
}





