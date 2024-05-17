//
//  ImageEditView.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/17/24.
//

import SwiftUI
import Combine
import AVFoundation

struct ImageEditView: View {
    
    @EnvironmentObject private var viewModel: ImageCaptureViewModel
    @Environment(\.presentationMode) var presentation
    @State private var evPointLocation: CGPoint = CGPoint()
    @State private var imageFrame = CGRect()
    
    @State private var croppingHeight: CGFloat = 200
    @State private var croppingWidth: CGFloat = 200
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    Image(uiImage: viewModel.capturedImage ?? UIImage())
                        .resizable()
                        .scaledToFit()
                    CustomDraggableComponent(height: $croppingHeight, width: $croppingWidth)
                }
                Spacer()
            }
            Spacer()
            Button(action: {
                print("Certify Image")
                do {
                    ProverManager.shared.proveImage(signature: viewModel.signature, image: viewModel.capturedImage?.jpegData(compressionQuality: 1), publicKey: try SecureEnclaveManager.shared.exportPubKey(), croppingHeight: Int32(croppingHeight), croppingWidth: Int32(croppingWidth))
                    showAlert = true
                    self.presentation.wrappedValue.dismiss()
                } catch {
                    print("Failed")
                }
                
            }) {
                Text("Certify Image")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }.padding()
                .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Image uploaded for certification"),
                            message: Text("Others will be able to trust your photo soon...")
                        )
                    }
        }
    }
}

struct CustomDraggableComponent: View {
    @Binding var height: CGFloat
    @Binding var width: CGFloat

    @State var maxWidth = 512
    @State var maxHeight = 512
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                Rectangle()
                    .fill(.clear)
                    .border(.black)
                    .frame(minWidth: width, maxWidth: width, minHeight: height, maxHeight: height)
                
                HStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 80, height: 30)
                        .cornerRadius(10)
                        .overlay(Text("Drag"))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = height + value.translation.height
                                    let newWidth = width + value.translation.width
                                    height = min(max(200, newHeight), CGFloat(maxHeight))
                                    width = min(max(200, newWidth), CGFloat(maxHeight))
                                }
                        )
                    Spacer()
                }
            } .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

struct ImageEditView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditView()
    }
}
