# @Stateとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/state

> A property wrapper type that can read and write a value managed by SwiftUI.

* SwiftUIによって管理される値を読み書きできるプロパティラッパー

### 自己理解

データと対象を結びつけて、データまたは対象の変更を暗示的にもう片方に反映させるデータバインディングの仕組みとSwiftUIを結びつけた機能の1つ。

`@State`をつけたプロパティはViewに紐づけられ、SwiftUIフレームワークに監視されることで、プロパティの値とUIの状態が同期される。

※ @Stateでの値の変更は宣言したそのView上でのみでしかすることができなたいめ、private修飾子を付けることが推奨されている。

``` swift
struct StateView: View {
    // @Stateの定義
    @State private var isPlaying: Bool = false

    var body: some View {
        Button(isPlaying: "Pause" : "Play") {
            // @Stateで定義した値の更新 → プロパティの値が変化すると自動的にViewが再描画される
            isPlaying.toggle()
        }
    }
}
```