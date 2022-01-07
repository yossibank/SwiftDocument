# 概要
初めてアプリ開発に関わっていく中で「設計」や「アーキテクチャ」という単語を耳にしたことはないでしょうか。  
設計とは何となくイメージがつくかと思いますが、アーキテクチャとはそもそも何なのかと疑問に感じる方もいるかと思います。

アプリを開発するにあたって、初めに検討すべきことが「設計」や「アーキテクチャ」であり、  
どの設計・アーキテクチャを採用するかはどのようなアプリを開発したいかによります。

例えば、

1. たくさんの画面を作る必要があるので、その画面遷移とそれらの状態の整合性を保ちたい
2. 通信などせず画面も少ないが、動的なオブジェクトを生成するので、それらの状況を細かく計算できるようにしたい
3. 大規模なプロジェクトのため、もしメンバーが入れ替わってもコードの品質を保てるようにしたい

などなど、作りたいアプリによって適している設計・アーキテクチャは異なります。

ただ、どの設計・アーキテクチャが正解というものではありません。  
ここで知るべきことは、どのような設計手法・アーキテクチャがあるのかを把握し特徴を理解することで、アプリ開発全体の理解を深めることにあります。

また、設計・アーキテクチャについては個人の考え方によって解釈に違いが発生する部分もあります。  
こちらは書籍の「iOSアプリパターン設計入門」の内容を噛み砕いて説明させて頂きますが、これが絶対正解というわけではないので大枠の考え方として見ていただければと思います。

## 設計について
設計とはそもそも何か、なぜ設計するのかといった設計の意義について考えます。

## 1. 設計とは
近年のアプリは以前と比べて複雑になってきています。主に5つのことが挙げられます。

1. アプリでできることの多様化  
    - デバイス端末のレイアウトの多様化(iPhone13, iPhone SE, iPad...)
    - アプリの起動経路の多様化(通知からアプリ起動、特定のリンクからアプリ起動、バックグラウンド時の処理...)

2. 頻繁・継続的なリリース  
    - 細かいスパンでリリースを繰り返すことで、他のアプリに先駆けて機能を投入できる
    - 小幅な改修を繰り返すことで不具合のリスクの最小化

3. アプリの大規模化  
    - 画面数・ユーザー数の増加
    - 大規模アプリに対応するためのコードの再利用化・共通化の必要性(同じような処理は共通化することでコードの煩雑化を防ぐ)

4. プロジェクトの長期化  
    - 利用するライブラリ・フレームワークの選定(サポートされ続けているものを使用し、使用は最小限に抑える)
    - 言語の移行(ObjectiveC → Swift → SwiftUI....)

5. チーム開発の分業  
    - 大人数のチームで開発することによる、他者とのコードの統一性(ルールを設ける)
    - 影響範囲の切り分け(各メンバーが自分の領域に集中でき、必要に応じて他所を参照したときにも意図が伝わりやすいコードが必要)

### 関心の分離
「関心の分離」という概念があります。  
これは、複雑な問題に対してはより単純な問題の群として切り分けるべきであり、そのためにシステムが部品(モジュール)の集合として構成される必要があるという考え方です。

そもそも全てのコンピュータシステムはなんらかの問題への関心を持ち、その問題に対する解決策を提供します。  
ただ問題は複雑で、解決しようにもさまざまな問題への関心事が絡み合うため、実際に解決策を提供していくのは難しくなります。  
例えば、<図1>のようなECサイトの商品について考えてみます。このような構成の際に商品クラスに仕様変更があると、変更影響による動作不具合の確認などを商品クラスに関連のあるクラス全てをチェックしなければなりません。  
出品に関するロジックを変更したとしても、予約・注文・発送のロジックについても影響がないか全て確認する必要があるということです。  
なぜこのような状態になるかというと、商品の周りには予約・注文・発送などの様々な関心事があるからです。商品クラスがそれらの関心事と結びつき、複数のロジックを持ってしまっています。
そこで重要なのが関心の分離であり、こうした問題に対しては複数の部品(モジュール)を作成し、それぞれの部品は狭い関心を持ち、一つの問題にのみ対処させるようにします<図2を参照>。  
このモジュールを組み合わせる事で、より単純に大きな問題を解決できるようにしていきます。これがソフトウェア設計の根幹にある考え方でもあります。

<図1>  
<img src=https://user-images.githubusercontent.com/55877379/148474421-5cdcc5a6-db0b-4079-8fbc-841ec5c7fbd2.png  width=70%>

<図2>  
<img src=https://user-images.githubusercontent.com/55877379/148474428-3e2d9de2-e292-45a9-8137-893c740546d7.png  width=70%>

### 設計パターン
複雑な問題は、より単純な問題の群として切りわけるべき(関心の分離)と先ほど述べました。  
実はこの問題を解決するために、過去の人達が何度も設計を繰り返す中で、さまざまな問題に対処するコードが共通して同じパターンに行き着くことが発見されています。  
これが「設計パターン」です。再現性のある問題に対する共通の解決策のことを指します。  
ここで具体的なパターンについては説明を省きますが、有名なパターンにGofのデザインパターンと呼ばれる23種類のパターンがあります。  
「Mediator」「Observer」「Singleton」等があり、これらの概念を知っておけば設計の理解も深まりますので余力があれば確認しておきましょう。

設計パターンを知っておくことのメリットは以下のようなことが挙げられます。

1. 問題を定型化して捉えられる
    - わざわざ自分で問題の解決策を見つけ出さなくても、先人たちが生み出した既知のパターンを通して問題を捉えなおせば容易に解決できることがある

