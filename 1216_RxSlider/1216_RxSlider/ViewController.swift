//
//  ViewController.swift
//  1216_RxSlider
//
//  Created by Kimkeeyun on 14/12/2017.
//  Copyright © 2017 yunari.me. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    @IBOutlet weak var redValueLabel: UILabel!
    @IBOutlet weak var greenValueLabel: UILabel!
    @IBOutlet weak var blueValueLabel: UILabel!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var redValue: CGFloat = 0.5
    var greenValue: CGFloat = 0.5
    var blueValue: CGFloat = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorView.backgroundColor = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
        bind()
    }

}

extension ViewController {
   
    func bind() {
        
        redSlider.rx.value.subscribe(onNext: { value in
            self.redValueLabel.text = "\(value)"
            self.redValue = CGFloat(value)
            self.setColor(r: CGFloat(value), g: self.greenValue, b: self.blueValue)
        })
        .disposed(by: disposeBag)
        
        greenSlider.rx.value.subscribe(onNext: { value in
            self.greenValueLabel.text = "\(value)"
            self.greenValue = CGFloat(value)
            self.setColor(r: self.redValue, g: CGFloat(value), b: self.blueValue)
        }).disposed(by: disposeBag)
        
        blueSlider.rx.value.subscribe(onNext: { value in
            self.blueValueLabel.text = "\(value)"
            self.blueValue = CGFloat(value)
            self.setColor(r: self.redValue, g: self.greenValue, b: CGFloat(value))
        }).disposed(by: disposeBag)
        
    }
    
    func setColor(r: CGFloat, g: CGFloat, b: CGFloat) {
        colorView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
}
