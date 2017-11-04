# RxSwift
- 2017.10.26 ~ 2017.12.30

## 1주차

### 1-1. Handling Cocoapods
- [Getting Started](https://guides.cocoapods.org/using/getting-started.html)
- [Alamofire](https://cocoapods.org/?q=alamofire)

### 1-2. Setting podfile
- **Alamofire, SwiftyJSON, OAuthSwift**

```
target 'codekit' do

use_frameworks!
pod 'Alamofire', '~> 4.5'
pod 'AlamofireImage’
pod 'SwiftyJSON'
pod 'OAuthSwift', '~> 1.1.2'

end
```

### 1-3. API (developer.github.com)
- [REST API v3](https://developer.github.com/v3/issues/)

### 1-4. Alamofire Software Foundation
- [Alamofire Software Foundation](https://github.com/Alamofire/Foundation)
- **Alamofire**: An HTTP networking library for iOS and OS X
- **AlamofireImage**: An image component library for Alamofire
- **AlamofireNetworkActivityIndicator**: An extension for controlling the visibility of the network activity indicator on iOS

### 1-5. Handling Git
- [Using Git with Terminal](https://github.com/codepath/ios_guides/wiki/Using-Git-with-Terminal)

## 2주차
- Github API를 통해, Issue Tracking App 만들기

### 2-1. 모델 구조체 및 유틸리티 구현
- `struct Model`
- `final class GlobalState`
- `struct App`, `protocol API`
- `struct GitHubAPI: API` : OAuth 인증 후 UserDefault 이용한 토큰 저장 
- `enum GitHubRouter`

### 2-2. ViewControllers
- LoginViewController
- RepoViewController
- ReposViewController
- IssuesViewController

### 2-3. nib파일을 통한 cell및 footer view 구현
- IssueCell
- LoadMoreFooterView (콜렉션뷰의 푸터뷰 구현)


<hr>

# 질문
1. `stateButton.isSelected = issue.state == .closed` 여기에서, `issue.state == closed` 이면 `isSelected`가 `true`가 되는데,
isSelected 되었을 때 image는 image name `(_open / _close)`를 보고 자동으로 결정되는 것인가요?


2. 아래에서 cellFromNib을 구현하는 이유는 무엇인가요?

```
extension IssueCell {
    //cellFromNib을 호출할 때마다 nib에서 하나씩 Cell을 가져온다.
    static var cellFromNib: IssueCell {
        guard let cell = Bundle.main.loadNibNamed("IssueCell", owner: nil, options: nil)?.first as? IssueCell else { return IssueCell() }
        return cell
    }
}
```

3. init(frame:)과 init(coder aDecoder: NSCoder) 두개 모두 구현하는 이유는 무엇인가요?

4. loadNib() 부분과 setupNib() 부분 잘 모르겠어요 ㅠ.ㅠ

```
class LoadMoreFooterView: UICollectionReusableView {

public func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LoadMoreFooterView", bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else { return UIView() }
        return view
    }
    
override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }
    
    // MARK: - NSCoding
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

fileprivate func setupNib() {
        let view = self.loadNib()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:[], metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:[], metrics:nil, views: bindings))
    }
```