# LINE公式アカウント構築・納品 標準作業手順書（SOP）

**用途:** 今後、Movanceが業務委託・受託案件でLINE公式アカウントの予約導線／リッチメニューを構築する際の標準手順。

**適用範囲:** LINE公式アカウント作成、Messaging API有効化、リッチメニュー制作・登録、外部Web予約導線への接続、実機確認、納品・引継ぎ。

**対象外:** LIFF / LINE Mini App / Webhook Bot / CRM連携 / 決済 / 本格的な予約DB。必要な案件のみ別設計とする。

---

## 1. 基本方針

1. 顧客ごとに別実装を増やさず、**共通コード + 顧客設定差し替え**を原則とする。
2. LINEは顧客接点のフロントとして使い、予約・FAQ・アクセス等のWeb画面へ遷移させる。
3. リッチメニューはできる限り共通テンプレート化し、変更点を「画像・URL・店舗情報」に限定する。
4. Channel Access Token / Channel Secret 等の秘密情報をGit、ソースコード、ドキュメント、チャットログへ保存しない。
5. LINE設定・画像仕様・URL・実行スクリプト・検証結果はGitを正本として残す。
6. 初回導入は手動でもよいが、繰り返し作業はMessaging APIスクリプトで再現可能にする。

---

## 2. 案件開始前に顧客から受領する情報

### 必須

- LINE公式アカウント名
- 管理者／担当者名
- 登録用メールアドレス
- 事業者名
- 業種
- 店舗名
- 店舗住所
- 電話番号
- 営業時間／休業日
- Google Maps掲載先または正式住所
- リッチメニューから遷移させるURL
- ロゴ、ブランドカラー、使用可能な写真・画像

### 予約導線を作る場合

- 予約メニュー／コース
- 所要時間
- 担当者／指名有無
- 営業日・予約可能時間
- 当日予約可否
- 予約変更／キャンセル方法
- 電話予約を残すか
- FAQ

### 権利・公開確認

- 店名・ロゴ・写真を公開デモ／本番で使用してよいか
- 画像・ブランド素材の使用許可
- デモの場合、実在店舗と誤認されない注記が必要か

---

## 3. LINE公式アカウント作成

1. LINE Official Account Managerを開く。
2. Business ID登録・本人確認を行う。
3. LINE公式アカウントを作成する。
4. アカウント名、会社・事業者情報、業種、利用目的を登録する。
5. 未認証アカウントでも通常のリッチメニュー・Messaging API連携は進められる。認証申請が必要な案件では、事業者情報・必要書類が整ってから別途申請する。

### 推奨命名

- LINE公式アカウント: 顧客ブランド／店舗名
- LINE Developers Provider: 顧客ブランドまたは案件単位の名称

プロバイダー連携は後から扱いづらいため、案件開始時に命名・所有主体を確認する。

---

## 4. Messaging API有効化

1. LINE Official Account ManagerからMessaging API利用を開始する。
2. LINE Developersの開発者情報を登録する。
3. 対象プロバイダーを選択／作成する。
4. LINE公式アカウントとMessaging APIチャネルを連携する。
5. Channel ID / Channel Secret / Channel Access Tokenを確認する。

### 秘密情報ルール

- **Channel Access TokenはGitに保存しない。**
- **Channel SecretはGitに保存しない。**
- プロンプトやREADMEへ実値を書かない。
- API実行時のみ環境変数または非表示入力を使用する。
- 受託案件終了後は、必要に応じてトークン再発行・権限移管を行う。

今回のMovance実装では、`scripts/setup-line-richmenu.ps1` が以下の順でトークンを取得する。

1. `LINE_CHANNEL_ACCESS_TOKEN` 環境変数
2. 未設定なら `Read-Host -AsSecureString` による対話入力

---

## 5. リッチメニュー設計

### 標準構成例

3分割の場合:

- 左: 予約
- 中央: 店舗情報・アクセス
- 右: FAQ

Movanceデモでは次のURLを利用している。

- 予約: `https://rookies2478.github.io/movance-demos/#course`
- アクセス: `https://rookies2478.github.io/movance-demos/#access`
- FAQ: `https://rookies2478.github.io/movance-demos/#faq`

顧客案件では上記をその案件の本番URLへ差し替える。

### 画像

現在の検証済み標準画像:

- `line-richmenu-2500x1686.jpg`
- 2500 × 1686 px
- JPEG
- 約575KB
- 横3分割

元画像は別保存し、LINEアップロード用に最適化したコピーを使用する。

### タップ領域

2500 × 1686 の横3分割:

- 左: x=0, y=0, width=834, height=1686
- 中央: x=834, y=0, width=833, height=1686
- 右: x=1667, y=0, width=833, height=1686

画像上のカード位置とAPI側のタップ領域が一致していることを必ず確認する。

---

## 6. Messaging APIによる自動登録

標準スクリプト:

```text
scripts/setup-line-richmenu.ps1
```

実行内容:

1. 画像存在確認
2. リッチメニュー作成
3. 画像アップロード
4. デフォルトリッチメニュー設定
5. Bot疎通確認
6. 登録済みリッチメニュー確認
7. デフォルトリッチメニュー一致確認

### 実行

Windows PowerShellの対話環境でリポジトリルートから実行する。

```powershell
powershell -File ".\scripts\setup-line-richmenu.ps1"
```

環境変数が未設定ならChannel Access Token入力が求められる。入力は画面非表示。

### 非対話環境

