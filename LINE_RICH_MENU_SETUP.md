# LINE公式アカウント リッチメニュー設定手順

対象アカウント: **Movance**（LINE Official Account ID: `@433iwomu`）
設定方法: 以下の2通りを記載する。
- **A. LINE Official Account Manager から手動登録**（GUI操作のみ、追加実装なし）
- **B. Messaging API 経由でスクリプト実行**（`scripts/setup-line-richmenu.ps1`、実行実績あり）

いずれの方法でも、最終的にLINEアプリ上のリッチメニュー表示・タップ領域・遷移先URLは同一になる。LIFF / Mini App の実装は今回対象外。

デモURL: https://rookies2478.github.io/movance-demos/

---

## 1. 使用する画像

リポジトリ直下の以下のファイルを使用する。

```
line-richmenu-2500x1686.jpg
```

- 元データ（`ChatGPT Image 2026年9月7日 20_44_17.png`）を **LINEリッチメニュー用にサイズ・容量最適化したコピー**。デザイン・文言・構図は元画像から一切変更していない。
- 元画像（PNG）は変更・削除せず、リポジトリにそのまま残置している。Web上のチャットデモ（`index.html`）は引き続き元のPNGを表示に使用する。

### 画像仕様（検証済み）

| 項目 | 値 | LINE Official Account Managerの制限 | 判定 |
|---|---|---|---|
| 形式 | JPEG | JPEG / PNG | OK |
| サイズ（横×縦） | 2500 × 1686 px | 800〜2500 × 250〜1686 px（大サイズテンプレート標準値） | OK（LINE公式「大」テンプレートの標準寸法と完全一致） |
| アスペクト比 | 約1.483:1 | 大テンプレート標準比率 | OK |
| ファイル容量 | 約575KB（588,702 bytes） | 上限 1MB | OK（余裕あり） |
| タップ領域と画像上のカード位置 | 左1/3=予約, 中央1/3=アクセス, 右1/3=FAQ | — | OK（後述） |

**参考：元画像の状態**（このままではアップロード非推奨だった点）
- サイズ: 1536 × 1024 px（アスペクト比 1.5:1）→ LINEの標準テンプレート寸法と一致せず、テンプレート選択時に画像が引き伸ばし・トリミングされるおそれがあった。
- 容量: 約1.49MB → LINE Official Account Managerの1MB上限を超過していた。

最適化コピーは、元画像を等倍拡大（1536×1024 → 2500×1667、縦横比は完全維持）した上で、LINE「大」テンプレートの縦1686pxに合わせて上下に計19px（背景色を伸長した無地の余白）を追加し、2500×1686へ調整。文字・イラスト・写真・構図は一切変更していない。JPEG品質92で書き出し、1MB制限に対して十分な余裕（約59%）を確保した。

---

## A. LINE Official Account Manager から手動登録する方法

### A-1. テンプレート／領域設定

LINE Official Account Manager の「リッチメニュー作成」画面で以下を選択する。

1. **テンプレートを選択** → サイズ：**大（2500×1686）** を選択
2. **レイアウト（分割パターン）** → **横一列に3分割（縦フル・均等3列）** のテンプレートを選択
   - 画像自体がすでに「左・中央・右」の3枚カードを均等3分割で配置したデザインになっているため、このレイアウトを選ぶだけでタップ領域が自動的に画像上のカードと一致する。
3. 画像アップロード欄に `line-richmenu-2500x1686.jpg` をアップロードする。

---

### A-2. 左・中央・右それぞれのURL

自動生成された3つのタップ領域（左1/3・中央1/3・右1/3）に、それぞれ以下のアクション種別「URL」を設定する。

| 領域 | カード内容 | 設定するURL |
|---|---|---|
| 左（1枚目） | 空き時間を見て予約する（RESERVE） | `https://rookies2478.github.io/movance-demos/#course` |
| 中央（2枚目） | 店舗情報・アクセス（ACCESS） | `https://rookies2478.github.io/movance-demos/#access` |
| 右（3枚目） | 予約についてよくある質問（FAQ） | `https://rookies2478.github.io/movance-demos/#faq` |

※ 各URLは `index.html` 内の `#course` / `#access` / `#faq` セクションに対応しており、既存の実装・ホットスポット構成（`index.html` 内 `.hotspot.reserve` / `.hotspot.access` / `.hotspot.faqhot`、いずれも横幅33.333%均等）と一致している。

