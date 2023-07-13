# What’s new in Xcode 15

## Editing

* **コード補完**
  * ファイル名から構造体などの命名が補完される
  * キーボードの右矢印「→」で欲しい引数だけ設定できる
  * Suggestionで出てくる順番が状況に合わせて最適化される

* **Asset Catalogの型安全性**

``` swift
// Asset Catalog(Image)
// 画像取得を型推論から取得できる
// couldsという名前でAsset Catalogに画像保存
Image(.clouds)

// Asset Catalog(Localization)
// Edit > Convert
```

* **Documentの強化**
  * 「Editor > Assistant > Documentation Preview」からリアルタイムでドキュメントを確認できる

``` swift
// ドキュメントに画像挿入(アセットカタログ内の画像)
/// ![画像説明文](画像名)
```

* **Macroの作成**
  * Command + Shift + A

## Navigating

* **ブックマーク**
  * ファイルに対してブックマークを設定しナビゲータからいつでもアクセスできるようになる
    * ブックマークした行に対する説明文も追加できる
  * ブックマークしたファイルに対してグルーピングもできる
  * チェックマークを付けてTODOリスト的な使い方もできる

## Sharing

* **変更履歴の可視化**
  * 変更したコードを1つのファイルで全て確認できる
  * ステージ変更、コミット、プッシュまで全てできる

## Testing

* **テスト実行結果の詳細化**
  * 成功・失敗のテストを分かりやすく表示される
  * 実行したテストの概要の詳細が表示できる

## Debugging

* **OSLogでのログ表示**
  * ログレベルに応じたフィルタリング
  * ログから作成した行へのジャンプ定義ができる

## Distributing

* **Xcode Cloudでのアプリ配布**
  * TestFlightへの自動配布