2. 解決策を客観的に比較できる
    - ある問題をパターンを通して捉えるとき、複数のパターンが適用できるケースもあります。そうしたときに、それぞれのパターンの強み・弱みを把握しているので客観的に判断でき、細かなトレードオフを把握した上でパターンを使い分けることで手戻りを減らせることに繋がります

3. メンバーの共通言語となる
    - 設計が複雑になるにつれ、各部品の関連もすぐに理解するのは難しくなります。しかし、パターンを適用することで共通の認識として構造を捉えることができ、開発の生産性向上に大きく貢献します

## 2.アーキテクチャとは
アプリ開発においても関心の分離は必要になってきます。「アプリを動かす」という複雑な問題領域は、大まかに複数の層(レイヤー)へと切り分けられます。  
そこで活用されるのがアーキテクチャです。ここではアーキテクチャとは「アプリの大まかなレイヤー分割の捉え方」と認識しておいてください(イメージは図3のようなものです)。  
これから説明するアーキテクチャの中でどれが一番優れているであったり、どのようにレイヤーを切り分けるのが一番正しいかの正解はありません。  
これらはアプリで対処しようとする問題によって多種多様なためです。しかしながら、アーキテクチャも設計と同じようにパターンが存在します。  
各パターンの概要を知り、強み・弱みを把握する事で、自らが関わるアプリに適したアーキテクチャを理解する第一歩となります。  
一度に全てを詳細に知ることは難しいです。まずは全体の概要を知ることから始め、開発とともに一緒に学んでいくのが良いかと思います。

<図3>  
<img src=https://user-images.githubusercontent.com/55877379/148474485-78798d5f-dbbf-41ce-b0ac-18502b0b78f4.png  width=70%>

### 2種類のアーキテクチャ
一般にiOSアプリのアーキテクチャと呼ばれているものには、切り口の違う2種類のものが混在しています。  
それを、ここでは「GUIアーキテクチャ」と「システムアーキテクチャ」と呼びます。  
MVC、MVP、MVVMといった耳馴染みのあるアーキテクチャには「M」や「V」の文字が含まれています。  
これらが「Model」や「View」を表すことは知っている方も多いと思います。しかし改めて、ModelやViewとは何なのかと問われるとどう答えますでしょうか。

これらのアーキテクチャの根底には**Presentation Domain Separation(PDS)**と呼ばれるアイデアがあります(プレゼンテーション == View、ドメイン == Modelと捉えて問題ありません)。  
ここでいうプレゼンテーション(View)と呼ばれているのは**UIに関係するロジック**であり、ドメイン(Model)というのはアプリケーションのユーザーが思い描く、**システム本来の関心領域**です。  
つまり、PDSとは「システム本来の関心領域(ドメイン)を、UI(プレゼンテーション)から引き離す」というアイデアを指し、これを実践する際の具体的なレイヤー構造をパターンとして示すのが*GUIアーキテクチャ*です。  
ただし、PDSはあくまでViewからの視点でしかないことに注意してください。というのも、システム全体を俯瞰的に見ると「UIにもシステム本来の関心にも該当しない処理」というのも存在するため、切り分けできていない部分もあります。  
GUIアーキテクチャのModelの正体は、実際は「UIに関係しない処理全て」というざっくりとした存在になっており、UIが関わる部分以外にはGUIアーキテクチャでは何も示されていません。  
では、GUIアーキテクチャよりも広く、UIという単位に捉われず、システム全体の構造を示すものは何かというと**システムアーキテクチャ**と呼ばれているものになります。

GUIアーキテクチャ | システムアーキテクチャ
:--: | :--:
<img src=https://user-images.githubusercontent.com/55877379/148474478-74a1222f-2af5-4381-a8bf-87063524ae1e.png  width=70%> | <img src=https://user-images.githubusercontent.com/55877379/148474488-9adc14a3-8fc5-499c-992f-06804159da80.png  width=70%>

### GUIアーキテクチャ
iOSアプリに限らず、UIのあるシステムは基本的に次のような処理を行います。

1. UIが入力イベントを受け取る
2. 入力イベントをシステムが解釈し、処理
3. 処理の結果をUIに描写

UI(プレゼンテーション)とシステム(ドメイン)には明確な関心の違いがあります。  
プレゼンテーションは、どのようにコンポーネントをレイアウトし情報を装飾するかに興味があります。  
ドメインは、情報をどのようにモデリングし処理するかに興味があります。  
関心が違うならばレイヤーとして切り分けるべきだ、というのがGUIアーキテクチャのコンセプトです。
プレゼンテーションとドメインのレイヤーを分離することはいくつかのメリットがあります。

1. 理解がしやすい
    - コードを追いやすい、Fat-View-Controllerを避けられる

2. 重複コードの排除
    - ロジックの共通化や同じ画面に異なる情報を表示できる

3. 分業のしやすさ
    - レイアウトを扱うエンジニア、サーバから取得したデータの整形をするエンジニアのように作業を分担できる

4. テスタビリティの向上
    - プレゼンテーション層のテストがしやすくなる

このような明確なメリットがあるため、PDSはUIをもつあらゆるシステムを構築する際の基礎概念として浸透していきました。  
このPDSの体現者であるGUIアーキテクチャの始祖が**Model-View-Controller(MVC)**になります。

## 3. MVC
MVCアーキテクチャはプログラムを「入力」「出力」「データの処理」の3つの要素に分けたとき、それぞれを**Controller**、**View**、**Model**と定義します。  
アプリケーションの処理から入力、出力とを分離・独立させたことで、プログラムの本質である「データ処理」そのものに専念できるようにしたのがMVCの特徴です。

### MVCの構造

* Model
  - 各種ビジネスロジックのかたまり

* View
  - 画面の描写を担当

