# RxSwift
- **2017.10 ~ 2017.12 (8w, 40h)**
- [강사님 github](https://github.com/intmain)

## 1주차 (17.10.28 - 5h)
- **Github Issue Tracking App** 핵심 기능 정의
- 개발 환경 설정 (Cocoapod)
- 스위프트 고급 문법 (Enum, Closure, 함수커링)

### 1-1. Handling Cocoapods
- [Getting Started](https://guides.cocoapods.org/using/getting-started.html)
- [Alamofire](https://cocoapods.org/?q=alamofire)

### 1-2. Setting podfile
- **Alamofire, SwiftyJSON, OAuthSwift**

```
target 'codekit' do

use_frameworks!
pod 'Alamofire',
pod 'AlamofireImage’
pod 'SwiftyJSON'
pod 'OAuthSwift',

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
- `struct GitHubAPI: API` : OAuth 인증 후 UserDefault 토큰 저장 
- `enum GitHubRouter`

### 2-2. ViewControllers
- LoginViewController
- RepoViewController
- ReposViewController
- IssuesViewController

### 2-3. xib파일을 통한 cell및 footer view 구현
- IssueCell
- LoadMoreFooterView (콜렉션뷰의 푸터뷰 구현)


<hr>

## 3주차 (17.11.11 - 5h)
- ViewController 추상화 작업 및 API 추가 구성 (이슈 상세 페이지 구현 및 코멘트 포스팅 기능 구현)

### 3-1. API 및 GitHubRouter 추가 구성
- `protocol API`
- `enum GitHubRouter`

### 3-2. ViewControllers (리스트뷰 추상화 작업)
- ListViewController
- IssuesViewController
- IssueDetailViewController
- CreateIssueViewController

### 3-3. xib파일을 통한 header view 구현
- IssueDetailHeaderView

<hr>

## 4주차 (17.11.18 - 5h)
- [RxSwift 개념 및 문법 실습](https://github.com/younari/RxSwiftExample)
- [ReactiveX](http://reactivex.io)
- [rxmarbles](http://rxmarbles.com)

<hr>

## 5~8주차 ( - 17.12.16, 20h)
- 1~4주차 내용을 RxSwift로 재구현
