//
//  FirestoreService.swift
//  dexr
//
//  Created by ibrahim dağcı on 14.09.2023.
//

import Foundation
import FirebaseFirestore
class FirestoreService{
    let firestoreDataBase = Firestore.firestore()
    enum ProductError:Error{
        case serverError
        case notFindError
    }
    func getProduct(collection:String,productCode:String,completion:@escaping (Result<Product,ProductError>)->()){
        let query = firestoreDataBase.collection(collection).whereField("code", isEqualTo: productCode)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(.serverError))
                } else {
                    if querySnapshot?.isEmpty != true{
                        for product in querySnapshot!.documents{
                            if let name = product.get("name") as? String , let code = product.get("code") as? String , let price = product.get("price") as? Double{
                                let product = Product(name: name, price: price, code: code)
                                completion(.success(product))
                            }
                        }
                    }
                    else{
                        completion(.failure(.notFindError))
                    }
                }
            }
    }
    
    
    func setDocument(collection:String,product:Product,completion:@escaping (Result<Bool,ProductError>)->()){
        firestoreDataBase.collection(collection).document(product.code).setData([
            "name": product.name,
            "code": product.code,
            "price": product.price
        ]) { err in
            if let err = err {
                completion(.failure(.serverError))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func getIsTrial(collection:String,completion:@escaping (Result<Bool,ProductError>)->()){
        let query = firestoreDataBase.collection(collection).document("isTrial")
            
        query.getDocument { snapshot, error in
            if let control = snapshot?.get("isTrial") as? Bool{
                completion(.success(control))
            }
            else{
                completion(.failure(.serverError))
            }
        }
    }
}


