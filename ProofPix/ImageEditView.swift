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
                ZStack {
                    Image(uiImage: viewModel.capturedImage ?? UIImage())
                        .resizable()
                        .scaledToFit()
                    CustomDraggableComponent(height: (viewModel.capturedImage ?? UIImage()).size.height, width: (viewModel.capturedImage ?? UIImage()).size.width)
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

struct CustomDraggableComponent: View {
    @State var height: CGFloat = 200
    @State var width: CGFloat = 200
    
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
                        .overlay(Text("Drag to crop"))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // This code allows resizing view min 200 and max to parent view size
                                    height = min(max(200, height + value.translation.height), CGFloat(maxHeight)) // 45 for Drag button height + padding
                                    width = min(max(200, height + value.translation.width), CGFloat(maxHeight))
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
