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
    @State private var evPointLocation: CGPoint = CGPoint()
    @State private var imageFrame = CGRect()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                GeometryReader { viewGeo in
                    GeometryReader { imgGeo in
                        ZStack {
                            Image(uiImage: viewModel.capturedImage ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .onReceive(Just(imgGeo), perform: { _ in
                                    let localFrame = imgGeo.frame(in: .local)
                                    imageFrame = AVMakeRect(aspectRatio: (viewModel.capturedImage ?? UIImage()).size, insideRect: localFrame)
                                })
                            EVPointView()
                                .position(evPointLocation)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        if imageFrame.contains(value.location) {
                                            self.evPointLocation = value.location
                                        }
                                    })
                                .onAppear {
                                    evPointLocation = CGPoint(x: imageFrame.origin.x, y: imageFrame.origin.y)
                                }
                            EVPointView()
                                .position(evPointLocation)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        if imageFrame.contains(value.location) {
                                            self.evPointLocation = value.location
                                        }
                                    })
                                .onAppear {
                                    evPointLocation = CGPoint(x: imageFrame.origin.x + 50, y: imageFrame.origin.y)
                                }
                            EVPointView()
                                .position(evPointLocation)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        if imageFrame.contains(value.location) {
                                            self.evPointLocation = value.location
                                        }
                                    })
                                .onAppear {
                                    evPointLocation = CGPoint(x: imageFrame.origin.x, y: imageFrame.origin.y + 50)
                                }
                            EVPointView()
                                .position(evPointLocation)
                                .gesture(DragGesture()
                                    .onChanged { value in
                                        if imageFrame.contains(value.location) {
                                            self.evPointLocation = value.location
                                        }
                                    })
                                .onAppear {
                                    evPointLocation = CGPoint(x: imageFrame.origin.x + 50, y: imageFrame.origin.y + 50)
                                }
                        } //: ZStack
                    } //: imgGeo
                    .frame(width: viewGeo.size.width * 0.8, height: viewGeo.size.height * 0.8)
                    .background(.black)
                }
                Spacer()
            }
            Spacer()
            Button(action: {
                print("Certify Image")
            }) {
                Text("Certify Image")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }.padding()
        }
    }
}

struct EVPointView: View {
    var id = UUID()
    var location: CGPoint = CGPoint(x: 50, y: 50)
    
    var body: some View {
        Capsule(style: .continuous)
            .stroke(.regularMaterial, style: StrokeStyle(lineWidth: 2))
            .background(Capsule().fill(.ultraThinMaterial))
            .frame(width: 30, height: 30)
    }
}

struct ImageEditView_Previews: PreviewProvider {
    static var previews: some View {
        ImageEditView()
    }
}
