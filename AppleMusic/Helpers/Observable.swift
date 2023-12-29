//
//  Observable.swift
//  AppleMusic
//
//  Created by Halil Yavuz on 25.09.2023.
//

import Foundation

class Observable<T> {
    
    var value: T? {
        didSet {
            DispatchQueue.main.async {
                self.listener?(self.value)
            }
        }
    }
        
    init(_ value: T? ) {
        self.value = value
    }
    
    private var listener: ((T?) -> Void)?
    
    func bind(_ listener: @escaping ((T?)-> Void)) {
        listener(value)
        self.listener = listener
    }
}
