# @EnvironmentObjectとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/environmentobject

> A property wrapper type for an observable object that a parent or ancestor view supplies.

* 親または祖先のViewが提供する観測可能なオブジェクトのプロパティーラッパー

### 自己理解

`ObservableObject`を準拠したクラス内の`@Published`の値を監視し、値が変化した際にViewが再描画される。

@EnvironmentObjectを使用する場合は、対応するモデルオブジェクトを祖先となるViewに必ず設定する。(`.environmentObject(_:)`)

一度インスタンスを生成後は、毎回インスタンスを渡す必要はなく設定したView階層全体の画面からアクセスすることができる。

``` swift
final class DataSource: ObservableObject {
    @Published var count = 0
}

struct EnvironmentObjectView: View {
    @EnvironmentObject var dataSource: DataSource

    var body: some View {
        VStack(spacing: 4) {
            Text("子View")
            Text("EnvironmentObject count: \(dataSource.count)")
            Button("increment") {
                dataSource.count += 1
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var dataSource: DataSource

    var body: some View {
        VStack(spacing: 32) {
            EnvironmentObjectView()

            Button("TAP [+2]") {
                // dataSourceのcountが更新される
                // EnvironmentObjectView()にインスタンスを渡さなくてもViewが更新される
                dataSource.count += 2
            }
        }
    }
}

#Preview {
    ContentView()
        // .environmentObject(_:)を必ず設定する
        .environmentObject(DataSource())
}
```