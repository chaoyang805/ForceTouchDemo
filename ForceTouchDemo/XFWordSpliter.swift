//
//  XFWordSpliter.swift
//  ForceTouchDemo
//
//  Created by chaoyang805 on 2016/10/31.
//  Copyright © 2016年 chaoyang805. All rights reserved.
//

import UIKit
import RxSwift

class XFWordSpliter: NSObject {

    static let baseUrl = "http://ltpapi.voicecloud.cn/analysis"
    static let apiKey = "q114o7u7c8W2G0y2m5v0yLOZIVqCkpDmAKzTVIEs"
    
    class func splitText(_ text: String) -> Observable<String> {
        
        return Observable.create({ (observer: AnyObserver<Data>) -> Disposable in
            
            guard let encodedText = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                NSLog("invalid text:\(text)")
                return Disposables.create()
            }
            
            let query = "api_key=q114o7u7c8W2G0y2m5v0yLOZIVqCkpDmAKzTVIEs&text=\(encodedText)&pattern=ws&format=plain"

            guard let requestUrl = URL(string: "\(baseUrl)?\(query)") else {
                NSLog("invalid url")
                return Disposables.create()
            }
            
            let request = URLRequest(url: requestUrl)
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let d = data {
                    observer.onNext(d)
                }
                if let e = error {
                    observer.onError(e)
                }
                
                observer.onCompleted()
            }).resume()
            
            return Disposables.create()
            
        })
        .map{ String(data: $0, encoding: .utf8) }
        .unwrap()
        
    }
}
