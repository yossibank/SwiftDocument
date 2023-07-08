# Model your schema with SwiftData

## Utilizing scheme macros

* **@Attribute scheme**

``` swift
@Model
final class Trip {
    // @Attribute(.unique)
    // 名前の一意性の保証
    // 既にその名前で存在する場合、最新の値を更新する(upsert)
    // Numeric, String, UUIDなどのプリミティブな値型であれば適用可能
    @Attribute(.unique) var name: String

    var destination: String

    // @Attribute(originalName: "以前のプロパティ名")
    // プロパティ名の変更
    // 本来は新しいプロパティとして識別されるが、既存のデータをそのまま保存できる
    var start_date: Date
    @Attribute(originalName: "start_date") var startDate: Date
    var end_date: Date
    @Attribute(originalName: "end_date") var endDate: Date

    // @Relationship(.cascade)
    // 削除関係を繋ぎ合わせる(親が削除されれば、親が持っている子のデータも自動的に削除される)
    @Relationship(.cascade)
    var bucketList: [BucketListItem]? = []

    @Relationship(.cascade)
    var livingAccommodation: LivingAccommodation?

    // @Transient
    // データを永続化しない、不要なデータの永続化を回避する
    // デフォルト値の設定が必要
    @Transient
    var tripViews: Int = 0

    // ...
}
```

## Evolving schemas

* **Migrationに必要な要素**
  * VersionedSchema(以前のスキーマをカプセル化する)
  * SchemaMigrationPlan(VersionedSchemaの総順序を元に必要な移行を順番に実行する)
  * 2つの移行ステージ
    * Lightweight
      * 既存のデータをマイグレーションするためにコードを追加する必要はない
      * 日付プロパティにoriginalNameを追加したり、リレーションシップの削除ルールを変更したりする場合
    * Custom
      * 名前を一意にする場合などは、重複排除するためのカスタムマイグレーションステージを作成する必要がある

``` swift
enum SampleTripsSchemeV1: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Trip.self, BucketListItem.self, LivingAccommodation.self]
    }

    @Model
    final class Trip {
        var name: String
        var destination: String
        var start_date: Date
        var end_date: Date

        var bucketList: [BucketListItem]? = []
        var livingAccommodation: LivingAccommodation?

        // ...
    }
}

enum SampleTripsSchemeV2: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Trip.self, BucketListItem.self, LivingAccommodation.self]
    }

    @Model
    final class Trip {
        @Attribute(.unique) var name: String
        var destination: String
        var start_date: Date
        var end_date: Date

        var bucketList: [BucketListItem]? = []
        var livingAccommodation: LivingAccommodation?

        // ...
    }
}

enum SampleTripsSchemeV3: VersionedSchema {
    static var models: [any PersistentModel.Type] {
        [Trip.self, BucketListItem.self, LivingAccommodation.self]
    }

    @Model
    final class Trip {
        @Attribute(.unique) var name: String
        var destination: String
        @Attribute(originalName: "start_date") var startDate: Date
        @Attribute(originalName: "end_date") var endDate: Date

        var bucketList: [BucketListItem]? = []
        var livingAccommodation: LivingAccommodation?

        // ...
    }
}

enum SampleTripsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SampleTripsSchemaV1.self, SampleTripsSchemaV2.self, SampleTripsSchemaV3.self,]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SampleTripsSchemaV1.self,
        toVersion: SampleTripsSchemaV2.self,
        // マイグレーションする前に名前一意のための重複排除処理をする
        willMigrate: { context in
            let trips = try? context.fetch(FetchDescriptor<SampleTripsSchemaV1.Trip>())
            // De-duplicate Trip instances here...
            try? context.save()
        },
        didMigrate: nil
    )

    static let migrateV2toV3 = MigrationState.lightweight(
        fromVersion: SampleTripsSchemaV2.self,
        toVersion: SampleTripsSchemaV3.self
    )

    // ...
}

// マイグレーションの実行
struct TripsApp: App {
    let container = ModelContainer(
        for: Trip.self,
        mogrationPlan: SampleTripsMigrationPlan.self
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
```