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

    var body: some View {
        ZStack {
            HostedCameraViewController(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Image(uiImage: viewModel.capturedImage ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
