# RxSwift
- **2017.10 ~ 2017.12 (8w, 40h)**
- [강사님 github](https://github.com/intmain)

## 1주차 (17.10.28 - 5h)
- 핵심 기능 정의, 개발 환경 설정 (Cocoapod, 사용할 api 등)
- 스위프트 고급 문법 설명

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

<hr>

## 2주차 (17.11.04 - 5h)
- Github API를 통해, Issue Tracking App 핵심 페이지 구성

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

## 3주차 (17.11.11 - 5h)