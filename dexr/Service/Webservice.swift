//
//  webservice.swift
//  dexr
//
//  Created by ibrahim dağcı on 13.09.2023.
//

import Foundation

class Webservice{
    let url = URL(string: "http://data.fixer.io/api/latest?access_key=38e535d7d5983bdf876b2b887ad23d3e")
    enum CurrencyError:Error{
        case serverError
        case parsingError
    }
    func downloadCurrency(completion:@escaping (Result<Currency,CurrencyError>)->()){
        URLSession.shared.dataTask(with: url!) { data, response, error in
            if let error = error{
                completion(.failure(.serverError))
            }
            else if let data = data{
               let currencyList =  try? JSONDecoder().decode(Currency.self, from: data)
                if let currencyList = currencyList{
                    completion(.success(currencyList))
                }
                else{
                    completion(.failure(.parsingError))
                }
            }
        }.resume()
    }
}
