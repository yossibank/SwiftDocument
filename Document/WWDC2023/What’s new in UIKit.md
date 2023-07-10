# What’s new in UIKit

## Key features

* **Xcode previews**

``` swift
// UIKitでPreview表示

// UIViewController
class LibraryViewController: UIViewController {
    // ...
}

#Preview("Library") {
    let controller = LibraryViewController()
    controller.displayCuratedContent = true
    return controller
}

// UIView
class SlideshowView: UIView {
    // ...
}

#Preview("Memories") {
    let view = SlideshowView()
    view.title = "Memories"
    view.subtitle = "Highlights from the pass year"
    view.images = ...
    return view
}
```

* **View controller lifecycle updates**

``` swift
// viewIsAppearing(iOS13から対応)
// viewWillAppearの後、viewDidAppearの前に呼び出される
// 呼び出された際にViewControllerとViewの最新のtrait collectionを保持している
// 初期のジオメトリ(サイズ)に依存する処理を書くのに理想的なコールバックとなる

// viewWillLayoutSubviews・viewDidLayoutSubviewsとの違い
// layoutSubviewsが実行されるたびに上記は発生するため、遷移中に複数回発生することもあれば、表示された後に発生する可能性もある
// viewIsAppearingは表示遷移中に一度のみ呼び出され、Viewがレイアウトを必要としない場合でも呼び出される
```

<img src="../../Image/WWDC2023/What’s_new_in UIKit_1.png" width=100%>

* **Trait system enhancements**
  * カスタムtraitを定義可能に
  * 「Unleash the UIKit trait system」参照


* **Attatched symbol images**

``` swift
// アニメーション付き画像の提供

// バウンド
imageView.addSymbolEffect(.bounce)
// バリアブルカラー(無限ループ)
imageView.addSymbolEffect(.variableColor.iterative)
// アニメーション終了
imageView.removeSymbolEffect(ofType: .variableColor)
// トランジション
imageView.setSymbolImage(pauseImage, contentTransiton: .replace.offUp)
```

* **Empty states**

``` swift
// UIContentUnavailableConfiguration
// コンテンツがない状態を表す新しいAPI

// コンテンツがないView作成
var config = UIContentUnavailableConfiguration.empty()

config.image = UIImage(systemName: "star.fill")
config.text = "No Favorites"
config.secondaryText = "Your favorite translations will appear here."

viewController.contentUnavailableConfiguration = config

// ローディング状態のView作成
let config = UIContentUnavailableConfiguration.loading()
viewController.contentUnavailableConfiguration = config

// SwiftUIViewでの表現
let config = UIHostingConfiguration {
    VStack {
        ProgressView(value: progress)
        Text("Downloading file...")
            .foregroundStyle(.secondary)
    }
}
viewController.contentUnavailableConfiguration = config

// updateContentUnavailableConfiguration(using: state)
// 実際の空状態を表すViewの表示を管理する場所

override func updateContentUnavailableConfiguration(
    using state: UIContentUnavailableConfigurationState
) {
    var config: ContentUnavailableConfiguration?

    if searchResults.isEmpty {
        config = .search()
    }
    contentUnavailableConfiguration = config
}

searchResults = backingStore.results(for: query)
setNeedsUpdateContentUnavailableConfiguration()
```

## Internatoinalization

``` swift
// line-heightの動的高さ調整
// 自動的に適用される

// 画像Localeの適用
let locale = Locale(languageCode: .japanese)

imageView.image = UIImage(
    systemName: "character.textbox",
    withConfiguration: UIImage.SymbolConfiguration(locale: locale)
)
```

## Improvements for iPad

* **ドラッグジェスチャーを開始できる領域の拡大**
  * UINavigationBar内の任意の場所をドラッグでジェスチャーが開始する
  * UINavigationBarを使用していない場合はUIWindowSceneDragInteractionで任意のViewに追加できる

* **サイドバーの自動非表示**
  * 表示するように要求されない限りは非表示のまま

* **ドキュメントアプリケーションへのサポート**
  * UIDocumentViewControllerの提供

* **Apple Pencilの拡張**
  * PencilKitの新しいインク追加

* **キーボードでのスクロール**
  * UIScrollViewの拡張(Page Up, Page Down, Home, Endキーでスクロール)

## General enhancements

* **CollectionViewのパフォーマンス最適化**

``` swift
// Compositional Layout

// 最大アイテムのサイズを基準として一貫したサイズを指定する
NSCollectionLayoutDimension.uniformAcrossSiblings(estimate:)
```

* **Animation表現の追加**

``` swift
// spring animation

UIView.animate(springDuration: 0.5, bounce: 0.0) {
    circle.center.x += 100
}

UIView.animate {
    circle.center.x += 100
}
```

* **ステータスバーのスタイル**

``` swift
// デフォルトでスクロールした時の背景色の明るさに合わせて白黒の色が変更される
override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
}
```

* **ISO HDR画像のサポート**
  * UIImageView, UIGraphicsImageRenderer, UIImageReaderでサポート

* **UIPageContorolでの進捗表示**

``` swift
// UIPageControlTimerProgress

// ページの表示時間設定(10秒経過で自動的に次へ)
let timerProgress = UIPageControlTimerProgress(preferredDuration: 10)
pageControl.progress = timerProgress

// 自動設定
timerProgress.resumeTimer()

// 手動設定
myTimer.addPeriodicTimeObserver { timer in
    progress.currentProgress = Float(timer.seconds / timer.duration)
    // ...
}
```