* Controller
  - 何かしらの入力に対する適切な処理を行うだけでなく、ModelオブジェクトとViewオブジェクトを保持。Modelオブジェクトに処理を依頼し、受け取った結果を使ってViewオブジェクトへ描写を指示

<img src=https://user-images.githubusercontent.com/55877379/148474506-424064ca-7027-42fc-b0d7-c1949e7f578d.png  width=70%>

### サンプルコード
実際にコードで表現してみると以下のようになります。
``` swift

// Model
final class Model {
   let notificationCenter = NotificationCenter()

   private(set) var count = 0 {
      didSet {
         notificationCenter.post(
            name: .init(rawValue: "name"),
            object: nil,
            userInfo: ["count": count]
         )
      }
   }

   func countDown() { count -= 1 }
   func countUp() { count += 1 }
}

// View
final class View: UIView {
   let label: UILabel
   let minusButton: UIButton
   let plusButton: UIButton

   override init(frame: CGRect) {
      // ... 画面のレイアウトの設定 ...
   }
}

// Controller
final class ViewController: UIViewController {
   var myModel: Model? {
      didSet {
         // ViewとModelを結合し、Modelの監視を開始する
         registerModel()
      }
   }

   private(set) lazy var myView: View = View()

   override func loadView() {
      view = myView
   }

   deinit {
      myModel?.notificationCenter.removeObserver(self)
   }

   private func registerModel() {
      guard let model = myModel else { return }

      myView.label.text = model.count.description
      myView.minusButton.addTarget(
         self,
         action: #selector(onMinusTapped),
         for: .touchUpInside
      )
      myView.plusButton.addTarget(
         self,
         action: #selector(onPlusTapped),
         for: .touchUpInside
      )
      model.notificationCenter.addObserver(
         forName: .init(rawValue: "count"),
         object: nil,
         queue: nil,
         using: { [weak self] notification in
            guard let self = self else { return }

            if let count = notification.userInfo?["count"] as? Int {
               self.myView.label.text = "\(count)"
            }
         }
      )
   }

   @objc func onMinusTapped() { myModel?.countDown() }
   @objc func onPlusTapped() { myModel?.countUp() }
}
```

## 4. MVP
MVPアーキテクチャは画面の描画処理とプレゼンテーションロジックを分離するGUIアーキテクチャです。  
MVCの責務(=解決すべき問題の領域)を再分割し、テストの容易性と作業分担のしやすさを手に入れたことが特徴です。  
MVPには`Passive View`と`Supervising Controller`の2つのパターンがあり、これらの違いは責務の分け方にあります。  
`Passive View`はプレゼンテーションロジックを完全に`Presenter(後ほど説明します)`に担当させるのに対し、`Supervising Controller`は複雑なプレゼンテーションロジックは`Presenter`に担当させつつ、簡単なものは`View`に残し、`Model`の状態変更通知を検知したらView自身でもプレゼンテーションロジックを処理する違いがあります。  

### MVPの目的
MVPの特徴としてテスト容易性と作業分担のしやすさを挙げましたが、これは言い換えるならば保守のしやすさとも言えます。  
より複雑なアプリケーションになるほど、保守のしやすさが重要になってきます。  
この目的に対して、MVPではプレゼンテーションロジックを担うコンポーネントである`Presenter`と`Presenter`が`View`に対して手続き的に描画指示を出す`フロー同期`を導入することで解決を図りました。  
iOSにおけるMVPでは、必要な箇所をprotocolとして宣言してコンポーネント間を疎結合にすることで、テスト容易性と作業分担のしやすさを実現しています。

### データの2つの同期方法
MVPの2つのパターンを理解する上で重要になるのが、コンポーネント間のデータを同期する`フロー同期`と`オブザーバー同期`の2つです。  

* フロー同期: 上位レイヤーのデータを下位レイヤーに都度セットしてデータを同期する、手続き的方法(手動)
    - [メリット] データフローを追いやすい(データを手動的に同期するため、どれとどれを同期させれば良いのかを把握しやすい)
    - [デメリット] 複数の箇所でのデータ同期をする際に全ての箇所の参照を持つ必要がある(複数画面でお気に入りのデータを管理する際に、共通したデータを参照している全ての参照を保持する必要がある)

* オブザーバー同期: 監視元である下位レイヤーが監視先である上位レイヤーからObserverパターンを使って送られるイベント通知を受け取ってデータを同期する、宣言的方法(自動)
    - [メリット] 共通した監視先を持つ複数の箇所で、データを同期しやすい(お気に入りのデータなどを複数画面で管理する必要があっても自動的に全ての箇所を変更できる)
    - [デメリット] データが変更されるたびに自動で同期処理が実行されるため、いつデータが同期されるかが追いづらい

MVPにおける`Passive View`では`Presenter → View`間にフロー同期を使います。  
iOSアプリ開発における、MVPのフロー同期とは`label.text = newText`による描写処理や、データソースを更新してから`tableView.reloadData()`を呼び出す描写処理などです。  
`Supervising Controller`では両方の同期方法を使用し、`Presenter → View`間をフロー同期し、`Model → View`間をオブザーバー同期します。  
フロー同期については直前に説明したとおりで、オブザーバー同期とは、監視元であるViewが、監視先であるModelからNotificationCenterなどで送られるイベントを受け取って、描写処理を行うことなどです。
2つの同期方法はどちらが優れているというものではなく、それぞれにメリット・デメリットを持っているため、設計段階でどちらを採用するか考える必要があります。  
この2つの同期方法はMVPのみならず、多くのアーキテクチャパターンで共通して利用される方法でもあるので場面ごとの有利不利を把握しておきましょう。

