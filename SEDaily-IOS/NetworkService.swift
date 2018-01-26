//
//  NetworkRequest.swift
//  SEDaily-IOS
//
//  Created by Berk Mollamustafaoglu on 13/01/2018.
//  Copyright © 2018. All rights reserved.
//

import Foundation
import Alamofire

protocol NetworkService {
    func networkRequest(_ urlString: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?) -> DataRequest
}

extension NetworkService {
    func networkRequest(_ urlString: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding = URLEncoding.default, headers: HTTPHeaders?) {
        return networkRequest(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
}
