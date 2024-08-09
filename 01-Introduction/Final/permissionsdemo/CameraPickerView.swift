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
import AVFoundation

// The CameraViewModel class is responsible for managing the camera-related logic.
class CameraViewModel: ObservableObject {
  // Published properties that notify the view when they change.
  @Published var capturedImage: UIImage? // Stores the captured image.
  @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined // Tracks the camera permission status.

  // Initializer that checks the camera permissions when the view model is created.
  init() {
    checkCameraPermissions()
  }

  // Function to check the current camera permissions.
  func checkCameraPermissions() {
    // Get the current authorization status for the camera.
    let status = AVCaptureDevice.authorizationStatus(for: .video)

    // Update the cameraPermissionStatus property on the main thread.
    DispatchQueue.main.async {
      self.cameraPermissionStatus = status
    }
  }

  // Function to request camera permissions from the user.
  func requestCameraPermissions() {
    // Request access to the camera.
    AVCaptureDevice.requestAccess(for: .video) { granted in
      // Re-check the permissions after the user has responded to the request.
      self.checkCameraPermissions()
    }
  }
}

// The CameraView struct defines the UI for capturing an image using the camera.
struct CameraView: View {
  // The view model is used to manage state and business logic for the view.
  @StateObject private var viewModel = CameraViewModel()

  // State to control the presentation of the camera picker.
  @State private var showCameraPicker = false

  // The body property defines the UI layout for this view.
  var body: some View {
    VStack {
      // Check if an image has been captured by the user.
      if let image = viewModel.capturedImage {
        // If an image is captured, display it using the Image view.
        Image(uiImage: image)
          .resizable() // Make the image resizable to fit the frame.
          .scaledToFit() // Ensure the image maintains its aspect ratio while fitting the frame.
          .frame(width: 300, height: 300) // Set the frame size for the image display.
      } else {
        // If no image is captured, display a placeholder text.
        Text("No image captured")
      }

      // A button that triggers the camera or requests permissions.
      Button(action: {
        // Handle the action based on the current camera permission status.
        switch viewModel.cameraPermissionStatus {
        case .authorized:
          // If the user has already granted permission, show the camera picker.
          showCameraPicker = true
        case .notDetermined:
          // If the permission status is not determined, request permissions.
          viewModel.requestCameraPermissions()
        default:
          break // Handle other cases where permission is denied or restricted.
        }
      }) {
        // The appearance and styling of the button.
        Text("Capture Photo")
          .padding() // Add padding around the button text.
          .background(Color.blue) // Set the background color of the button.
          .foregroundColor(.white) // Set the text color of the button.
          .cornerRadius(10) // Apply rounded corners to the button.
      }
      // Present a sheet when showCameraPicker is true. The sheet displays the CameraPicker view.
      .sheet(isPresented: $showCameraPicker) {
        // Pass the capturedImage binding to the CameraPicker so it can update the selected image.
        CameraPicker(selectedImage: $viewModel.capturedImage)
      }

      // Display a message about the camera permission status.
      Text(permissionMessage)
        .padding()
    }
    // Check camera permissions when the view appears.
    .onAppear {
      viewModel.checkCameraPermissions()
    }
  }

  // A computed property that returns a message based on the camera permission status.
  private var permissionMessage: String {
    switch viewModel.cameraPermissionStatus {
    case .authorized:
      return "Camera permission granted."
    case .denied, .restricted:
      return "Camera permission denied. Please go to Settings to enable it."
    case .notDetermined:
      return "" // No message needed if the permission status is not determined.
    @unknown default:
      return "" // Handle any future cases that may be added to AVAuthorizationStatus.
    }
  }
}


#Preview {
  CameraView()
}
