# @Environmentとは

## ドキュメント

https://developer.apple.com/documentation/swiftui/environment

> A property wrapper that reads a value from a view’s environment.

* Viewの環境情報から値を読み取るプロパティーラッパー

### 自己理解

@Environmentでキーパスを指定することでタイムゾーンやフォント、カラーモードなどの環境値を読み取ることができる。

``` swift
struct EnvironmentView: View {
    @State private var isShowModal = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 16) {
            Text(colorScheme == .light ? "light" : "dark")

            Button("Modal") {
                isShowModal.toggle()
            }
        }
        .sheet(isPresented: $isShowModal) {
            ModalView()
        }
    }
}

struct ModalView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Modal View")

            Button("Close") {
                dismiss()
            }
        }
    }
}
```