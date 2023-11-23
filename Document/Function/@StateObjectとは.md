# @StateObjectとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/stateobject

> A property wrapper type that instantiates an observable object.

* 観測可能なオブジェクトをインスタンス化するプロパティーラッパー

### 自己理解

`ObservableObject`を準拠したクラス内の`@Published`の値を監視し、値が変化した際にViewが再描画される。

@StateObjectのライフサイクルはViewが表示されてから非表示になるまでになり、親Viewの更新などに関わらず状態を保持できる。

※ SwiftUIが提供するストレージ管理と衝突する可能性があるため、private修飾子を付けることが推奨されている。

``` swift
final class DataSource: ObservableObject {
    @Published var count = 0
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
                    // @StateObject → 親Viewの更新に関わらず状態は保持される
                    flag.toggle()
                }
            }

            StateObjectView()
        }
    }
}
```