Claude Code等の非対話シェルでは `Read-Host` がEOFになる場合がある。その場合、対話可能なローカルPowerShellで実行するか、実行プロセスに安全な方法で環境変数を渡す。

---

## 7. 実機受入テスト

設定完了後、必ずスマートフォンのLINEアプリから検証する。

### 必須確認

- LINE公式アカウントを友だち追加できる
- トーク画面でリッチメニューが表示される
- リッチメニュー画像が切れていない／伸びていない
- 左領域が予約画面へ遷移する
- 中央領域がアクセス画面へ遷移する
- 右領域がFAQへ遷移する
- タップ領域にズレがない
- 戻る操作が不自然でない
- FAQ文言が本番運用と一致する
- 電話番号、住所、営業時間が正式情報になっている
- Google Mapsが正しい店舗を示している
- デモの場合は実予約が発生しないことが明示されている

可能ならiOS / Android両方で確認する。

---

## 8. 納品時チェックリスト

### Git

- [ ] 正式画像がGitに保存されている
- [ ] リッチメニュー設定手順がGitにある
- [ ] API設定スクリプトがGitにある
- [ ] 秘密情報がcommitされていない
- [ ] 不要な一時ファイルがない
- [ ] git statusがclean
- [ ] 最終commit / push済み

### LINE

- [ ] 正しい公式アカウントへ設定した
- [ ] デフォルトリッチメニューになっている
- [ ] 各リンクが本番URL
- [ ] 実機確認済み
- [ ] 顧客側管理者がログイン・運用できる

### 顧客引継ぎ

- [ ] LINE Official Account Managerの管理主体を確認
- [ ] LINE Developers Providerの管理主体を確認
- [ ] 秘密情報の保管方法を顧客と合意
- [ ] FAQ・店舗情報の更新担当を決める
- [ ] 問い合わせ時の連絡先を決める

---

## 9. 今回発生したトラブルと標準対応

### 9.1 リッチメニュー画像が1MB超過

**症状:** 元画像がLINEアップロード上限を超える。

**対応:** 元画像を残したまま、LINE用JPEGコピーを作成し、サイズ・容量を最適化する。デザイン・文字・構図を勝手に変更しない。

### 9.2 画像サイズ／比率が標準テンプレートと合わない

**症状:** 伸縮・トリミングの可能性。

**対応:** LINEテンプレートに合わせた寸法へ調整し、必要なら背景余白で補正する。カード本体の比率は崩さない。

### 9.3 Windows PowerShell 5.1で日本語が文字化けしてParserError

**症状:** スクリプト内の日本語が文字化けし、クォート構造まで壊れる。

**対応:** 

- PowerShellスクリプトはUTF-8 with BOMで保存する。
- API内部名・label・console outputは可能ならASCIIにする。
- Windows PowerShell 5.1とPowerShell 7の両方で構文チェックする。

### 9.4 Claude Codeのシェルに環境変数が継承されない

**症状:** 起動元PowerShellで設定した `LINE_CHANNEL_ACCESS_TOKEN` をClaude Code側プロセスから参照できない。

**対応:** 秘密情報をClaude Codeのチャットへ貼らない。非対話プロセスで安全に渡せない場合、スクリプトを対話可能な起動元PowerShellで直接実行する。

### 9.5 非対話シェルでRead-Hostが使えない

**症状:** 入力待ちにならずEOFで終了。

**対応:** 対話PowerShellで実行する。CIで使う場合はシークレットストア等から環境変数として注入する。

### 9.6 APIは成功したが実機で違う画面が開く

**確認順:** 

1. APIに設定したURI
2. リッチメニューのタップ座標
3. Web側のアンカー／ルーティング
4. GitHub Pages等の公開反映
5. LINEアプリの表示更新

---

## 10. Movanceでの検証実績

2026-09-07、Movance LINE公式アカウントでMessaging API経由の登録を実施し、以下を確認済み。

- Bot displayName: `Movance`
- rich menu name: `Movance Reservation Demo`
- size: 2500 × 1686
- areas: 3
- image upload: success
- default rich menu setting: success
- default verification: match
- 実機LINEで表示・3導線を確認済み

実行時のrichMenuIdは認証情報ではないが、環境ごとに変わるため、再利用ロジックで固定値として扱わない。

---

## 11. 再利用時に案件ごとに差し替えるもの

原則として以下だけを案件変数にする。

- LINE公式アカウント／プロバイダー
- Channel Access Token
- リッチメニュー画像
- リッチメニュー名
- chat bar text
- タップ領域数・座標
- 各遷移先URL
- 店舗名
- 住所
- 電話番号
- 営業時間
- メニュー／コース
- FAQ
- Google Maps情報

それ以外の実行手順・秘密情報ルール・検証フローは共通化する。

---

## 12. 関連ファイル

- `LINE_RICH_MENU_SETUP.md` — Movanceデモ固有の設定値・GUI／API手順
- `scripts/setup-line-richmenu.ps1` — Messaging API自動登録スクリプト
- `line-richmenu-2500x1686.jpg` — LINE用最適化画像
- `index.html` — Movance予約デモ

---

## 13. 改訂ルール

このSOPは、案件で新しい失敗・制約・効率化手法が見つかった場合に更新する。

更新時は次の2分類で追記する。

- **共通パターン:** 他案件にも適用できる一般ルール
- **案件固有:** 特定顧客／特定構成だけに必要な注意点

同じ失敗を繰り返さないことを最優先とし、単なる作業ログではなく、次回の再現性・安全性・作業時間短縮につながる形で残す。
