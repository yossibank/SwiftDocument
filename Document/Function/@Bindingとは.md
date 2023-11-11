# @Bindingとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/binding

> A property wrapper type that can read and write a value owned by a source of truth.

* `single source of truth`が所有する値を値を読み書きできるプロパティラッパー

### 自己理解

データと対象を結びつけて、データまたは対象の変更を暗示的にもう片方に反映させるデータバインディングの仕組みとSwiftUIを結びつけた機能の1つ。

@Stateでは自身のViewに定義することで値を`single source of truth`として管理していたが、@Bindingでは親子関係にあるView内の@Stateのデータを参照し、値を読み書きすることができる。

@Stateをつけたプロパティの値が更新されるとViewが再描画されるため、その@Stateのデータを参照している@Bindingも自動的に再描画が行われる。

``` swift
struct StateView: View {
    // @Stateの定義
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Button(isPlaying: "Pause" : "Play") {
                // @Stateで定義した値の更新 → プロパティの値が変化すると自動的にViewが再描画される
                isPlaying.toggle()
            }

            // @Stateのデータを@Bindingに紐づける
            BindingView(isPlaying: $isPlaying)
        }
    }
}

struct BindingView: View {
    // @Bindingの定義
    // 親の@Stateのデータを参照する
    @Binding var isPlaying: Bool

    var body: some View {
        Toggle(
            // @BindingのisPlayingを参照する → single source of truthである親の@Stateを参照し、読み書きを行う
            isOn: $isPlaying,
            label: {
                Text(isPlaying ? "ON" : "OFF")
            }
        )
        .frame(width: 100)
    }
}
```