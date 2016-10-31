//
//  Observable+Unwrap.swift
//  ForceTouchDemo
//
//  Created by chaoyang805 on 16/10/30.
//  Copyright © 2016年 chaoyang805. All rights reserved.
//

import Foundation
import RxSwift

protocol OptionalType {
    associatedtype Wrapped
    var asOptional: Wrapped? { get }
}

extension Optional: OptionalType {
    
    var asOptional: Wrapped? {
        return self
    }
}

extension Observable where Element: OptionalType {
    
    func unwrap() -> Observable<Element.Wrapped> {
        return self.filter { $0.asOptional != nil }.map { $0.asOptional! }
    }
}
