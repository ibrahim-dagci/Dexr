//
//  ViewController.swift
//  dexr
//
//  Created by ibrahim dağcı on 13.09.2023.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var dollarRateLabel: UILabel!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var euroToDollarExchangeRate: Double?
    var euroToTurkishLiraExchangeRate: Double?
    var currentDollarRate:Double?
    var addOrGet = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .dark) // Dilediğiniz blur stilini seçebilirsiniz.
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds // Arka planın boyutunu ekrana uyacak şekilde ayarlayın.
        view.addSubview(blurView) // Arka plana ekleyin.
        FirestoreService().getIsTrial(collection: "Control") { resault in
            switch resault{
                case .success(let res):
                if res == true{
                    UIView.animate(withDuration: 0.3, animations: {
                            blurView.alpha = 0.0 // Blur efektini yavaşça kaybetmeye başlayın
                        }) { (completed) in
                            if completed {
                                blurView.removeFromSuperview()// Modal içeriği kaldırın
                            }
                        }
                }
                else{
                    self.showAlert(title: "Attention", message: "The trial version has ended, please contact the administrator.")
                }
                
                case .failure(let err):
                    self.showAlert(title: "Error", message: err.localizedDescription)
            }
        }
        setupCamera()
        if endUpdateControl() == false{
            Webservice().downloadCurrency() { resault in
                switch resault{
                    case .success(let currencys):
                        self.euroToTurkishLiraExchangeRate =  currencys.rates["TRY"]
                        self.euroToDollarExchangeRate = currencys.rates["USD"]
                        UserDefaults.standard.set(Date(), forKey: "endDataUpdateDate")
                        self.currentDollarRate = self.convertDollarToTurkishLira(dollarAmount: 1)
                        UserDefaults.standard.set(self.currentDollarRate, forKey: "currentDollarRate")
                        DispatchQueue.main.async {
                            let formattedString = String(format: "%.3f", self.currentDollarRate!)
                            self.dollarRateLabel.text = "Current Dollar Rate: \(formattedString)"
                        }
                    case .failure(let error):
                    self.showAlert(title: "Error!", message: error.localizedDescription)
                }
            }
        }
        else{
            self.currentDollarRate = UserDefaults.standard.object(forKey: "currentDollarRate") as? Double
            let formattedString = String(format: "%.3f", currentDollarRate!)
            self.dollarRateLabel.text = "Current Dollar Rate: \(formattedString)"
        }
        
    }
    
    @IBAction func xButtonClick(_ sender: Any) {
        captureSession.stopRunning()
        previewLayer.removeFromSuperlayer()
        xButton.isHidden = true
    }
    @IBAction func getProduct(_ sender: Any) {
        xButton.isHidden = false
        addOrGet = false
        if !captureSession.isRunning {
            view.layer.addSublayer(previewLayer)
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    @IBAction func addProduct(_ sender: Any) {
        xButton.isHidden = false
        addOrGet = true
        if !captureSession.isRunning {
            view.layer.addSublayer(previewLayer)
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
}

extension ViewController{
    
    func convertDollarToTurkishLira(dollarAmount: Double) -> Double {
        let dollarToEuroRate = 1/euroToDollarExchangeRate!
        let dollarToTurkishLiraExchangeRate = dollarToEuroRate * euroToTurkishLiraExchangeRate!
        return dollarToTurkishLiraExchangeRate
    }
    
    func endUpdateControl() -> Bool{
        let endDataUpdateDate = UserDefaults.standard.object(forKey: "endDataUpdateDate")
        if let endDataUpdateDate = endDataUpdateDate as? Date{
            let dateDiff = dateDiff(frontDate: endDataUpdateDate, now: Date())
            if  dateDiff[1] as! Int >= 2 || dateDiff[0] as! String != "hour"{
                return false
            }
            else{
                return true
            }
        }
        return false
    }
    
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let oketButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(oketButton)
        self.present(alert, animated: true, completion: nil)
    }
    

    
    func dateDiff(frontDate:Date,now:Date) ->[Any]{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: frontDate, to: now)
        if let year = components.year, let month = components.month, let day = components.day,
            let hour = components.hour {
            print(components)
            print(Date())
            if year > 0 {
                let diff:[Any] = ["year",year]
                return diff
            }
            else if month > 0 {
                let diff:[Any] = ["month",month]
                return diff
            }
            else if day > 0 {
                let diff:[Any] = ["day",day]
                return diff
            }
            else if hour >= 0 {
                let diff:[Any] = ["hour",hour]
                return diff
            }
            else{
                let diff:[Any] = ["nil",-1]
                return diff
            }
        }
        else {
            let diff:[Any] = ["nil",-1]
            return diff
        }
    }
}


extension ViewController: AVCaptureMetadataOutputObjectsDelegate{
    func setupCamera() {
        xButton.isHidden = true
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(videoInput)
        } catch {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        
        
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                if let stringValue = readableObject.stringValue {
                    // Burada okunan barkodun değerini kullanabilirsiniz (stringValue)
                    captureSession.stopRunning()
                    previewLayer.removeFromSuperlayer()
                    xButton.isHidden = true
                    if addOrGet{
                        performSegue(withIdentifier: "addProduct", sender: stringValue)
                    }
                    else{
                        performSegue(withIdentifier: "getProduct", sender: stringValue)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addProduct"{
            let aimVC =  segue.destination as! AddProductVC
            aimVC.productCode = sender as? String
        }
        if segue.identifier == "getProduct"{
            let aimVC =  segue.destination as! GetProductVC
            aimVC.productCode = sender as? String
            aimVC.currentDollarRate = currentDollarRate
        }
    }
}