### MVPの構造
`Passive View`と`Supervising Controller`では異なる同期方法のため若干の違いがありますが、まず共通している部分について述べます。

* Model
    - UIに関係しない純粋なドメインロジックやそのデータを持つ。画面表示がどのようなものでも共通な、アプリの機能実現のための処理が置かれる
    - MVPにおけるModelはMVC、MVVMにおけるModelと同じ立ち位置
    - GUIアーキテクチャのため、Modelの詳細な責務分けについては関与しない
    - Model自身は他のコンポーネントに依存しない。ViewやPresenterがなくてもビルド可能である

* View
    - ユーザー操作の受け付けと、画面表示を担当するコンポーネント。iOSのMVPにおいてはViewControllerもViewに含まれる
    - タップやスワイプなどのUIイベントを受け付け、Presenterに処理を委譲、Modelの処理の呼び出しを行う
    - Modelに変更が発生した場合、何らかの方法でViewにそれが伝達され、表示内容が更新される

* Presenter
    - ViewとModelの仲介役であり、プレゼンテーションロジックを担う
    - Modelはアプリのビジネスロジックを知っているが、それが画面上でどのように表示されるかを知るべきではない。Viewをシンプルにするために、複雑な(あるいは全ての)プレゼンテーションロジックを持たせたくないが、Modelに画面表示に関するロジックを持たせたくない場合に使用する

#### Passive View
`Passive View`はViewを完全に受け身にするパターンです。各コンポーネントのデータのやり取りはフロー同期によって実現します。  
Viewは基本的に全てのユーザーの入力イベントをPresenterに渡します。Presenterは入力に応じてプレゼンテーションロジックを処理し、Viewに対して手続き的な描画指示を出します。  
ViewはPresenterの指示によってのみ描画処理を行い、自身を起点とした描画処理は行いません(これがViewが受け身であるということ)。  
`Passive View`の利点は、Viewに画面描画の実装を持たせておくのみにしておき、描画指示はPresenterに任せることで、プレゼンテーションロジックをテストが行いやすくなる点です。

* Model
  - Presenterからのみアクセスされ、Viewとは直接の関わりを持たない

* View
  - Presenterからの描画指示に従うだけで、完全な受け身の立ち位置となる

* Presenter
  - 全てのプレゼンテーションロジックを受け持つ

<img src=https://user-images.githubusercontent.com/55877379/148474508-1d286059-208b-4a22-a58d-663498e9fc05.png  width=70%>

#### Supervising Controller
`Supervising Controller`はフロー同期とオブザーバー同期の両方を使うパターンです。ViewはPresenterとフロー同期で、Modelとオブザーバー同期でデータをやり取りします。  
Viewは簡単なプレゼンテーションロジックを持ち、Presenterは複雑なプレゼンテーションロジックを持ちます。  
ModelはPresenterによって呼び出され、Viewに対して描画に必要なデータをイベント通知によって受け渡します。  
ViewはPresenterからの描画指示に応えると同時に、Modelからのイベント通知によって受け渡されたデータを自身で解釈して描画に利用します。  
`Passive View`では完全なフロー同期でデータのやり取りを行うため、データフローが追いやすくなり、開発者間で認識の統一が図りやすいというメリットがある一方で、簡単な処理でも、Modelが絡んだ処理は必ず`View → Presenter → Model → Presenter → View`というデータフローを踏む必要があるためコードが冗長になりがちです。  
`Supervising Controller`は`Model → View`間にオブザーバー同期を用いることで、この冗長さを解決できます。

* Model: Presenterからのみアクセスされ、必要に応じてViewに対してイベントを通知する
* View: PresenterとModelの双方から描画指示を受け、簡単なプレゼンテーションロジックを持つ
* Presenter: 複雑なプレゼンテーションロジックを担う

<img src=https://user-images.githubusercontent.com/55877379/148474537-2047732c-0e38-4f07-8af6-02cfd24fc8ec.png  width=70%>

#### 選定基準
2つのMVPパターンの使い分けについて、「全てのプレゼンテーションロジックをテスト可能にしたいか」という基準で判断します。  
テスト可能な状態にするには、Viewがプレゼンテーションロジックを持たないようにする必要があります。  
もし、全てのプレゼンテーションロジックをテスト可能な状態にしたいのであれば、Modelの変更を画面に反映する際に、Presenterを介さなければならないという冗長さに目を瞑りつつも`Passive View`を選択する必要があるでしょう。一方で、そのアプリケーションで取り扱うプレゼンテーションロジックが簡単なものであればテストが不要という判断ができます。その場合は、冗長さの軽減を繋げるために`Supervising Controller`を選択することができるでしょう。  
それぞれのMVPパターンのメリット・デメリットをよく抑えて、そのプロジェクトの現状に合ったパターンを選択していきましょう。

