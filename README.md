# Lovendar

## Requirements

- Xcode 26.0.1
- Swift 6.2
- iOS 26.0

## 概要

このアプリケーションは Hack U in 東京電機大学 2025 にて作成されたアプリケーションです。
必ず Xcode をインストールして動作確認をするようにしてください。また MacOS を 26.0.1 へ更新していない場合は、必ず更新してください。

もし、Cursor や VSCode を使用して開発したい場合は、以下の拡張機能をインストールすると開発しやすいかもしれません。

- [Swift](https://marketplace.cursorapi.com/items/?itemName=sswg.swift-lang)
- [SweetPad](https://marketplace.cursorapi.com/items/?itemName=sweetpad.sweetpad)

使い方などで以下の記事が参考になるので、参照してみてください。

[【Swift】VSCodeやCursorで快適なSwift開発ライフを送りたい](https://zenn.dev/ncdc/articles/swift_sweetpad)

## 環境構築

### 1. リポジトリのクローン

```bash
git clone git@github.com:ruribou/Lovendar.git
cd Lovendar
```

### 2. Secrets の設定

アプリケーションを実行する前に、API エンドポイントの設定が必要です。

1. `Lovendar/Core/Secrets.swift.template` をコピーして `Secrets.swift` を作成

```bash
cp Lovendar/Core/Secrets.swift.template Lovendar/Core/Secrets.swift
```

2. `Lovendar/Core/Secrets.swift` を開き、実際の API URL を設定

```swift
struct Secrets {
    static let productionBaseURL = "https://your-actual-production-url.com/api"
}
```

### 3. ビルド

XCode を開き、`Lovendar.xcodeproj` を開き、`Lovendar` を選択してビルドしてください

