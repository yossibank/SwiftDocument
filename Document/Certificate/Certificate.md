## 詳細概要
- [詳細概要](#詳細概要)
  - [4.証明書登録](#4証明書登録)
    - [Code Signing Identity](#code-signing-identity)
  - [5.AppID登録](#5appid登録)
    - [AppID作成方法](#appid作成方法)
  - [6.Device登録](#6device登録)
    - [DeviceID登録方法](#deviceid登録方法)
  - [7.プロビジョニングプロファイル登録(Apple Developer Center)](#7プロビジョニングプロファイル登録apple-developer-center)
    - [プロビジョニングプロファイル作成方法](#プロビジョニングプロファイル作成方法)
  - [8.プロビジョニングプロファイル登録(ローカル)](#8プロビジョニングプロファイル登録ローカル)
  - [9.ビルド設定](#9ビルド設定)
  - [10.ビルドとアーカイブ](#10ビルドとアーカイブ)
  - [11.豆知識(Tips)](#11豆知識tips)
    - [証明書の管理](#証明書の管理)
      - [新しく証明書を作成するパターン](#新しく証明書を作成するパターン)
      - [既存の証明書を渡すパターン](#既存の証明書を渡すパターン)
- [参考文献](#参考文献)

### 4.証明書登録

`3.証明書作成`で作成した証明書(.cerファイル)をダウンロードし、ローカルマシンのキーチェーン内に取り込みます。

この時、証明書が`2.CSR(証明書署名要求)作成`でキーチェーンに保存された秘密鍵と自動的に紐づきます。

<img src="../../Image/Certificate/Certificate27.png" width="80%">

紐づいた場合には、証明書と秘密鍵がペアになって表示されます。

<img src="../../Image/Certificate/Certificate28.png" width="80%">

もし、証明書に対して秘密鍵が紐づかない場合は、`2.CSR(証明書署名要求)作成`の際に作成された秘密鍵がローカルマシンに存在していないことを意味します。

#### Code Signing Identity

証明書と秘密鍵が紐づいてペアとなったものは[identity](https://developer.apple.com/documentation/security/certificate_key_and_trust_services/identities)と呼ばれ、特にコード署名においてはCode Signing Identityと呼ばれます。

`4.証明書登録`で証明書と秘密鍵が紐づかれると説明しましたが、これは署名を行う際に使用する証明書内の公開鍵とペアとなっている秘密鍵を特定するために行なっています。

Code Signing Identityはp12というファイル形式でインポート・エクスポートすることができます。p12ファイルはコード署名に必要な公開鍵・秘密鍵、諸々の情報を含んでいるため、取り扱いには注意する必要があります。

<img src="../../Image/Certificate/Certificate29.png" width="80%">

p12ファイルは、例えばローカルマシンを買い替える時などに使えます。古いローカルマシンからp12ファイルをエクスポートし、新しいローカルマシンにインポートすれば、新しいローカルマシンで再度証明書の作成をする必要がなくなります。

<img src="../../Image/Certificate/Certificate30.png" width="80%">

他にもp12ファイルは、チーム開発する際に共有をしたり、BitriseといったCI/CDツールでコード署名を行うために必要だったりします。


### 5.AppID登録

AppIDはアプリケーションを識別するための固有のIDになります。

このIDには、Capabilitiesというアプリが必要とする主要な機能を有効にするための設定も含める必要があります。

<img src="../../Image/Certificate/Certificate31.png" width="80%">

#### AppID作成方法

* Identifiers → ＋マーク → Register a new identifier「App IDs」→ Selecte a type「App」選択

<img src="../../Image/Certificate/Certificate32.png" width="80%">

**Description** → AppIDの名前

**App ID Prefix** → AppIDの接頭辞でTeamIDが割り当てられる

**Bundle ID**

1. Explicit → アプリケーションのBundleIDと完全一致の値を入力する
2. Wildcard → アプリケーションのBundleIDと完全一致させる必要はなく、ワイルドカード(*)を使用できる

**Capabilities** → アプリ機能を有効にするかの設定

<img src="../../Image/Certificate/Certificate33.png" width="80%">

※ **BundleID**でWildcardを選択した場合はCapabilitiesを設定できません。そのためアプリ機能を有効にしたいものを含めたい場合はExplicitで完全一致のBundleIDを設定する必要があります。

<img src="../../Image/Certificate/Certificate34.png" width="80%">

### 6.Device登録

Device登録ではアプリをインストールする端末のUDID(Unique Device Identifier)を登録します。

<img src="../../Image/Certificate/Certificate35.png" width="80%">

UDIDはFinderなどの端末情報内に記載されています。

<img src="../../Image/Certificate/Certificate36.png" width="80%">

#### DeviceID登録方法

* Devices → ＋マーク → Register a New Device情報入力

<img src="../../Image/Certificate/Certificate37.png" width="80%">

**Device Name** → Devicesに登録する名前

**Device ID(UUID)** → 端末UDID

### 7.プロビジョニングプロファイル登録(Apple Developer Center)

これまでiOSがアプリをインストールする際に、証明書を使ってコード署名を行い、正当性を検証していることを説明してきました。しかしながら、iOSはコード署名だけではなく他にも検証しているものがあります。それがAppIDとDeviceIDです。そして、これらのiOSが検証する情報を全てまとめたものがプロビジョニングプロファイルになります。

※ プロビジョニングプロファイル → .mobileprovisionファイル形式で作成されます

iOSがプロビジョニングプロファイルの中身を参照して検証している内容は以下の3つになります。

1. 証明書内の公開鍵を使って、コード署名が正しくできるかどうか
2. アプリケーションのBundleIDがAppIDの要件を満たしているかどうか
3. インストールする先の端末のUDIDがDeviceID内に含まれているかどうか

<img src="../../Image/Certificate/Certificate38.png" width="80%">

以上を踏まえて、iOSがアプリをインストールする際の流れは以下のようになります。

<img src="../../Image/Certificate/Certificate39.png" width="80%">

#### プロビジョニングプロファイル作成方法

1. Profiles → ＋マーク → Register a New Provisioning Profile情報入力

<img src="../../Image/Certificate/Certificate40.png" width="80%">

2. 作成したAppIDを選択

<img src="../../Image/Certificate/Certificate41.png" width="80%">

3. 作成した証明書を選択

<img src="../../Image/Certificate/Certificate42.png" width="80%">

4. 作成したDeviceIDを選択

<img src="../../Image/Certificate/Certificate43.png" width="80%">

5. 作成するプロビジョニングプロファイルの名前設定、生成

<img src="../../Image/Certificate/Certificate44.png" width="80%">

### 8.プロビジョニングプロファイル登録(ローカル)

Xcodeの場合では、使用するプロビジョニングプロファイルを登録します。

<img src="../../Image/Certificate/Certificate48.png" width="80%">

### 9.ビルド設定

プロビジョニングプロファイル登録後は、アプリケーションのBundleIDがプロビジョニングプロファイルの**AppID**の要件を満たしているかどうか、証明書内の公開鍵とp12内の秘密鍵がペアとして一致しているかどうかなどを確認し、適切なものに設定します。

### 10.ビルドとアーカイブ

上記までが正しく設定されていれば、アプリケーションをビルド・アーカイブすることができます。

アーカイブした際には、ipaファイルというアプリケーションに必要なファイルを1つのフォルダに集めてzip化し、拡張子を.ipaにしたzipファイルが生成されます。

※ ipa → iOS Package Archive

ipaファイルには、コード署名で使用したプロビジョニングプロファイルやその情報、アプリケーションのリソースファイルやアプリケーションの情報が含まれています。

<img src="../../Image/Certificate/Certificate49.png" width="80%">

このipaファイルが、DeployGateでの配信や、App Storeにリリースする際のアプリの情報の元になります。

### 11.豆知識(Tips)

#### 証明書の管理

プロビジョニングプロファイルに含まれる証明書の公開鍵はローカル上の秘密鍵とペアである必要があるため、開発メンバーが増えた際には以下のような対応が必要になります。

##### 新しく証明書を作成するパターン

1. 新しく入った開発メンバーのApple Developerアカウントを作成
2. Apple Developer Portalに新しい開発メンバー招待
3. 証明書を作成
4. DeviceID登録(新しい端末がある場合)
5. プロビジョニングプロファイルの更新(作成した証明書、端末ID追加)

<img src="../../Image/Certificate/Certificate45.png" width="80%">

##### 既存の証明書を渡すパターン

0. (新しい端末を登録する必要がある場合は端末ID登録&プロビジョニングプロファイル更新)
1. プロビジョニングプロファイルの証明書の公開鍵とペアになっているp12ファイルを渡す
2. プロビジョニングプロファイルを渡す

<img src="../../Image/Certificate/Certificate46.png" width="80%">

上記の対応を手動で行うのはとても手間がかかりますし、証明書も有効期限が1年間のため、毎年更新の作業が出てきてしまいます。

そこで、これらの証明書の作業を全て自動で解決できるようにしたのがfastlaneのmatchになります。

fastlane matchでは共有の1つの証明書を管理者が作成し、GitHubのプライベートリポジトリなどに保存することで、他の開発者が作成された証明書をコマンド1つで取得できる、かつ管理者が安全に証明書を保管することができます。

<img src="../../Image/Certificate/Certificate47.png" width="80%">

## 参考文献

[iOSアプリのプロビジョニング周りを図にしてみる](https://qiita.com/fujisan3/items/d037e3c40a0acc46f618)

[iOSアプリの証明書まわりの話をしっかりと理解する](https://zenn.dev/mhackit/scraps/355fe56dc7b4c8)

[iOSのコード署名がなんのためにどうやって行われているかを理解する](https://qiita.com/maiyama18/items/88567365dde2a3b3cc92#%E3%82%B3%E3%83%BC%E3%83%89%E7%BD%B2%E5%90%8D%E3%81%AE%E7%99%BB%E5%A0%B4%E4%BA%BA%E7%89%A9)

[iOSの証明書について](https://kumaskun.hatenablog.com/entry/2022/09/20/210919)

[Xcode と署名](https://scrapbox.io/tasuwo-ios/Xcode_%E3%81%A8%E7%BD%B2%E5%90%8D)

石田保輝・宮崎修一 (2017) アルゴリズム図鑑 照英社