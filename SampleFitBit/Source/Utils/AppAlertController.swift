
//
//  DPAlertController.swift
//  SampleFitBit
//
//  Created by mobiiworld on 28/06/19.
//  Copyright © 2019 mobiiworld. All rights reserved.
//

import Foundation
import UIKit

class AppAlertController: UIAlertController {
    
    var optionsArray:[String] = []
    var cancelText: String? {
        didSet {
            
        }
    }
    override var preferredStyle: UIAlertController.Style {
        return .actionSheet
    }
    
    typealias ListItemActionBlock = ((Int, String) -> Void)
    var didTap: ListItemActionBlock = {(index, options) in  }
    
    convenience init(title: String?, message: String?, optionsArray: [String]?, tintColor: UIColor?, cancelText: String?)  {
        self.init()
        self.title = title
        self.message = message
        self.optionsArray = optionsArray ?? []
        self.view.tintColor = tintColor ?? .black
        self.cancelText = cancelText
        self.commonInit()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        for (i, element) in optionsArray.enumerated() {
            let action = UIAlertAction(title: element, style: .default, handler: { (action) in
                self.didTap(i, element)
            })
            self.addAction(action)
        }
        guard let cancelText = self.cancelText else {
            return
        }
        let cancelActionButton = UIAlertAction(title: cancelText, style: .cancel) { _ in
//            self.didTap(self.optionsArray.count, cancelText)
        }
        self.addAction(cancelActionButton)
    }
}