### サンプルコード
実際にコードで表現してみると以下のようになります。(Passive-Viewでの実装の場合)
``` swift
/**
 * GitHubのユーザー検索を実施し、検索結果のユーザーのGitHubリポジトリ一覧を表示するアプリ
 */

/** Model
 * プレゼンテーションロジック以外のドメインロジックを担当する
 */
protocol SearchUserModelInput {
   func fetchUser(query: String, completion: @escaping (Result<[User]>) -> Void)
}

final class SearchUserModel: SearchUserModelInput {
   func fetchUser(
      query: String,
      completion: @escaping (Result<[User]>) -> VOid
   ) {
      let session = GitHub.Session()
      let request = SearchUserRequest(
         query: query,
         sort: nil,
         order: nil,
         page: nil,
         perPage: nil
      )

      session.send(request) { result in
         switch result {
            case let .success(response):
               completion(.success(response.0.items))

            case let .failure(error):
               completion(.failure(error))
         }
      }
   }
}


/** Presenter
 * プレゼンテーションロジックを処理する
 * Viewに描画指示を出す
 */
protocol SearchUserPresenterInput {
   var numberOfUsers: Int { get }
   func user(forRow row: Int) -> User?
   func didSelectRow(at indexPath: IndexPath)
   func didTapSearchButton(text: String?)
}

protocol SearchUserPresenterOutput: AnyObject {
   func updateUsers(_ users: [User])
   func transitionToUserDetail(userName: String)
}

final class SearchUserPresenter: SearchUserPresenterInput {
   private(set) var users: [User] = []

   private weak var view: SearchUserPresenterOutput!
   private weak var model: SearchUserModelInput

   init(
      view: SearchUserPresenterOutput,
      model: SearchUserModelInput
   ) {
      self.view = view
      self.model = model
   }

   var numberOfUsers: Int {
      users.count
   }

   func user(forRow row: Int) -> User? {
      guard row < users.count else { return nil }
      return users[row]
   }

   /* プレゼンテーションロジックの処理 */
   func didSelectRow(at indexPath: IndexPath) {
      guard let user = user(forRow: indexPath.row) else { return }
      view.transitionToUserDetail(userName: user.login)
   }

   /* プレゼンテーションロジックの処理 */
   func didTapSearchButton(text: String?) {
      guard
         let query = text,
         let !query.isEmpty
      else {
         return
      }

      model.fetchUser(query: query) { [weak self] result in
         switch result {
            case let .success(users):
               self?.users = users

               DispatchQueue.main.async {
                  /* viewに描画指示を出す */
                  self?.view.updateUsers(users)
               }

            case let .failure(error):
               print(error) // error handling
         }
      }
   }
}


/** View
 * ユーザー入力をPresenterに伝える
 * 画面の描画処理を行う
 */
final class SearchUserViewController: UIViewController {
   @IBOutlet private weak var searchBar: UISearchBar!
   @IBOutlet private weak var tableView: UITableView!

   private var presenter: SearchUserPresenterInput!
    
   func inject(presenter: SearchUserPresenterInput) {
      self.presenter = presenter
   }

   ...
}

extension SearchUserViewController: UISearchBarDelegate {
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      /* ユーザー入力をPresenterに伝える */
      presenter.didTapSearchButton(text: searchBar.text)
   }
}

extension SearchUserViewController: UITableViewDelegate {
   func tableView(
      _ tableView: UITableView,
      didSelectRowAt indexPath: IndexPath
   ) {
      tableView.deselectRow(at: indexPath, animated: false)
      /* ユーザー入力をPresenterに伝える */
      presenter.didSelectRow(at: indexPath)
   }
}

extension SearchUserViewController: UITableViewDataSource {
   ...
}

extension SearchUserViewController: SearchUserPresenterOutput {
   /* 画面の描画処理を行う */
   func updateUsers(_ users: [User]) {
      tableView.reloadData()
   }

   /* 画面の描画処理を行う */
   func transitionToUserDetail(userName: String) {
      guard let userDetailVC = UIStoryboard(
         name: "UserDetail",
         bundle: nil
      ).instantiateInitialViewController() as? UserDetailViewController
      else {
         return
      }

      let model = UserDetailModel(userName: userName)
      let presenter = UserDetailPresenter(
         userName: userName,
         view: userDetailVC,
         model: model
      )
      userDetailVC.inject(presenter: presenter)

      navigagtionController?.pushViewController(userDetailVC, animated: true)
   }
}
```

## 4. MVVM
MVVMアーキテクチャは画面の描画処理とプレゼンテーションロジックを分離するGUIアーキテクチャです。  
GUI構造をModel/View/ViewModelの3つに分け、画面の描画処理をViewに、画面描画のロジックをViewModelというコンポーネントに閉じ込めます。  
そして、ViewとViewModelを`データバインディング`と呼ばれる仕組みで関連づけることで、ViewModelの状態変更に同期してViewの状態を更新され、画面に反映されることが特徴です。  
このデータバインディングによって、プレゼンテーションロジックを担うViewModel内にViewに対する手続き的な描画指示を出す必要がなくなります。これは宣言的なバインディングにより、ViewModel自身の状態を更新するだけで、Viewの描画処理が発火するためです。  
ViewとViewModelとはデータバインディングによって完全に疎結合になるため、具体的なViewが存在しなくてもプレゼンテーションロジックをテストしやすいメリットもあります。

### データバインディング
データバインディングとは、2つのデータの状態を監視し同期する仕組みのことです。  
片方のデータ変更をもう一方が検知して、データを自動的に更新します。  

<img src=https://user-images.githubusercontent.com/55877379/148474818-e8fb24a0-a790-4224-82db-f7978a0a6fad.png  width=70%>

### MVVMの目的
MVVMは、関数型リアクティブプログラミング(FRP)と相性が良いことが挙げられます。  
FRPについては詳しい説明は省きますが、時間や外部の入力とともに変化する値や計算によるデータの流れに着目する手法のことです。
例えばGPSの位置情報を取得する時に適用できます。GPSが移動し、座標(緯度・経度)が変化するたびに位置情報データが送信され、移動をやめるとデータの送信が止まるように、一定の期間の位置情報データを一片に送信するのではなく、変化が起きる度にデータを送信するのが特徴です。こうしたデータの流れをデータストリームと呼び、データの様子や処理の様子を模擬的に可視化する手法としてマーブルダイアグラムがあります。<図4>

<図4>
<img src=https://user-images.githubusercontent.com/55877379/148474813-8dfce280-3240-4d6a-9ca7-e4be5a4b98d1.png  width=70%>

