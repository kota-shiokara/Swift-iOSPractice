//
//  TopViewContoroller.swift
//  SwiftQRReader
//
//  Created by 田島鼓太郎 on 2021/10/30.
//

import UIKit
import AVFoundation

class TopViewContoroller: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let session = AVCaptureSession()
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Start viewDidLoad()")
        
        // AV系機能の管理オブジェクト
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        
        // 対象のデバイス、多分カメラとかそういう入力装置を取得してそう
        let devices = discoverySession.devices
        
        print("device: \(String(describing: devices.first))")
        
        if let backCamera = devices.first {
            print("backCamera doing")
            print(backCamera)
            do {
                // 背面カメラ
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.cameraView.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.cameraView.layer.addSublayer(previewLayer)
                        
                        self.session.startRunning()
                        print("Start Running to Read")
                    } else {
                        print("canAddOutput false")
                    }
                } else {
                    print("canAddInput false")
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
        
        
        
        print("End viewDidLoad()")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in  metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRcodeの確認
            if metadata.type != .qr { continue }
            
            // QRcodeの内容が空か確認
            if metadata.stringValue == nil { continue }
            
            // TODO: ここにQRcode読んだ時の処理を書く
            if let url = URL(string: metadata.stringValue!) {
                self.session.stopRunning()
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                break
            }
        }
    }
}
