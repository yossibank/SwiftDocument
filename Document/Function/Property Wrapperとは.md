# Property Wrappersとは

## ドキュメント

https://docs.swift.org/swift-book/documentation/the-swift-programming-language/properties/#Property-Wrappers

> A property wrapper adds a layer of separation between code that manages how a property is stored and the code that defines a property.

* Property Wrapperはプロパティの保存方法を管理するコードと、プロパティを定義するコードの間に分離のレイヤーを追加する

### 自己理解

Property Wrapperはプロパティの値の保存方法や計算方法を定義し、同じような振る舞いを行うプロパティをProperty Wrapperにラップすることで同じような処理を書くことなく再利用できるようになる仕組み。

* 基本的なProperty Wrapperの定義

``` swift
// 1. @propertyWrapperのattribute定義
@propertyWrapper
// 2. enum, struct, classで定義
struct TwelveOrLess {
    private var number: Int = 0

    // 3. wrappedValueの定義
    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, 12) }
    }
}

// 使用例
struct SmallRectangle {
    @TwelveOrLess var height: Int
    @TwelveOrLess var width: Int
}

// 展開すると以下のようになる
struct SmallRectangle {
    private var _height = TwelveOrLess()
    private var _width = TwelveOrLess()

    var height: Int {
        get { _height.wrappedValue }
        set { _height.wrappedValue = newValue }
    }

    var width: Int {
        get { _width.wrappedValue }
        set { _width.wrappedValue = newValue }
    }
}

var rectangle = SmallRectangle()
print(rectangle.height) // 0

rectangle.height = 10
print(rectangle.height) // 10

rectangle.height = 20
print(rectangle.height) // 12
```

* 初期を持ったProperty Wrapper

``` swift
@propertyWrapper
struct TwelveOrLess {
    private var number: Int

    init(number: Int) {
        self.number = number
    }

    var wrappedValue: Int {
        get { number }
        set { number = min(newValue, 12) }
    }
}

struct SmallRectangle {
    @TwelveOrLess(number: 0) var height: Int
    @TwelveOrLess(number: 5) var width: Int
}

var rectangle = SmallRectangle()
print(rectangle.height) // 0
print(rectangle.width) // 5
```

* ProjectedValue(投影値)
  * wrappedValueに付随した特別な値を保持するプロパティ
  * アクセスには`$`記号をつける必要がある

``` swift
@propertyWrapper
struct TwelveOrLess {
    private var number: Int

    init(number: Int) {
        self.number = number
        self.projectedValue = false
    }

    private(set) var projectedValue: Bool

    var wrappedValue: Int {
        get { number }
        set {
            if newValue > 12 {
                number = 12
                projectedValue = true
            } else {
                number = newValue
                projectedValue = false
            }
        }
    }
}

struct SmallRectangle {
    @TwelveOrLess(number: 0) var height: Int
    @TwelveOrLess(number: 5) var width: Int
}

var rectangle = SmallRectangle()
print(rectangle.height) // 0
print(rectangle.$height) // false

rectangle.width = 20
print(rectangle.width) // 12
print(rectangle.$width) // true
```