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
import UIKit

// This struct defines the main view for the document picker functionality.
struct DocumentPickerView: View {
  // State variable to control the presentation of the document picker sheet.
  @State private var showDocumentPicker = false
  
  // State variable to hold the selected image from the document picker.
  @State private var selectedImage: UIImage?
  
  // The body property defines the UI layout for this view.
  var body: some View {
    VStack {
      // Check if an image has been selected by the user.
      if let image = selectedImage {
        // If an image is selected, display it using the Image view.
        Image(uiImage: image)
          .resizable() // Make the image resizable to fit the frame.
          .scaledToFit() // Ensure the image maintains its aspect ratio while fitting the frame.
          .frame(width: 300, height: 300) // Set the frame size for the image display.
      } else {
        // If no image is selected, display a placeholder text.
        Text("No image selected")
      }
      
      // A button that triggers the document picker.
      Button(action: {
        // Set showDocumentPicker to true to present the document picker sheet.
        showDocumentPicker = true
      }) {
        // The appearance and styling of the button.
        Text("Select Image")
          .padding() // Add padding around the button text.
          .background(Color.blue) // Set the background color of the button.
          .foregroundColor(.white) // Set the text color of the button.
          .cornerRadius(10) // Apply rounded corners to the button.
      }
      // Present a sheet when showDocumentPicker is true. The sheet displays the DocumentPicker view.
      .sheet(isPresented: $showDocumentPicker) {
        // Pass the selectedImage binding to the DocumentPicker so it can update the selected image.
        DocumentPicker(selectedImage: $selectedImage)
      }
    }
  }
}

#Preview {
  DocumentPickerView()
}
