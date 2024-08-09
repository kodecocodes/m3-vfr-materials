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
import UniformTypeIdentifiers
import UIKit

// The DocumentPicker struct allows integration of the UIDocumentPickerViewController into SwiftUI.
struct DocumentPicker: UIViewControllerRepresentable {
  // The Coordinator class acts as the delegate for the UIDocumentPickerViewController.
  class Coordinator: NSObject, UIDocumentPickerDelegate {
    // A reference to the parent DocumentPicker struct.
    var parent: DocumentPicker

    // Initializer to set up the coordinator with a reference to the parent.
    init(parent: DocumentPicker) {
      self.parent = parent
    }

    // This method is called when the user selects a document.
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      // Safely unwrap the first URL from the array of selected documents.
      guard let selectedFileURL = urls.first else { return }

      do {
        // Get the user's document directory.
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create the destination URL by appending the file name to the document directory path.
        let destinationURL = documentDirectory.appendingPathComponent(selectedFileURL.lastPathComponent)

        // Check if a file with the same name already exists at the destination.
        if FileManager.default.fileExists(atPath: destinationURL.path) {
          // If it exists, remove the existing file to avoid conflicts.
          try FileManager.default.removeItem(at: destinationURL)
        }

        // Copy the selected file to the destination URL.
        try FileManager.default.copyItem(at: selectedFileURL, to: destinationURL)
        print("File copied to \(destinationURL)")

        // Attempt to load the copied file as a UIImage and assign it to the parent's selectedImage binding.
        parent.selectedImage = UIImage(contentsOfFile: destinationURL.path)
      } catch {
        // Handle any errors that occur during file operations.
        print("Error copying file: \(error)")
      }
    }
  }

  // A binding to the selectedImage, allowing the parent view to update when an image is selected.
  @Binding var selectedImage: UIImage?

  // This method creates an instance of the Coordinator class, linking it with the DocumentPicker.
  func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  // This method creates and configures the UIDocumentPickerViewController.
  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    // Create a document picker that can open JPEG and PNG files.
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.jpeg, UTType.png])

    // Set the coordinator as the delegate to handle the document picking process.
    documentPicker.delegate = context.coordinator
    return documentPicker
  }

  // This method allows for updates to the UIDocumentPickerViewController, but is not used in this case.
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    // No updates are needed for this view controller in this example.
  }
}


