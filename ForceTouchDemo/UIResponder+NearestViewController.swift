//
//  UIResponder+NearestViewController.swift
//  ForceTouchDemo
//
//  Created by chaoyang805 on 2016/10/31.
//  Copyright © 2016年 chaoyang805. All rights reserved.
//

import UIKit

extension UIResponder {
    
    func findNearestViewController() -> UIViewController? {
        if self.isKind(of: UIViewController.self) {
            return self as? UIViewController
        }
        
        var responder: UIResponder? = self
        
        while responder != nil && !responder!.isKind(of: UIViewController.self) {
            responder = responder?.next
        }
        return responder as? UIViewController
    }
}
