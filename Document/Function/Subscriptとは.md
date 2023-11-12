# Subscriptとは

## ドキュメント

https://docs.swift.org/swift-book/documentation/the-swift-programming-language/subscripts/

> Classes, structures, and enumerations can define subscripts, which are shortcuts for accessing the member elements of a collection, list, or sequence

* クラス、構造体、列挙型などのコレクション、リスト、シーケンスに短い構文でアクセスするための方法を提供する

### 自己理解

`subscript`はクラス、構造体、列挙型などのコレクション、リスト、シーケンスに短い構文でアクセスするための方法を提供し、これによってインデックスを使って要素にアクセスする際に、通常のメソッド呼び出しよりも簡潔で直感的な構文を使用することができる

* 特徴
  1. 構文の簡素化: `subscript`を使うことで、コレクションやシーケンス内の特定の要素に対して、より読みやすく簡単なアクセス方法を提供する
  2. カスタムアクセス: 開発者は、自分のデータ構造に`subscript`を定義して、特定のロジックや計算を組み込んだカスタムアクセスを提供する
  3. 読み取りと書き込み: `subscript`は読み取り専用にも、読み書き可能にも設定できる。これは`get`および`set`ブロックを使って制御される

* 基本的な例
  * 配列や辞書のような標準コレクションには、`subscript`が内部的に使用されている

``` swift
let array = [1, 2, 3]
let firstElement = array[0] // subscriptを使用して最初の要素にアクセス

let dictionary = ["key1": "value1", "key2": "value2"]
let value = dictionary["key1"] // subscriptを使用してキーに対する値にアクセス
```

* カスタムsubscript
  * 独自の構造体やクラスに`subscript`を実装できる

``` swift
struct Matrix {
    private var data: [[Int]]

    subscript(row: Int, column: Int) -> Int {
        get {
            data[row][column]
        }
        set {
            data[row][column] = newValue
        }
    }
}

var matrix = Matrix(data: [[1, 2], [3, 4]])
let value1 = matrix[0, 1] // 2
matrix[0, 1] = 5
let value2 = matrix[0, 1] // 5
```