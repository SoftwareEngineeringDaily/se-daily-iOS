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
    func networkRequest(_ urlString: URLConvertible, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding, headers: HTTPHeaders?, responseCallback: @escaping (DataResponse<Any>) -> Void)
}
