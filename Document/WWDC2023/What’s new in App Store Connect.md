# What’s new in App Store Connect

## Monetize your app

* **アプリ内課金**
  * 価格設定の柔軟化(価格の自動設定)

``` swift
// SwiftUI内でのStoreKit表示
import StoreKit
import SwiftUI

struct BackyardBirdsPassShop: View {
    @Environment(\.shopIDs.pass) var passGroupID

    var body: some View {
        SubscriptionStoreView(groupID: passGroupID)
    }
}

// 課金用画面カスタマイズ
SubcriptionSgtoreView(groupID: ...) {
    ...
}
.subscriptionStoreControlIcon { subscription, subscriptionInfo in
    Group {
        let status = PassStatus(levelOfService: subscriptionInfo.groupLabel)

        switch status {
        case .premium:
            Image(systemName: "bird")

        case .family:
            Image(systemName: "person.3.sequence")

        default:
            Image(systemName: "wallet.pass")
        }
    }
    .symbolVariant(.fill)
}
.foregroundStyle(.white)
.subscriptionStoreControlStyle(.buttons)
```

## Manage testers

* **TestFlight**
  * テスターに関する情報状態表示
    * 招待されたか
    * 承諾されたか
    * アプリをインストールしたか
    * アプリに対するセッション数
    * アプリのクラッシュ数
    * アプリへのフィードバック数
  * 社内メンバーのみへの配布(TestFlight internal Only)
    * 外部用配布ができない
    * AppStoreにレビュー対象として提出できない

* **ファミリー機能へのテスト**
  * App Store Connectでアカウントを作成しファミリー共有として作成できる


## Build your store presence

* **新しいデータ収集追加**
  * ユーザーの周囲のデータ(Environment Scanning)
  * 手の構造や動き(Hands)
  * 頭の動き(Heads)

* **予約販売**
  * 地域ごとにいつリリースできるかを設定できる

## Automate with APIs

* **App Store Connect APIの追加**
  * Game Centerへのサポート
  * 新たな生成可能なAPIキーの追加
    * marketing and custom service API keys
    * user-based key