FRPはModelの変更やViewの変更が相互に接続されてリアクティブに反応できる点と、手続き的ではなく宣言的にロジックを宣言できる点がMVVMとの相性が良く、MVVMのアーキテクチャが採用される理由にもなっています。

### MVVMの構造

* Model
    - UIに関係しない純粋なドメインロジックやそのデータを持つ
    - MVC、MVVPにおけるModelと同じ立ち位置
    - GUIアーキテクチャのため、Modelの詳細な責務分けについては関与しない
    - 他のコンポーネントに依存しない

* View
    - ユーザー操作の受け付けと、画面表示を担当するコンポーネント
    - ViewModelが保持する状態とデータバインディングし、ユーザー入力に応じてViewModelが自身が保持するデータを加工・更新することで、バインディングした画面表示を更新

* ViewModel: 
    - View-Model間の画面表示のための仲介役であり、以下の責務を担う
      - Viewに表示するためのデータを保持する
      - Viewからイベントを受け取り、Modelの処理を呼び出す
      - Viewからイベントを受け取り、加工して値を更新する
    - Modelはアプリケーションのビジネスロジックを知っているが、それが画面上でどのように表示されるかを知るべきではない。ビジネスロジックと独立した、画面表示のために必要な状態とロジックを担う
    - Viewの抽象化を行うという点でMVPのPresenterと役割の被る部分が多いものの、いくつか違いが存在し、PresenterはViewに対して手続き的な更新処理を書かなければいけないためViewの参照を保持する必要があるが、ViewModelではViewの状態と自身が持つ状態を関連づけること(=データバインディング)によって状態を更新するため、手続き的な更新処理を必要とせず、ViewModelがViewの参照を保持する必要がない違いがある

<img src=https://user-images.githubusercontent.com/55877379/148474547-62db8329-4cab-4fa1-8b3a-7f6eaa38ecd0.png  width=70%>

### サンプルコード
実際にコードで表現してみると以下のようになります。(Combineを使用した場合)

起動時 | 正常時 | エラー時
:--: | :--: | :--:
<img src=https://user-images.githubusercontent.com/55877379/148474932-f643b00b-ee1c-467f-a189-a398748b8bfc.png  width=70%> | <img src=https://user-images.githubusercontent.com/55877379/148474935-d629c3f9-640c-48cf-aa76-52e547255377.png  width=70%> | <img src=https://user-images.githubusercontent.com/55877379/148474937-6083338a-e1bc-48b3-aab1-e0fcb56843e2.png  width=70%>

``` swift
/** 
 * メールアドレスとパスワードを入力し、ログインボタンを押した時にログインの処理をする
 * メールアドレスとパスワードにバリデーションを施し、空文字の場合はエラーを表示させる
 */

/** Model
 * protocol化して疎結合に、テスタブルにする
 */
protocol LoginModelProtocol {
   func login(email: String, password: String)
}

final class CombineModel: LoginModelProtocol {
   // ...... 
   func login(email: String, password: String) {
      // ログイン処理
   }
}

/** ViewModel
 * Viewに表示するためのデータを保持する
 * Viewからイベントを受け取り、Modelの処理を呼び出す
 * Viewからイベントを受け取り、加工して値を更新する
 */
import Combine

enum ValidationError {
    case none
    case invalidEmail
    case invalidPassword
    case invalidEmailAndPassword
    case done
}

final class CombineViewModel {
   /* Viewからイベントを受け取り、加工して値を更新する */
    @Published var emailAddress: String = ""
    @Published var password: String = ""

    /* Viewに表示するためのデータを保持する */
    @Published var isLoginEnabled: Bool = false
    @Published var validateState: ValidationError = .none

    func validate(emailAddress: String, password: String) {
        switch (emailAddress.isEmpty, password.isEmpty) {
        case (true, true):
            isLoginEnabled = false
            validateState = .invalidEmailAndPassword

        case (true, false):
            isLoginEnabled = false
            validateState = .invalidEmail

        case (false, true):
            isLoginEnabled = false
            validateState = .invalidPassword

        case (false, false):
            isLoginEnabled = true
            validateState = .done
        }
    }

    func login() {
        // combineModel.login(email: emailAddress, password: password).....
        print("メールアドレス: \(emailAddress)")
        print("パスワード: \(password)")
    }
}

/** View
 * ユーザー入力をViewModelに伝搬する
 * 自身の状態とViewModelの状態をデータバインディングする
 * ViewModelから返されるイベントを元に描写処理を実行する
 */
import Combine
import UIKit

final class CombineViewController: UIViewController {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                emailTextField, passwordTextField, validateLabel, loginButton
            ]
        )
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "メールアドレス"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "パスワード"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let validateLabel: UILabel = {
        let label = UILabel()
        label.text = "メールアドレスとパスワードを入力"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("ログイン", for: .normal)
        button.backgroundColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var viewModel: CombineViewModel!

    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupEvent()
        bindViewModel()
        bindView()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CombineViewController {

    func inject(viewModel: CombineViewModel) {
        self.viewModel = viewModel
    }
}

private extension CombineViewController {

    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(stackView)
    }

    func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 64),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -64),
            
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func setupEvent() {
        loginButton.addTarget(
            self,
            action: #selector(tappedLoginButton),
            for: .touchUpInside
        )
    }

    func bindViewModel() {
        /* ユーザー入力をViewModelに伝搬する */
        emailTextField.textDidChangePublisher
            .assign(to: \.emailAddress, on: viewModel)
            .store(in: &cancellables)

        /* ユーザー入力をViewModelに伝搬する */
        passwordTextField.textDidChangePublisher
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)
    }

    func bindView() {
        Publishers.CombineLatest(
            emailTextField.textDidChangePublisher,
            passwordTextField.textDidChangePublisher
        ).sink { [weak self] emailAddress, password in
            self?.viewModel.validate(
                emailAddress: emailAddress,
                password: password
            )
        }
        .store(in: &cancellables)

        /* ViewModelから返されるイベントを元に描写処理を実行する */
        viewModel.$isLoginEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEnabled in
                guard let self = self else { return }
                
                self.loginButton.isEnabled = isEnabled
                self.loginButton.backgroundColor = isEnabled ? .green : .gray
            }
            .store(in: &cancellables)

        /* ViewModelから返されるイベントを元に描写処理を実行する */
        viewModel.$validateState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .none:
                    self.validateLabel.textColor = .black
                    self.validateLabel.text = "メールアドレスとパスワードを入力"

                case .invalidEmail:
                    self.validateLabel.textColor = .red
                    self.validateLabel.text = "メールアドレスを入力"

                case .invalidPassword:
                    self.validateLabel.textColor = .red
                    self.validateLabel.text = "パスワードを入力"

                case .invalidEmailAndPassword:
                    self.validateLabel.textColor = .black
                    self.validateLabel.text = "メールアドレスとパスワードを入力"

                case .done:
                    self.validateLabel.textColor = .green
                    self.validateLabel.text = "OK"
                }
            }
            .store(in: &cancellables)
    }
}

extension CombineViewController {

    @objc func tappedLoginButton() {
        viewModel.login()
    }
}

extension UITextField {

    var textDidChangePublisher: AnyPublisher<String, Never> {
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { $0.object as? UITextField }
            .map { $0?.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

/**
 * AppDelegate
 */
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = CombineViewController()
        viewController.inject(viewModel: CombineViewModel())
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }
}
```

