//
//  ShowImageViewController.swift
//  camera using capture photo AVFoundation
//
//  Created by Digival on 09/08/23.
//

import UIKit
import PhotosUI

class ShowImageViewController: UIViewController {
    var isPlay = false
    var captureImage: UIImage?
    @IBOutlet var playerView: UIView!
    var livePhotoURL: URL?
    var videoPlayer: AVPlayer?
    @IBOutlet weak var showImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        showImage.isUserInteractionEnabled = true
        showImage.addGestureRecognizer(tapGestureRecognizer)
        
        let squareViewAction = UITapGestureRecognizer(target: self, action: #selector(ShowImageViewController.videoAction))
        playerView.addGestureRecognizer(squareViewAction)
      //  showImage.image = captureImage
        
        if livePhotoURL == nil {
            isPlay = true
            showImage.image = captureImage
         
        } else {
            forPlayVideo()
            showImage.isHidden = true
           
        }
        // Do any additional setup after loading the view.
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if isPlay == true {
            showImage.image = captureImage
        } else {
            videoPlayer?.play()
            showImage.isHidden = true
        }
    }
    @objc func videoAction() {
        if isPlay == true {
            showImage.image = captureImage
            videoPlayer?.pause()
        } else {
            showImage.image = captureImage
            showImage.isHidden = true
            videoPlayer?.play()
       
        }
    }
    @IBAction func backAction(_ sender: Any) {
        
        self.dismiss(animated: true)
    }

    func forPlayVideo() {
        if let videoUrl = livePhotoURL {
            
            videoPlayer = AVPlayer(url: videoUrl)
            // create instance of playerlayer with videoPlayer
            let playerLayer = AVPlayerLayer(player: videoPlayer)
            // set its videoGravity to AVLayerVideoGravityResizeAspectFill to make it full size
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            // add it to your view
            playerLayer.frame = self.view.frame
            playerView.layer.addSublayer(playerLayer)
        }
    }
}
