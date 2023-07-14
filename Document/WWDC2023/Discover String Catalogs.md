# Discover String Catalogs

* **アプリに表示される文字列の多言語管理**

``` swift
// 一意な識別子であるキーの指定(必須)
String(localized: "Welcome to WWDC!")

// デフォルト値の指定(オプション)
String(
    localized: "WWDC_NOTIFICATION_TITLE",
    defaultValue: "Webcome to WWDC!",
)

// どのように使用されているかのコメントの指定(推奨)
String(
    localized: "Welcome to WWDC!",
    comment: "Notification banner title"
)

// どのグループに属しているかのテーブルの指定(オプション)
String(
    localized: "Welcome to WWDC!",
    table: "WWDCNotifications",
    comment: "Notification banner title"
)

// .stringsファイルの場合
//
// en.lproj
//   - Localizable.strings
//   - Localizable.stringsdict
//
// de.lproj
//   - Localizable.strings
//   - Localizable.stringsdict
//
// String Catalogの場合
//   - Localizable.xcstrings
```

## Extract

* **コンパイラからのローカライズ可能な文字列抽出**
  * 「Use Compiler to Extract Swift Strings」を有効にする

``` swift
// SwiftUIでのLocalize
struct ContentView: View {
    var body: some View {
        VStack {
            // 文字列は自動的に抽出され、ローカライズされる
            // init(_ titleKey: LocalizedStringKey, systeImage name: String)
            Label("Thanks for shopping with us!", systemImage: "bag")
                .font(.title)

            // コメントも指定可能
            Label {
                Text(
                    "Thanks for shopping with us!",
                    comment: "Label above checkout button"
                )
            } icon: {
                Image(systemName: "bag")
            }

            HStack {
                Button("Clear Cart") {}
                Button("Checkout") {}
            }
        }
    }
}

// 独自のカスタムViewの作成
struct CardView: View {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)

            VStack {
                Text(title)
                Text(subtitle)
            }
            .padding()
        }
    }
}

CardView(
    title: "Recent Purchases",
    subtitle: "Items you've ordered in the past week."
)

CardView(
    title: LocalizedStringResource("Recent Purchases", comment: "Card Title"),
    ...
)
```

``` swift
// 一般的なローカライズ
import Foundation

func stringsToPresent() -> (String, AttributedString) {
    return (
        String(localized: "Title"),
        AttributedString(localized: "**Attributed** _Subtitle_")
    )
}

func stringsToPresent() -> (String, AttributedString) {
    // LocalizedStringResourceも使用可能
    let deferredString = LocalizedStringResource("Title")

    return (
        String(localized: deferredString),
        AttributedString(localized: "**Attributed** _Subtitle_")
    )
}
```

## Edit

* **ローカライズ状態や翻訳進捗状態の表示**
  * ローカライズの4つの状態
    * STALE:「Not found in code」
    * New:「Untranslated」
    * NEEDS REVIEW:「May require change」
    * CHEEK MARK(GREEN): 「Translated」

``` swift
// 複数形表現に対する簡易化
// You have %11d birds in %11d backyeards You have @birds in @yards
// @birds
//  one     %11d bird
//  other   %11d birds
//
// @yards
//  one     %11d backyard
//  other   %11d backyards
```

## Export

* **Xcode外へのエクスポート**

``` swift
// 「Product → Export Localizations → Target」
// 「Localization Prefers String Catalogs」 → Yes
//
// XLIFF(ローカライズ可能な文字列とその翻訳を含むファイル)
<trans-unit id="Brid Food Shop">
    <source>Bird Food Shop</source>
</trans-unit>

// 特定の言語の特定のデバイス環境では文字列を変化させたい
<trans-unit id="Brid Food Shop|==|device.applewatch">
    <source>Bird Food Shop</source>
    <target>Loja de Comida</target>
</trans-unit>

<trans-unit id="Brid Food Shop|==|device.other">
    <source>Bird Food Shop</source>
    <target>Loja de Comida de Passarinho</target>
</trans-unit>
```

## Migrate

* **既存のローカライズファイルのマイグレーション**
  * ローカライズファイル選択「Migrate to String Catalog」