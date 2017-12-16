//
//  URLToImageViewController.swift
//  RxTest
//
//  Created by leonard on 2017. 11. 30..
//  Copyright © 2017년 leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire //download

class URLToImageViewController: UIViewController {
    @IBOutlet weak var urlTextFeild: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
}

extension URLToImageViewController {
  
    //.flatMap -> Observable<T>
    //.flatMapLatest 또는 take(1)
    //.bind 내부에서 observer를 만들고 subscribe 한다.
    func bind() {
        goButton.rx.tap.asObservable()
            .flatMap{ [weak self] _ -> Observable<Void> in
                return Observable<Void>.create({ observer -> Disposable in
                    let alert = UIAlertController(title: "이미지 다운로드", message: "이미지를 다운로드 받으시겠습니까?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(
                        title: "YES",
                        style: .cancel,
                        handler: { (action) in
                            observer.onNext(())
                            observer.onCompleted()
                    }))
                    
                    alert.addAction(UIAlertAction(
                        title: "NO",
                        style: .default))
                    
                    self?.present(alert, animated: true, completion: nil)
                    
                    return Disposables.create {
                    }
                })
            }.flatMapLatest { [weak self] _ -> Observable<String> in
                guard let `self` = self else { return Observable.empty() }
                return self.urlTextFeild.rx.text.orEmpty.asObservable()
            }.map { text -> URL in
                return try text.asURL()
            }.filter { (url: URL) -> Bool in
                let imageExtensions = ["jpg", "jpeg", "png", "gif"]
                return imageExtensions.contains(url.pathExtension)
            }.flatMap { (url: URL) -> Observable<UIImage> in
                return ImageAPI.downloadImage(url: url)
            }.bind(to: imageView.rx.image).disposed(by: disposeBag)
    }
    
}


struct ImageAPI {
    
    static func downloadImage(url: URL) -> Observable<UIImage> {
        return Observable<UIImage>.create({ observer -> Disposable in
            let destination = DownloadRequest.suggestedDownloadDestination()
            let request = Alamofire.download(url, to: destination).response(completionHandler:
            { (response: DefaultDownloadResponse) in
                if let data = response.destinationURL, let image = UIImage(contentsOfFile: data.path) {
                    // API call -> data -> onNext() -> onCompleted()
                    observer.onNext(image)
                    observer.onCompleted()
                }
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }
    
}

