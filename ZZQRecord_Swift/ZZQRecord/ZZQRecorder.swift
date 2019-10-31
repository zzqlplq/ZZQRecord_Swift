//
//  ZZQRecorder.swift
//  ZZQRecorder_Swift
//
//  Created by 郑志强 on 2019/9/27.
//  Copyright © 2019 郑志强. All rights reserved.
//

import Foundation
import AVFoundation


protocol ZZQRecorderDelegate {
    func didStartRecorder()
    func didFinishRecorder(filePath: String?, error: AudioRecordError?)
}


class ZZQRecorder: NSObject, AVAudioRecorderDelegate {
    
    var delegate: ZZQRecorderDelegate?
    var audioRecorder: AVAudioRecorder?
    var fileExtension: String!
    var filePath: String? {
        get {
            audioRecorder?.url.path
        }
    }
    
    var settings: [String : Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                   AVSampleRateKey: 8000,
                   AVNumberOfChannelsKey: 1,
                   AVLinearPCMBitDepthKey: 16,
                   AVLinearPCMIsFloatKey: true]

    init(fileExtension: String) {
        super.init()
        self.fileExtension = fileExtension
    }
    
    override convenience init() {
        self.init(fileExtension: "caf")
    }
    
    func startRecord() {
        ZZQRecorder.checkMicAuthorization { (permission) in
            if permission {
                self.recorderStartRecord()
            } else {
                self.delegate?.didFinishRecorder(filePath: self.filePath, error: .authorizationStatusDenied)
            }
        }
    }
    
    func stopRecord() {
        audioRecorder?.stop()
    }
    
    // MARK: - AVAudioRecorderDelegate

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        delegate?.didFinishRecorder(filePath: recorder.url.path, error: flag ? nil : .unkownError)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        delegate?.didFinishRecorder(filePath: self.filePath, error: .encodeError);
    }
    
    
    // MARK: - private function
    
    private func recorderStartRecord() {
        
        configRecordSession()
        resetAudioRecorder()
        audioRecorder = createAudioRecroder()

        guard audioRecorder != nil else {
            delegate?.didFinishRecorder(filePath: self.filePath, error: .initError)
            return
        }
        
        
        let result = audioRecorder!.record()
        if result {
            delegate?.didStartRecorder()
        } else {
            delegate?.didFinishRecorder(filePath: self.filePath, error: .startRedordError)
        }
    }
    
    
    private func getRecordFilePath() -> URL {

         let fileName = Util.dateToString()
         let cachePath: String = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let filePath = URL.init(fileURLWithPath: cachePath).appendingPathComponent(fileName).appendingPathExtension(fileExtension)

         return filePath
    }
    
   
    private func configRecordSession() {
         let session = AVAudioSession.sharedInstance()
         try? session.setCategory(.record)
         try? session.setActive(true)
    }
    
    
    private func createAudioRecroder() -> AVAudioRecorder? {
        let audioRecorder = try? AVAudioRecorder.init(url: getRecordFilePath(), settings: self.settings)
        audioRecorder!.delegate = self
        audioRecorder!.prepareToRecord()
        
        return audioRecorder
     }
     
    
    private func resetAudioRecorder() {
        audioRecorder?.stop()
        audioRecorder?.delegate = nil
        audioRecorder = nil
     }
}



extension ZZQRecorder {
    
    static func checkMicAuthorization(completion: ((Bool) -> Void)?) {
        let autoStatus = AVCaptureDevice.authorizationStatus(for: .audio)

    switch autoStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { (result) in
                completion?(result)
        }
        case .authorized:
            completion?(true)

        case .denied,.restricted:
            completion?(false)
        
        default:
            completion?(false)
        }
    }
}


private struct Util {
    
    static func dateToString(_ date: Date = Date.init(), _ dateFormat: String = "yyyy-MM-dd-HH-mm-ss") -> String {
        let formatter = DateFormatter.init()
         formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}



enum AudioRecordError: Error {
    case authorizationStatusDenied  // 权限拒绝
    case initError                  // 初始化失败
    case startRedordError           // 录音失败
    case encodeError                // 编码失败
    case unkownError                // 其他问题
}
