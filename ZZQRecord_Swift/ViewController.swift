//
//  ViewController.swift
//  ZZQRecord_Swift
//
//  Created by 郑志强 on 2019/9/27.
//  Copyright © 2019 郑志强. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, ZZQRecorderDelegate {

    var player: AVAudioPlayer?
    let recorder = ZZQRecorder.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recorder.delegate = self
        
        let startBtn = UIButton.init(frame: CGRect.init(x: 100, y: 100, width: 100, height: 50))
        startBtn.setTitle("开始录音", for: .normal)
        startBtn.addTarget(self, action: #selector(startRecorder), for: .touchUpInside)
        startBtn.backgroundColor = .red
        view.addSubview(startBtn)
    
        let stopBtn = UIButton.init(frame: CGRect.init(x: 100, y: 200, width: 100, height: 50))
        stopBtn.setTitle("结束录音", for: .normal)
        stopBtn.addTarget(self, action: #selector(stopRecorder), for: .touchUpInside)
        stopBtn.backgroundColor = .blue
        view.addSubview(stopBtn)
        
        let playBtn = UIButton.init(frame: CGRect.init(x: 100, y: 300, width: 100, height: 50))
        playBtn.setTitle("播放录音", for: .normal)
        playBtn.addTarget(self, action: #selector(playRecorder), for: .touchUpInside)
        playBtn.backgroundColor = .yellow
        
        view.addSubview(playBtn)
    }
    
    
    @objc func startRecorder() {
        recorder.startRecord()
    }
    
    
    @objc func stopRecorder() {
        recorder.stopRecord()
    }
    
    
    @objc func playRecorder() {
        
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback)
        try? session.setActive(true)

        self.player = try? AVAudioPlayer.init(contentsOf: URL.init(fileURLWithPath: self.recorder.filePath ?? ""))
        self.player?.play()
    }
    
    
    func didStartRecorder() {
        print("开始录音")
    }
    
    
    func didFinishRecorder(filePath: String?, error: AudioRecordError?) {
        if error == nil {
            print("录音成功 filePath: " + filePath!)
        } else {
            print("error:" + error!.localizedDescription)
        }
    }
}

