//
//  ImagePickerTestViewController.swift
//  RxTest
//
//  Created by leonard on 2017. 12. 1..
//  Copyright © 2017년 leonard. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class ImagePickerTestViewController: UIViewController {
    
    @IBOutlet var showPickerButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var progressbar: UIProgressView!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
}

extension ImagePickerTestViewController {
    
    func bind() {
        showPickerButton.rx.tap
            .flatMap { [weak self] _ in
                return UIImagePickerController.rx
                    .createWithParent(self) { picker in
                        picker.sourceType = .photoLibrary
                        picker.allowsEditing = false
                    }.flatMap {
                        $0.rx.didFinishPickingMediaWithInfo
                    }.take(1)
            }.map { info in
                return info[UIImagePickerControllerOriginalImage] as? UIImage
            }.subscribe(onNext: { (image: UIImage?) in
                self.imageView.rx.image.onNext(image)
                self.progressbar.isHidden = false
                self.uploadButton.isHidden = false
            }).disposed(by: disposeBag)
        
        
        // observeOn & subscribeOn 을 통한 thread 관리
        uploadButton.rx.tap.asObservable()
            .flatMap{ [weak self] _ -> Observable<Void> in
                UIAlertController.rx.showAlertTo(self, title: "업로드", message: "업로드 하시겠습니까?")
            }.map{ [weak self] _ -> UIImage? in
                return self?.imageView.image
            }.observeOn(SerialDispatchQueueScheduler(qos: .background))
            .flatMap { (image: UIImage?) -> Observable<Float> in
                guard let img = image else { return Observable.empty() }
                return API.upload(image: img)
            }.subscribeOn(MainScheduler.instance)
            .bind(to: progressbar.rx.progress)
            .disposed(by: disposeBag)
    }
    
}


struct API {
    static func upload(image: UIImage) -> Observable<Float> {
        guard let data = UIImagePNGRepresentation(image) else { return Observable.empty() }
        let imageSize: Float = Float(data.count) //image 크기
        return Observable<Float>.create({ (observer) -> Disposable in
            for i in stride(from: 0, to: imageSize, by: 40) {
                observer.onNext( Float(i / imageSize) )
            }
            observer.onNext( Float(1) )
            observer.onCompleted()
            return Disposables.create {
                
            }
        })
    }
}
