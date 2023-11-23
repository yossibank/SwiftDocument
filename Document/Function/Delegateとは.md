# Delegateとは

## ドキュメント

https://docs.swift.org/swift-book/documentation/the-swift-programming-language/protocols/#Delegation

> Delegation is a design pattern that enables a class or structure to hand off (or delegate) some of its responsibilities to an instance of another type.

* デリゲートは、あるクラスや構造体がその責任の一部を別の型のインスタンスに委ねる(または委任する)ことを可能にするデザインパターン

### 自己理解

「あるオブジェクトから別のオブジェクトに処理を任せる」

protocolを使用して実装するデザインパターンの一つ。1つのオブジェクト(delegate)が、別のオブジェクトのために特定のタスクや機能を実行する。

protocolに要件を定義し、delegateはそのprotocolを使用して、特定のタスクを別のオブジェクトに委任する方法を提供する。

* 登場人物
  * 任せる処理「protocol」
  * 処理を任せるオブジェクト(クラス、構造体、、、)
  * 処理を任されるオブジェクト(クラス、構造体、、、)

``` swift
// 任せる処理
protocol DataHandlerDelegate {
    func didReceiveData(_ data: String)
}

// 処理を任せるオブジェクト
final class DataHandler {
    weak var delegate: DataHandlerDelegate?

    func fetchData() {
        let data = "Sample Data"

        // デリゲートに処理を任せる
        delegate?.didReceiveData(data)
    }
}

// 処理を任されるオブジェクト
final class ReceivedHandler: DataHandlerDelegate {
    let dataHandler = DataHandler()

    init() {
        // デリゲートの処理を自身が受け持つようにする
        dataHandler.delegate = self
        dataHandler.fetchData()
    }

    // デリゲートの処理を行う
    func didReceiveData(_ data: String) {
        print("Received Data: \(data)")
    }
}
```