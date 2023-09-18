//
//  AddProductVC.swift
//  dexr
//
//  Created by ibrahim dağcı on 14.09.2023.
//

import UIKit

class AddProductVC: UIViewController {

    @IBOutlet weak var productPriceField: UITextField!
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var productCodeLabel: UILabel!
    var productCode:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInit()
        if let productCode = productCode {
            productCodeLabel.text = productCode
        }
    }
    
    @IBAction func addProductClick(_ sender: Any) {
        if let price =  Double(productPriceField.text!.replacingOccurrences(of: ",", with: ".")),let name = productNameField.text{
            let product = Product(name: name, price: price, code: productCode!)
            FirestoreService().setDocument(collection: "Products", product: product) { resault in
                switch resault{
                case .success(_):
                    self.showAlert(title: "Succes", message: "The product has been successfully registered",style: true)
                    return
                case.failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription,style: false)
                }
            }
        }else{
            self.showAlert(title: "Attention!", message: "Please enter correctly data and do not leave the price field blank.",style: false)
        }
        
    }
}

extension AddProductVC{
    func setupInit(){
        let touchSensor = UITapGestureRecognizer(target: self, action: #selector(self.touchTheFreeArea))
        view.addGestureRecognizer(touchSensor)
        
    }
    @objc func touchTheFreeArea(){
        view.endEditing(true)
    }
    
    func showAlert(title:String,message:String,style:Bool){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let oketButton = UIAlertAction(title: "ok", style: .default) {  (_) in
            self.dismiss(animated: true)
        }
        let cancelButton = UIAlertAction(title: "cancel", style: .destructive) {  (_) in
            
        }
        if style{
            alert.addAction(oketButton)
        }
        else{
            alert.addAction(cancelButton)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