## 5. Clean Architecture
これまでMVC、MVP、MVVMといったUIとModelとを分離するアーキテクチャ(GUIアーキテクチャ)を説明していきましたが、それに対してClean Architectureはシステムアーキテクチャに属するアーキテクチャになります。UIだけでなくアプリケーション全体、つまりModelの内部表現にまで踏み込んだアーキテクチャのパターンです。  

## Clean Architectureの特徴
あるシステムの1機能を実現するアプリケーションを考える時、Clean Architectureはその実現する機能の領域(ドメイン)と技術の詳細に注目し、アプリケーションを4つのコンポーネントに分けます。

* Entity
    - アプリケーションに依存しない、ドメインに関するデータ構造やビジネスロジック

* Use Case
    - アプリケーションで固有なロジック
    - UIに関する処理は書かない。入出力のための出入口(ポート)は存在するが、そのポートにどのような経路から入力があって、どこへ出力するのかは知らない

* インターフェースドライバー
    - Use Case・フレームワークとドライバーで使われるデータ構造を互いに変換する
    - Use Caseの入出力ポートを外側の何に接続するかを決定する責務も持つ

* フレームワークとドライバ
    - データベース(DB)、Webなどのフレームワークやツールの「詳細」

この4つが同心円状になるよう、もっとも純粋で他に依存のないEntityを中心に据え、その外にUseCaseを置きます。  
逆にデータベース/Web/フレームワーク/OSのような移植や、技術遷移で変わりやすいものは最外周に配置します。  
残るインターフェースアダプターは内外の変換層として、UseCaseと最外層との間に挟み込んだ階層構造を作ります。  
そして、依存の方向を外から内への一方向に厳密に定めます。  
この構造を維持してアプリケーションを作ることで、変わりやすい部分を変えやすく、維持しておきたい部分はそのままにしやすくできます。また、内側にあるEntityやUseCaseは外側のWebAPIサーバーやデバイスドライバなどに依存していないので、それらの完成を待つことなくロジックをテストできます。

<img src=https://user-images.githubusercontent.com/55877379/148474993-11d30618-65ac-4922-85e3-07e83d331000.png  width=70%>

### Clean Architectureの目的
現在のiOSアプリは、UIと単純な処理だけでは成り立たず、WebAPIによるデータ通信、データベースへのデータ読み書きなど、外部との連携機能を持つことが当然になっています。  
また、アプリケーションの要件は複雑・大規模化していて、GUIアーキテクチャが「Model」とひとくくりにするコンポーネントも、内部は加速度的に複雑になっています。  
さらにアプリはiOSだけでなくAndroidでも同時に開発することも一般的です。ビジネスロジックなどOS非依存の部分を同じように書ければ保守性も高まります。  
こうしたシステム全体での大きな共通部分が存在していて、なおかつ複数のプラットフォームに展開するときに効果を発揮する設計パターンでもあります。

### レイヤー間の通信
Clean Architectureにはレイヤー間の相互関係に重要なルールがあり、それは内側の円は外側の円からのみ参照されることです。  
内側の円が外側の円を直接参照することがありません(=内側のクラスが外側のクラスや関数を直接参照することがあってはいけません)。
そのため、レイヤー間の相互通信には`依存関係逆転の原則`が用いられます。

#### 依存関係逆転の原則
レイヤー間の相互通信に依存関係逆転の原則が用いられますが、その間の通信がどのような関係の下で行われるかを探っていきます。  
以下の図はClean Architectureの2つの層(Use Caseとインターフェースアダプター)を示したものです。

<img src=https://user-images.githubusercontent.com/55877379/148475001-402e6c43-d94f-470e-bf58-772317d62f51.png  width=70%>

