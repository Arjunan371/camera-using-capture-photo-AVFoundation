//
//  ViewController.swift
//  camera using capture photo AVFoundation
//
//  Created by Digival on 09/08/23.
//

import UIKit
import AVFoundation
//import PhotosUI

enum CameraType {
    case Front
    case Back
}




class ViewController: UIViewController {
    var camera: CameraType = .Back
//    var flash: AVCaptureDevice.FlashMode = .off
       var flash = false
    var isLive = false
    var movieOutput = AVCaptureMovieFileOutput()
    var audioInput: AVCaptureDeviceInput?
    var audioOutput: AVCaptureAudioDataOutput?
    var livePhotoURL: URL?
   
    @IBOutlet weak var liveButton: UIImageView!
    @IBOutlet weak var flashLightButton: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var squareView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var previewView: UIView!
    var videoOutput: AVCaptureFileOutput?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var backCamera: AVCaptureDevice?
    override func viewDidLoad() {
        super.viewDidLoad()
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.cornerRadius = 35
        borderView.layer.borderWidth = 5
        circleView.layer.cornerRadius = 25
        imageView.layer.cornerRadius = 70 / 4
        self.imageView.clipsToBounds = true
        imageView.isHidden = true

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let flashLight = UITapGestureRecognizer(target: self, action: #selector(flashLightAction(flashLight:)))
        flashLightButton.isUserInteractionEnabled = true
        flashLightButton.addGestureRecognizer(flashLight)
        
        let liveCamera = UITapGestureRecognizer(target: self, action: #selector(liveCameraAction(liveCamera:)))
        liveButton.isUserInteractionEnabled = true
        liveButton.addGestureRecognizer(liveCamera)
        
        let squareViewAction = UITapGestureRecognizer(target: self, action: #selector(ViewController.circleViewButtonAction))
        
        circleView.addGestureRecognizer(squareViewAction)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCaptureSession()
    }

    @objc func liveCameraAction(liveCamera:UITapGestureRecognizer) {
//        if let connection = movieOutput.connection(with: .video), connection.isActive && isLive == true {
//            // Already capturing, stop the sessio
//            liveButton.image = UIImage(named: "liveOn")
//            setupCaptureSession()
//            isLive = false
//        } else {
//            // Start capturing Live Photo
//            liveButton.image = UIImage(named: "liveOff")
//            setupLivePhotoCaptureSession()
//            startSession()
//            isLive = true
//        }
    }
    
    @objc func circleViewButtonAction() {
        if camera == .Back && flash == false {
            let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg] )
            toggleFlash(on: true)
            stillImageOutput?.capturePhoto(with: setting, delegate: self)
            toggleFlash(on: false)
            imageView.isHidden = false
        } else {
            let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.jpeg] )
            toggleFlash(on: false)
            stillImageOutput?.capturePhoto(with: setting, delegate: self)
            imageView.isHidden = false
        }
     
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let captureImagePass = segue.destination as! ShowImageViewController
        captureImagePass.captureImage = imageView.image
//        if isLive == false {
//            captureImagePass.livePhotoURL = livePhotoURL
//        } else {
//            captureImagePass.captureImage = imageView.image
//        }
  
    }
    @objc func imageTapped(tapGestureRecognizer:UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "liveImage", sender: self)

    }
    @IBAction func switchCamera(_ sender: UIButton) {
        switchCamera()
    }
    @objc func flashLightAction(flashLight: UITapGestureRecognizer){
        if flash == true {
            flashLightButton.image = UIImage(named: "flashOn")
           
            flash = false
        } else {
            print("flashOff")
            flashLightButton.image = UIImage(named: "flashOff")
         flash = true
        }
    }

    func switchCamera() {
        
        if camera == .Back {
            camera = .Front
        } else {
            camera = .Back
        }
        setupCaptureSession()
    }
    func forPreviewLayer(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
       // videoPreviewLayer?.frame = previewView.bounds
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewView?.layer.addSublayer(videoPreviewLayer ?? AVCaptureVideoPreviewLayer())
        
        DispatchQueue.main.async {
            self.captureSession?.startRunning()
            self.videoPreviewLayer?.frame = self.previewView.bounds
        }
    }
    

    func toggleFlash(on: Bool ) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            device.torchMode = on ? .on : .off
            if on {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }

            device.unlockForConfiguration()
          
        } catch {
            print("Error: \(error)")
        }
    }
    
    func setupCaptureSession() {
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        var captureDevice:AVCaptureDevice! = nil
        if (camera == .Front) {
            let videoDevices = AVCaptureDevice.devices(for: AVMediaType.video)
            
            for device in videoDevices{
                let device = device
                if device.position == AVCaptureDevice.Position.front {
                    captureDevice = device
                    break
                }
            }
        } else {
            captureDevice = AVCaptureDevice.default(for: AVMediaType.video )
            
        }
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        do {
  
            let input = try? AVCaptureDeviceInput(device: captureDevice)
            
            if (captureSession?.canAddInput(input!)) != nil {
                
                captureSession?.addInput(input!)
                
                stillImageOutput = AVCapturePhotoOutput()

                if (captureSession?.canAddOutput(stillImageOutput ?? AVCapturePhotoOutput()) != nil){
                    captureSession?.addOutput(stillImageOutput ?? AVCapturePhotoOutput())
                    forPreviewLayer()
                }
            }
 
        }
      
    }
    //MARK: LIVE PHOTO
    
//    func setupLivePhotoCaptureSession() {
//            let audioDevice = AVCaptureDevice.default(for: .audio)
//            do {
//                if let audioDevice = audioDevice {
//                    audioInput = try AVCaptureDeviceInput(device: audioDevice)
//                    if let audioInput = audioInput, captureSession?.canAddInput(audioInput) == true {
//                        captureSession?.addInput(audioInput)
//                    }
//                    audioOutput = AVCaptureAudioDataOutput()
//                    if let audioOutput = audioOutput, captureSession?.canAddOutput(audioOutput) == true {
//                        captureSession?.addOutput(audioOutput)
//                    }
//                    movieOutput = AVCaptureMovieFileOutput()
//                    if captureSession?.canAddOutput(movieOutput) == true {
//                        captureSession?.addOutput(movieOutput)
//                    }
//                    let outputPath = NSTemporaryDirectory() + "livePhotoMovie.mov"
//
//                    let outputURL = URL(fileURLWithPath: outputPath)
//                    livePhotoURL = outputURL
//                    movieOutput.startRecording(to: outputURL, recordingDelegate: self)
//                }
//            } catch {
//                print("Error setting audio device input: \(error)")
//            }
//        }
//
//    func startSession() {
//
//        if !(captureSession!.isRunning) {
//            //          videoQueue().async {
//            DispatchQueue.global().async {
//                self.captureSession?.startRunning()
//
//            }
//
//
//        }
  //  }
    
//    func stopSession() {
//        if ((captureSession?.isRunning) != nil) {
//            DispatchQueue.main.async {
//                self.captureSession?.stopRunning()
//            }
//        }
//    }
}
extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){
        
        guard let imageData = photo.fileDataRepresentation() else { return }
           let image = UIImage(data: imageData)
        imageView.image = image
    }
    
    }
//extension ViewController: AVCaptureFileOutputRecordingDelegate {
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        if let error = error {
//            print("Recording error: \(error)")
//        } else {
//            print("Recording finished: \(outputFileURL)")
//            DispatchQueue.main.async {
//                if self.isLive == false {
//                    self.performSegue(withIdentifier: "showImage", sender: outputFileURL)
//                } else {
//                    print("error")
//                }
//
//
//            }
//        }
//    }
//}


