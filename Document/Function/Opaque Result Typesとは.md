#  Opaque Result Types

## ドキュメント

https://github.com/apple/swift-evolution/blob/main/proposals/0244-opaque-result-types.md

### 自己理解

「内部実装を隠しながらパフォーマンスにも影響しない戻り値の表現方法(**some**)」

``` swift
protocol Animal {
    func foo()
}

struct Cat: Animal {
    func foo() {
        print("cat")
    }
}

// Opaque Result Types
func makeAnimal() -> some Animal {
    return Cat()
}

let animal = makeAnimal()
animal.foo() // "cat"

// 内部実装を過剰に公開する
func makeAnimal() -> Cat {
    return Cat()
}

// プロトコル型にはパフォーマンス上のロスが発生する
func makeAnimal() -> Animal {
    return Cat()
}
```

* 内部実装を過剰に公開するとは

1. 実装の詳細を不必要に露出させている例

``` swift
struct Pair<Value>: Sequence {
    private var array: [Value]

    init(_ value1: Value, _ value2: Value) {
        array = [value1, value2]
    }

    var values: (Value, Value) {
        (array[0], array[1])
    }

    // makeIterator()はSequenceで準拠するプロトコル
    // public protocol Sequence {
    //     public func makeIterator() -> Self.Iterator
    // }
    // 実装の詳細を不必要に露出させてしまっている
    func makeIterator() -> IndexingIterator<[Value]> {
        // array.makeIterator()の戻り値がIndexingIterator<[Value]>
        array.makeIterator()
    }
}

let pair: Pair<Int> = Pair(2, 3)

for value in pair {
    print(value)
}
// 2
// 3
```

2. パフォーマンス、メモリ効率を考えて、1.の実装をタプルにした時

``` swift
struct Pair<Value>: Sequence {
    private(set) var values: (Value, Value)

    init(_ value1: Value, _ value2: Value) {
        values = (value1, value2)
    }

    // 返す型を自力で実装する必要がある
    func makeIterator() -> /* ??? */ {
        /* ... */
    }

    // カプセル化された内部実装を変更したかっただけなのに、公開されたAPIの方が変更されてしまっている
    // IndexingIterator<[Value]>からPairIterator<Value>に変わっている
    func makeIterator() -> PairIterator<Value> {
         .first(values.0, values.1)
    }
}

// Pairの実装の変更に伴い、将来的には不要になるかもしれない
// つまり、PairIteratorという将来的に不要になるかもしれない型を公開している
enum PairIterator<Value>: IteratorProtocol {
    case first(Value, Value)
    case last(Value)
    case none

    mutating func next() -> Value? {
        switch self {
        case let .first(first, last):
            self = .last(last)
            return first
        case let .last(last):
            self = .none
            return last
        case .none:
            return nil
        }
    }
}
```

* プロトコル型にはパフォーマンス上のロスが発生する

1. プロトコルの型は`Existential Type`であるため、実行時によるオーバーヘッドが発生する

``` swift
protocol Animal {
    func foo()
}

struct Cat: Animal {
    var a: UInt8 = 42

    func foo() {
        print("cat")
    }
}

struct Dog: Animal {
    var b: Int64 = -1

    func foo() {
        print("dog")
    }
}

let cat: Cat = Cat()
MemoryLayout.size(ofValue: cat) // 1バイト

let dog = Dog()
MemoryLayout.size(ofValue: dog) // 8バイト

var animal: Animal = Cat()
// Animalに適合したどのような型のインスタンスでも格納できるように、Existential Containerという入れ物に包まれている
// そのため大きいサイズ領域が必要となる
MemoryLayout.size(ofValue: animal) // 40バイト

// Existential Typeを使うと、引数に渡すときにExistential Containerに包むオーバーヘッドが発生し、メソッドを呼ぶときはExistential Containerを開いて間接的にメソッドを呼び出すオーバーヘッドが発生する
func useAnimal(_ animal: Animal) {
    animal.foo() // Existential Containerを開くオーバーヘッド発生
}

let cat = Cat()
useAnimal(cat) // Existential Containerに包むオーバーヘッド発生
```