UseCaseからPresenterへデータを渡すためには依存関係逆転の原則を使い、入出力それぞれの通信仕様を満たすprotocolを内側のUseCaseに定義しておき、外側のController、Presenterをそのprotocolに準拠させておきます。そしてUseCaseにオブジェクトの参照を渡すことで、UseCaseからのイベントを間接的に受け取ることができます。  
コードで表すと以下のような流れになります。  

``` swift
// UseCase層
protocol UseCaseOutputPort: AnyObject {
    func useCaseDidUpdate(value: Int)
}

protocol UseCaseInputPort {
    func update(something: Int)
}

final class UseCase: UsecaseInputPort {
    private weak var output: UseCaseOutputPort?

    /* あくまで入出力のデータを受け取れるオブジェクトであり、Presenterの具体的なクラスではない */
    init(output: UseCaseInputPort) {
        self.output = output
    }

    func update(something value: Int) {
        // 値を使ったアプリケーション固有の処理
        // Entity層の処理・データも使える
 
        // Output経由でPresenterへ通知(逆方向)
        output?.useCaseDidUpdate(value: value)
    }
}

final class Presenter: UseCaseOutputPort {
    func useCaseDidUpdate(value: Int) {
        print("UI更新\(value)")
    }
}

final class Controller {
    private let useCaseInput: UseCaseInputPort

    init(input: UseCaseInputPort) {
        self.useCaseInput = input
    }

    func received(something value: Int) {
        // Input経由でUseCaseを呼び出す(順方向)
        useCaseInput.update(something: value)
    }
}

// 円の構築
let useCase: UseCase = .init(output: Presenter())
let controller: Controller = .init(input: useCase)

// 処理開始
controller.received(something: 10)
```

#### 非同期を前提としたメソッド
通信を実現するときに、外の層に対して問い合わせるメソッドを用意するときの、その結果をどのように受け取るかという問題があります。  
UseCaseからWebやデータベースに向かってデータを取得する処理を考えてみます。  
WebやデータベースとUseCaseとの間には、データを変換するGatewayを挟みます。  

<img src=https://user-images.githubusercontent.com/55877379/148475005-189be52d-5b81-45e7-b44f-77dec5a35c9a.png width=70%>

UseCaseからGatewayに問い合わせをするとき、取得したデータはどのようにUseCaseに渡すべきでしょうか。  
方法として、以下のようなものが挙げられます。  

1. メソッドの戻り値で渡す
  - 最も避けるべき方法
  - データがネットワーク越しのストレージに保存されていた場合などは、UseCaseは外側の都合に関知せずメソッドを呼び、戻り値を持つことになるため、ネットワークアクセスの間は処理が止まってしまう(データの受け渡しは非同期で結果が得られることを大前提に考える必要がある)

2. デリゲートメソッドとして結果を受け渡す
  - 結果を非同期で返せるため、戻り値による問題は避けられる
  - 一連の処理がコード上で区切られることになるため処理が追いづらくなる、呼び出しコードとデリゲートメソッドをペアで用意するのが面倒

3. 完了ハンドラで結果を渡す
  - 結果を渡すタイミングを非同期にでき、処理も分断されない

※ 完了ハンドラを使った結果の受け取り

``` swift
// UseCase層
protocol SomeDataRepositoryProtocol: AnyObject {
    func get(ofIndex: Int, completionHandler: @escaping (_ values: Result<[Int]>) -> Void)
}

// インターフェースアダプター層
final class SomeDataRepositoryGateway: SomeDataRepositoryProtocol {
    func get(ofIndex: Int, completionHandler: @escaping (_ values: Result<[Int]>) -> Void) {
        // ... External Interfaceでの処理 ...
        comletionHandler(.success(result)) // 結果を渡す
    }
}
```

### Clean ArchitectureとGUIアーキテクチャ
Clean Architectureはシステムアーキテクチャであり、対象範囲はアプリケーション全体に渡ります。  
GUIのレイヤーについては細かな構成の指定はありません。  
あくまでUIを含めた「フレームワークとドライバー」とビジネスロジックの分離、EntityとUseCaseの分離、そして依存関係の方向について定めた設計思想です。  
UIの構造に影響を受けないため、Clean ArchitectureはMVC, MVP, MVVMといったGUIアーキテクチャと組み合わせることもできます。(MVP + Clean Architecture, MVVM + Clean Architecture...)

### VIPER
Clean Architectureの派生として、VIPERアーキテクチャがあります。  
簡単にいうと、Clean Architectureを元に画面遷移のためのRouterを足したものになります。  
「VIPER」 = Clean Architecture + MVP(Passive View) + Router

* View
  - 画面表示とUIイベント受信。Clean Architectureにおけるフレームワークとドライバに相当

* Interactor
  - データ操作とユースケース。Entityを使ってビジネスロジックを表現する。Clean ArchitectureのUseCaseに相当

* Presenter
  - アーキテクチャ上の仲介役(Mediator)。UIKitに依存しない。Clean Architectureのインターフェースアダプターに相当

* Entity
  - Interactorによってのみ使われる単純な構造のモデル。Clean ArchitectureのEntityに相当

* Router
  - 画面遷移と新しい画面のセットアップ

<img src=https://user-images.githubusercontent.com/55877379/148474998-f3d3ac14-baea-418a-ba08-f61d13bdd464.png width=70%>

## まとめ
全体的にふわっとしたものになってますがGUIアーキテクチャとシステムアーキテクチャについて説明しました。  
他にもReduxやFluxなどのアーキテクチャもありますが今回は主要なアーキテクチャについてのものになります。  
これらは書籍の「iOSアプリ設計パターン入門」に全て記載されているものになりますので、ReduxやFlux、その他深く詳しく知りたい場合は本書を読むのが一番かと思います。

## 参考
関義隆他 (2019) iOSアプリ設計パターン入門 PEAKS