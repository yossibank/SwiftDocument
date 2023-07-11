# Build programmatic UI with Xcode Previews

## What are previews

* **Previewとは？**
  * Viewを作成したり設定したりするコードの断片

``` swift
// アプリにコンパイルされ、コードやリソースと一緒に表示される
// コードを変更することでXcodeが2つのことを行う
//  1. コードの変更を調べて、最小限のコードを再コンパイルする
//  2. Previewを再実行する
#Preview {
    MyView()
}
```

## Writing previews

* **Previewの書き方・コンテンツの種類**

``` swift
// Previewの初期化
#Preview {
    Content()
}

// Previewの名前、追加設定
#Preview("Name", configuration) {
    Content()
}

// SwiftUI(Viewを返却するのみ)
#Preview("2×2 Grid", traits: .landscapeLeft) {
    List { // 必要に応じてPreviewするViewの範囲を広げられる
        CollageView(layout. twoByTwoGrid)
    }
    .environment(CollageLayoutStore.sample) // データの注入
}

// UIKit & AppKit(UIViewController、UIView、NSViewを返却する)
#Preview {
    var controller = SavedCollagesController()
    controller.dataSource = CollagesDataStore.sample
    controller.layoutMode = .grid
    return controller
}

#Preview("Filter View") {
    var view = CollageFilterDisplayView()
    view.filter = .bloom(amount: 15.0)
    view.imageData = ...
    return view
}

// Widget
#Preview(as: .systemSmall) {
    FrameWidget()
} timelineProvider: {
    RandomCollageProvider()
}

// Widget(タイムラインの表示を固定化する)
#Preview(as: .systemSmall) {
    FrameWidget()
} timeline: {
    let first = CollageLayout<Void>
        .preset_2×3_left3.map { _, _ in Color.gray }
        .fillSlice(at: 0, with: [.green, .orange, .cyan])
    let second = first.fillSlice(at: 1, with: [.blue])

    ImageGridEntry(layout: first)
    ImageGridEntry(layout: second)
}

// Widget(Live Activities)
#Preview(as: .dynamicIsland(.compact), PizzaDeliveryAttributes()) {
    FoodOrderWidget()
} contentStates: {
    PizzaState.preparing
    PizzaState.baking
    PizzaState.outForDelivery
}
```

## Previews in your project

* **Previewのライブラリ**
  * Previewに必要な3つの要素
    * ソースファイル
    * ソースファイルを含むターゲット
    * スキーム

``` swift
// データ・アセットの設定
#Preview("All Filters", .landscapeLeft) {
    let viewController = FilterRenderingViewController()
    // Preview ContentのPreview Assetsから取得している
    // Preview用のデータとしてリリースアプリに含めたくない場合はDevelopment Assetsの設定をする
    // 「Build Settings」 → 「Development Assets」 → Preview Contentのパスをドラッグして渡す
    if let image = UIImage(named: "sample-001")?.cgImage {
        viewController.imageData = image
    }
    viewController.filter = Filter(
        bloomAmount: 1.0,
        vignetteAmount: 1.0,
        saturationAmount: 0.5
    )
    return viewController
}
```

* **実機に接続することでPreviewのターゲットを実機にすることもできる**