2. ジェネリクスでの`Existential Type`のオーバーヘッドの解決

``` swift
// Existential Type
func useAnimal(_ animal: Animal) {
    animal.foo()
}

// 具体型
// コンパイル時にanimalの型が確定するので、animal.foo()で呼ばれるメソッドの実態をコンパイル時に確定させることができる
func useAnimal(_ animal: Cat) { animal.foo() }
func useAnimal(_ animal: Dog) { animal.foo() }

// ジェネリクス
// 具体型と同等のパフォーマンスを実現することができる
// 実行時のオーバーヘッドが発生しない
func useAnimal<A: Animal>(_ animal: A) {
    animal.foo()
}
```

* リバースジェネリクス
  * ジェネリクスで`Exiestential Type`の問題を解決できた
    * ただ、これは引数の場合のみで戻り値として`Existential type`を返すことはできない
  * 戻り値でも`Existential Type`の問題を解決するのがリバースジェネリクス
    * 具体的な型を隠蔽したまま実行時のオーバーヘッドを支払わずに済む

``` swift
// Existential Type
func makeAnimal() -> Animal {
    return Cat()
}

// ジェネリクス🙅‍♂️
// ジェネリクスの型パラメータを決めるのはAPIの利用者
// 以下のコードはmakeAnimalの実装自体がAをCatと仮定している
// 利用者ではなく実装者が型を決定しようとしているため型エラーでコンパイルに失敗する
func makeAnimal<A: Animal>() -> A {
    return Cat() // コンパイルエラー
}
```

``` swift
// ジェネリクス
// useAnimalの利用者がAの具体的な型を定め、useAnimalの実装者は抽象的なAに対してコードを書く
func useAnimal<A: Animal>(_ animal: A) {
    animal.foo()
}

// リバースジェネリクス
// makeAnimalの実装者がAの具体的な型を定め、makeAnimalの利用者は抽象的なAに対してコードを書く
func makeAnimal() -> <A: Animal> A {
    return Cat()
}

// 利用者(let animal)には実際に返されるCatインスタンスは見えない
// あくまでAnimalに適合した何らかの型のインスタンスが返されたものとして扱う
// 実際にはCatインスタンスなので、コンパイラ内で最適化され、makeAnimalがCatを返すのと同じパフォーマンスを発揮できる
let animal = makeAnimal()
animal.foo()

// 明示的な型を表すとこうなる
let animal: makeAnimal.A = makeAnimal()
animal.foo()

// makeAnimal.Aは実際にはCatだが、利用者には隠蔽されているためエラーとなる
let animal = makeAnimal()
let cat: Cat = animal // コンパイルエラー
```

* シンタックスシュガーとしてOpaque type
  * Opaque Result Typeは「リバースジェネリクス」のシンタックスシュガーとなる

``` swift
// リバースジェネリクス
func makeAnimal() -> <A: Animal> A {
    return Cat()
}

// Opaque Result Type
func makeAnimal() -> some Animal {
    return Cat()
}

// ジェネリクス
func useAnimal<A: Animal>(_ animal: A) {
    animal.foo()
}

// Opaque Argument Type
func useAnimal(_ animal: some Animal) {
    animal.foo()
}
```

* Opaque Result Typeの挙動

``` swift
func makeAnimal() -> some Animal {
    return Cat()
}

var animal1 = makeAnimal()
let animal2 = makeAnimal()
animal1 = animal2 // 🙆‍♂️

func makeAnimal1() -> some Animal {
    return Cat()
}

func makeAnimal2() -> some Animal {
    return Cat()
}

var animal1 = makeAnimal1()
let animal2 = makeAnimal2()
animal1 = animal2 // 🙅‍♂️

func makeAnimals() -> (some Animal, some Animal) {
    return (Cat(), Cat())
}

var (animal1, animal2) = makeAnimals()
animal1 = animal2 // 🙅‍♂️
```