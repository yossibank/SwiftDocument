# @ObservedObjectとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/observedobject

> A property wrapper type that subscribes to an observable object and invalidates a view whenever the observable object changes.

* 観測可能なオブジェクトを購読するプロパティラッパー、観測可能なオブジェクトが変更されるたびにViewを再描画する

### 自己理解

`ObservableObject`を準拠したクラス内の`@Published`の値を監視し、値が変化した際にViewが再描画される。

@ObservedObjectのライフサイクルは**親Viewのbodyが更新される度**になり、更新される度にインスタンスが初期化されるため、状態の持続性を保証できない。

そのため、親Viewから渡されるデータを参照するように定義を行う。(デフォルト値や初期値を設定しない)

``` swift
struct ObservedObjectView: View {
    // デフォルト値や初期値を持つべきでない
    @ObservedObject private var dataSource = DataSource()

    var body: some View {
        VStack(spacing: 4) {
            Text("子View")
            Text("ObservedObject count: \(dataSource.count)")
            Button("increment") {
                dataSource.count += 1
            }
        }
    }
}

struct StateObjectView: View {
    @StateObject private var dataSource = DataSource()

    var body: some View {
        VStack(spacing: 4) {
            Text("子View")
            Text("StateObject count: \(dataSource.count)")
            Button("increment") {
                dataSource.count += 1
            }
        }
    }
}

struct ContentView: View {
    @State private var flag = false

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                Text("親View")

                Image(systemName: flag ? "flame" : "flame.fill")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(flag ? .black : .red)

                Button("Change") {
                    // flagで親Viewが更新される
                    // @ObservedObject → インスタンスが初期化され、状態がリセットされる
                    flag.toggle()
                }
            }

            ObservedObjectView()
            StateObjectView()
        }
    }
}
```