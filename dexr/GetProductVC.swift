//
//  GetProductVC.swift
//  dexr
//
//  Created by ibrahim dağcı on 14.09.2023.
//

import UIKit
import FirebaseFirestore
class GetProductVC: UIViewController {
    @IBOutlet weak var productCodeLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    var productCode:String?
    var currentDollarRate:Double?
    override func viewDidLoad() {
        super.viewDidLoad()
        FirestoreService().getProduct(collection: "Products", productCode: productCode!) { resault in
            switch resault{
            case .success(let product):
                self.productCodeLabel.text = "Product Code: \(product.code)"
                self.productNameLabel.text = "Product Name: \(product.name)"
                self.productPriceLabel.text = "Product Price: \(String(format: "%.2f", (product.price * self.currentDollarRate!)))₺"
            case.failure(_):
                self.productCodeLabel.text = self.productCode!
                self.productNameLabel.text = " Product Name: Not found"
                self.productPriceLabel.text = "Product Price: Not found"
            }
        }
    }
    

    

}