---

### A-3. 表示設定

- **メニュー名**（管理用ラベル）: 任意（例：`Movance_通常メニュー`）
- **タイトル**（トーク画面のタブ表示に使用される内部名。ユーザーには表示されない想定の項目だが必須入力）: 任意で分かりやすい名称を入力（例：`予約・アクセス・FAQ`）
- **表示期間**: 恒常的に使う場合は開始日のみ設定し、終了日は最大値（または長期）を設定
- **メニューバーのテキスト**: 例：`メニュー` または `タップして開く`
- **デフォルト表示**: 「オンに設定（トーク画面を開いたときにメニューを表示した状態にする）」を推奨
- 設定後、**「公開」** をクリックして反映する。

---

### A-4. 公開後の動作確認

1. Movance公式アカウント（`@433iwomu`）を友だち追加済みのスマートフォンでLINEアプリを開く
2. トーク画面下部にリッチメニューが表示されることを確認
3. 画像が縦横比を保った状態（引き伸ばし・トリミングされていない）で表示されていることを確認
4. **左（予約する）** をタップ → ブラウザが開き `https://rookies2478.github.io/movance-demos/#course` の「メニューを選択」画面が表示されることを確認
5. **中央（アクセス）** をタップ → `#access` の店舗情報・地図（Googleマップ埋め込み）画面が表示されることを確認
6. **右（FAQ）** をタップ → `#faq` のFAQ画面が表示されることを確認
7. スマートフォン実機（iOS / Android）それぞれでタップ領域のズレがないか確認（3領域とも均等3分割のため基本的にズレは生じない想定だが、実機確認を推奨）

---

## B. Messaging API 経由でスクリプト実行する方法

スクリプト: `scripts/setup-line-richmenu.ps1`（PowerShell、UTF-8 with BOM保存）

### B-1. スクリプトの動作内容

1. リッチメニュー作成（`POST /v2/bot/richmenu`）— サイズ2500×1686、左834px/中央833px/右833px の縦フル均等3分割、各領域のaction typeは`uri`
   - 左: `https://rookies2478.github.io/movance-demos/#course`
   - 中央: `https://rookies2478.github.io/movance-demos/#access`
   - 右: `https://rookies2478.github.io/movance-demos/#faq`
2. 画像アップロード（`POST /v2/bot/richmenu/{richMenuId}/content`）— `line-richmenu-2500x1686.jpg` をアップロード
3. デフォルトリッチメニューに設定（`POST /v2/bot/user/all/richmenu/{richMenuId}`）
4. 疎通確認（`GET /v2/bot/info`、`GET /v2/bot/richmenu/{richMenuId}`、`GET /v2/bot/user/all/richmenu`）

### B-2. Channel Access Tokenの取扱い

- 環境変数 `LINE_CHANNEL_ACCESS_TOKEN` が設定されていればそれを使用する
- 未設定の場合は実行時に `Read-Host -AsSecureString` で対話入力させる（画面には表示されない）
- トークンはファイル保存・ログ出力・Gitへのコミットを一切行わない。API呼び出し中のみメモリ上で使用し、処理終了後に変数参照を破棄する（PowerShellの文字列は不変のため完全消去の保証はできないが、可能な範囲で対応）

### B-3. 実行コマンド

対話環境（起動元PowerShell）で実行する。`Read-Host` を使うため、非対話シェル（CI等）では環境変数を必ず設定してから実行すること。

```powershell
powershell -File "scripts\setup-line-richmenu.ps1"
```

### B-4. 実行実績

2026年9月7日、Movanceアカウントに対して本スクリプトを実行し、以下の結果で成功を確認済み。

| 項目 | 結果 |
|---|---|
| displayName | Movance |
| richMenuId | `richmenu-afbf20d917fce24218c69db78d81503e` |
| 画像アップロード | success |
| デフォルト設定 | success |
| デフォルト確認 | match |
| size | 2500×1686 |
| areas | 3 |

※ `richMenuId` は実行のたびに新規発行される。上記は実行時点の記録であり、再実行時は異なるIDになる。

---

## 対象外（今回は実施しない）

- LINE Developers コンソールでの設定（チャネル自体の作成・設定変更）
- LIFF / Mini App の実装

これらは将来的に自動化・パーソナライズ（例：ユーザー属性別のリッチメニュー出し分け）が必要になった場合に別途検討する。
