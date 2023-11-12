# @Bindingとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/binding

> A property wrapper type that can read and write a value owned by a source of truth.

* `Single Source of Truth`が所有する値を値を読み書きできるプロパティラッパー

### 自己理解

データと対象を結びつけて、データまたは対象の変更を暗示的にもう片方に反映させるデータバインディングの仕組みとSwiftUIを結びつけた機能の1つ。

@Stateでは自身のViewに定義することで値を`Single Source of Truth`として管理していたが、@Bindingでは親子関係にあるView内の@Stateのデータを参照し、値を読み書きすることができる。

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

※ Single Source of Truth(SSOT)

全ての情報の正確な、信頼できる、単一の参照ソースを持つこと。

これにより、データの一貫性、整合性、および信頼性を確保することができる。

1. データの一貫性: 情報が単一のソースのため、データの一貫性が保つことができる。これは、異なるシステムや部門間での情報の整合性を保ち、矛盾を避けるのに役立つ
2. エラーの減少: 単一の情報源を持つことで、誤情報や矛盾が減少する。これにより、誤ったデータに基づく意思決定や問題の発生を減らすことができる
3. 効率の向上: データの重複を減らし、情報のアクセスと管理がより効率的になる。これにより、データ更新や検索のプロセスが簡素化される
4. 信頼性の向上: 利用者は、提供されるデータが最新かつ正確であることを信頼できる。これにより、より高品質の意思決定が可能になる