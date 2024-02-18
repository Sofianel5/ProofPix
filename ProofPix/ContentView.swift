//
//  ContentView.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/16/24.
//

import SwiftUI
import CoreData

class ImageCaptureViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var signature: Data?

    let cameraVC = CameraViewController()

    func captureImage() {
        cameraVC.capturePhoto(captureCompletion: { [weak self] image, error in
            DispatchQueue.main.async {
                self?.capturedImage = image
                if let signableImage = self?.capturedImage {
                    self?.signature = SecureEnclaveManager.shared.sign(message: signableImage.base64!)
                    print("Signed image")
                }
            }
        })
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ImageCaptureViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                HostedCameraViewController(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Button(action: {
                        print("button pressed")
                        path.append("ImageEditView")
                    }) {
                        Image(uiImage: viewModel.capturedImage ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 256, height: 256)
                    }.navigationDestination(for: String.self) { string in
                        switch string {
                        case "ImageEditView":
                            ImageEditView()
                                .environmentObject(viewModel)

                        default:
                            Text("Unknown")
                        }
                    }
                    Button(action: {
                        viewModel.captureImage()
                    }) {
                        Text("Capture Image")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }.padding()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
