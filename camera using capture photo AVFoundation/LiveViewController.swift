//
//  LiveViewController.swift
//  camera using capture photo AVFoundation
//
//  Created by Digival on 11/08/23.
//

import UIKit


class LiveViewController: UIViewController, PHLivePhotoViewDelegate {

    @IBOutlet weak var liveImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.livePhotoView()
        // Do any additional setup after loading the view.
    }


}
