//
//  MainViewController.swift
//  ProofPix
//
//  Created by Sofiane Larbi on 2/16/24.
//

import UIKit
import SwiftUI
import AVFoundation

typealias CaptureCompletion = (_ image: UIImage?, _ error: Error?)->Void

class CameraViewController: UIViewController {
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    private let settings = AVCapturePhotoSettings()
    private let photoOutput = AVCapturePhotoOutput()
    var screenRect: CGRect! = nil // For view dimensions
    var captureCompletion: CaptureCompletion? = nil
      
    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        switch UIDevice.current.orientation {
            // Home button on top
            case UIDeviceOrientation.portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
             
            // Home button on right
            case UIDeviceOrientation.landscapeLeft:
                self.previewLayer.connection?.videoOrientation = .landscapeRight
            
            // Home button on left
            case UIDeviceOrientation.landscapeRight:
                self.previewLayer.connection?.videoOrientation = .landscapeLeft
             
            // Home button at bottom
            case UIDeviceOrientation.portrait:
                self.previewLayer.connection?.videoOrientation = .portrait
                
            default:
                break
            }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
            case .authorized:
                permissionGranted = true
                
            // Permission has not been requested yet
            case .notDetermined:
                requestPermission()
                    
            default:
                permissionGranted = false
            }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
 
    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInDualCamera,for: .video, position: .back) else {
            print("Can't capture from device")
            return
        }
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Can't find video input")
            return
        }
        
        guard captureSession.canAddInput(videoDeviceInput) else {
            print("Can't add input")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // Preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        previewLayer.connection?.videoOrientation = .portrait
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
    
    func capturePhoto(captureCompletion: @escaping CaptureCompletion) {
        self.captureCompletion = captureCompletion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    

    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect) -> UIImage?
    {


        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * inputImage.scale,
                              y:cropRect.origin.y * inputImage.scale,
                              width:cropRect.size.width * inputImage.scale,
                              height:cropRect.size.height * inputImage.scale)


        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }


        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef, scale: inputImage.scale, orientation: .up)
        return croppedImage
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData) else {
            print("Image capture failed")
            captureCompletion?(nil, error)
            return
        }
        guard let croppedImage = cropImage(image, toRect: CGRect(x: 0, y: image.size.height / 2 - image.size.width / 2, width: image.size.width, height: image.size.width)) else {
            print("Failed to crop image")
            return
        }
        let resizedImage = UIImage(cgImage: (croppedImage.cgImage?.resize(size: CGSize(width: 256, height: 256))!)!, scale: image.scale, orientation: .right)
        captureCompletion?(resizedImage, nil)
    }
}

struct HostedCameraViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController

    @ObservedObject var viewModel: ImageCaptureViewModel

    func makeUIViewController(context: Context) -> CameraViewController {
        viewModel.cameraVC
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}

extension CGImage {
    func resize(size:CGSize) -> CGImage? {
        let width: Int = Int(size.width)
        let height: Int = Int(size.height)

        let bytesPerPixel = self.bitsPerPixel / self.bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel


        guard let colorSpace = self.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: self.bitsPerComponent, bytesPerRow: destBytesPerRow, space: colorSpace, bitmapInfo: self.alphaInfo.rawValue) else { return nil }

        context.interpolationQuality = .high
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}

extension UIImage {
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}
