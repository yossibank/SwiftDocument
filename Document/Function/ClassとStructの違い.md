# ClassとStructの違い

## ドキュメント

https://docs.swift.org/swift-book/documentation/the-swift-programming-language/classesandstructures/
https://developer.apple.com/documentation/swift/choosing-between-structures-and-classes

### 自己理解

* クラスと構造体はどちらもデータ構造をカプセル化する機能の1つ

* クラスと構造体の共通部分
  1. 値を格納するためのプロパティを定義できる[[Properties](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties)]
  2. 機能を提供するためのメソッドを定義できる[[Methods](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/methods)]
  3. サブスクリプト構文を使用して値にアクセスするためのサブスクリプトを定義できる[[Subscripts](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/subscripts)]
  4. 初期状態を設定するためのイニシャライザを定義できる[[Initialization](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/initialization)]
  5. 既存実装を超えてextensionで機能を拡張できることができる[[Extensions](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/extensions)]
  6. 標準機能を提供するためのプロトコルを準拠することができる[[Protocols](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols)]

* クラスにしかない機能
  1. 継承により、あるクラスが別のクラスの特徴を受け継ぐことができる[[Inheritance](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/inheritance)]
  2. 型キャストにより、実行時にクラスのインスタンスの型をチェックし、解釈することができる[[Type Casting](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/typecasting)]
  3. デイニシャライザにより、クラスのインスタンスが割り当てたリソースを解放することができる[[Deinitialization](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/deinitialization)]
  4. 参照カウント(ARC)により、クラスのインスタンスへの複数の参照が可能になる[[Automatic Reference Counting](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting)]

※ クラスは構造体を比較して複雑になるため、基本的には構造体を使用することを推奨している。適切な場合は必要に応じてクラスを使用する。

* 決定的な違い(参照型のクラス vs 値型の構造体)
  * 参照型のクラス: クラスのインスタンスが変数や定数に割り当てられる時、実際にはそのインスタンスへの参照が割り当てられる。つまり、同じインスタンスを指す複数の参照が存在する
  * 値型の構造体: 構造体のインスタンスが変数や定数に割り当てられる時、そのインスタンスのコピーが作成される。つまり、それぞれのインスタンスが独立しており、他のインスタンスとは関連しない

#### 値型

* 定義と特徴
  * 値型はデータの実際の値を保持する
  * 構造体(struct)、列挙型(enum)、基本データ型(Int, String, Boolなど)が該当する

* 動作
  * 値型のインスタンスを新しい変数や定数に割り当てると、その値のコピーが作成される
  * つまり、元のインスタンスと新しいインスタンスは完全に独立しており、互いに影響しない

* 利用シナリオ
  * データのカプセル化が重要で、共有されるべきでない場合に最適
  * 単純なデータ構造や短期間のデータ格納に最適

#### 参照型

* 定義と特徴
  * 参照型はデータの参照、つまりデータへのポインタを保持する
  * クラス(class)が該当する

* 動作
  * 参照型のインスタンスを新しい変数や定数に割り当てると、元のインスタンスへの参照がコピーされる
  * つまり、複数の変数や定数が同じインスタンスを共有し、一方での変更が他方にも影響する

* 利用シナリオ
  * 複雑なデータ構造や長期間のデータ格納に最適
  * データの共有や継承が必要な場合に最適