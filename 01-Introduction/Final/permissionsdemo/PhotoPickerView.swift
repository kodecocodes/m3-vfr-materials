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
import PhotosUI

// The PhotoPickerViewModel class is responsible for managing the photo selection logic.
// It interacts with the PhotosPicker and handles the loading of the selected image.
class PhotoPickerViewModel: ObservableObject {
  // Published property to store the selected image.
  // When this property changes, the view will automatically update.
  @Published var selectedImage: UIImage?

  // Published property to store the selected PhotosPickerItem.
  // When this property is set, it triggers the image loading process.
  @Published var selectedPickerItem: PhotosPickerItem? {
    didSet {
      // Load the image when a new item is selected.
      if let item = selectedPickerItem {
        loadImage(from: item)
      }
    }
  }

  // Private function to load the image from the selected PhotosPickerItem.
  // This method is called whenever the selectedPickerItem property is set.
  private func loadImage(from item: PhotosPickerItem) {
    // Asynchronously load the selected item as Data.
    item.loadTransferable(type: Data.self) { result in
      // Ensure that the UI updates occur on the main thread.
      DispatchQueue.main.async {
        switch result {
        case .success(let data):
          if let data = data, let uiImage = UIImage(data: data) {
            // If the data was successfully loaded and converted to a UIImage, set it to selectedImage.
            self.selectedImage = uiImage
          } else {
            // Handle the case where the data could not be converted to an image.
            print("Failed to convert data to UIImage")
          }
        case .failure(let error):
          // Handle any errors that occur during image loading.
          print("Error loading image: \(error)")
        }
      }
    }
  }
}

// The PhotoPickerView struct defines the UI for selecting a photo from the user's photo library using the PhotosPicker.
struct PhotoPickerView: View {
  // StateObject to manage the view model, which contains the business logic for the view.
  @StateObject private var viewModel = PhotoPickerViewModel()

  // The body property defines the UI layout for this view.
  var body: some View {
    VStack {
      // Check if an image has been selected by the user.
      if let image = viewModel.selectedImage {
        // If an image is selected, display it using the Image view.
        Image(uiImage: image)
          .resizable() // Make the image resizable to fit the frame.
          .scaledToFit() // Ensure the image maintains its aspect ratio while fitting the frame.
          .frame(width: 300, height: 300) // Set the frame size for the image display.
      } else {
        // If no image is selected, display a placeholder text.
        Text("No image selected")
      }

      // Use PhotosPicker for selecting a photo from the photo library.
      PhotosPicker(
        selection: $viewModel.selectedPickerItem, // Binding to the selected PhotosPickerItem
        matching: .images, // Limit the selection to images only.
        photoLibrary: .shared() // Access the shared photo library.
      ) {
        // The appearance and styling of the button.
        Text("Select Photo")
          .padding() // Add padding around the button text.
          .background(Color.blue) // Set the background color of the button.
          .foregroundColor(.white) // Set the text color of the button.
          .cornerRadius(10) // Apply rounded corners to the button.
      }
    }
  }
}

#Preview {
  PhotoPickerView()
}
