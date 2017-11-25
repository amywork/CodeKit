//: Playground - noun: a place where people can play

import UIKit

public struct Some<Base> {
//    let base: Base
//    init(_ base: Base) {
//        self.base = base
//    }
    init() {
        
    }
    
}

protocol BoxCompatible {
    associatedtype CompatibleType
    var box: Some<CompatibleType> { get set }
    static var box: Some<CompatibleType>.Type { get set }
}

// extension은 override 못함
extension BoxCompatible {
    var box: Some<Self> {
        get {
            return Some()
        }
        set {
            
        }
    }
    
    static var box: Some<Self>.Type {
        get {
            return Some<Self>.self
        }
        set {
            
        }
    }
}

class A {
    
}

extension A: BoxCompatible {

}

class B {

}

extension B: BoxCompatible {
    
}



extension Some where Base: A {
    var description: String  {
        return "A.box.description"
    }
    
    static var className: String {
        return "A"
    }
}

extension Some where Base: B {
    var someBoxingValue: Int {
        return 10
    }
}

let a = A()
a.box.description
A.box.className

let b = B()
b.box.someBoxingValue

