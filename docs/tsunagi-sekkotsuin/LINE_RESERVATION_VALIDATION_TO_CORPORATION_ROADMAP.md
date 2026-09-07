# Revenue Loop for Clinics｜接骨院実証 → 標準Product化ロードマップ

**Status:** Canonical / 現行実行方針  
**対象:** つなぎ接骨院を起点とする接骨院・予約型ローカルサービス向けProduct  
**提供:** Movance  
**更新日:** 2026-09-08  
**Supersedes:** 本ファイル旧版「LINE予約SaaS 検証→法人化ロードマップ」

---

## 1. 結論

Movanceが検証すべき商品は、単なる「LINE予約SaaS」ではない。

> **Revenue Loop for Clinics = 患者の来院サイクル上で発生する売上機会損失（Revenue Leak）を検知し、LINEを主な顧客接点として回収する小型Vertical SaaS。**

予約機能はRevenue Loopの入口の1つであり、商品そのものではない。

初期実証では、つなぎ接骨院の実データ・実運用から、どのRevenue Leakが大きく、どのLeakなら最小の入力・連携で回収できるかを確認する。その後、別法人の接骨院で同じ仕組みが大きな個別開発なしに再現できることを確認し、標準Productとして一般販売判断を行う。

```text
2026年内
つなぎ接骨院でRevenue Leakを計測
        ↓
最重要Leak 1〜3個に絞ってMVP実装
        ↓
実運用で「回収売上 / 操作負荷 / 導入負荷」を検証
        ↓
別法人の接骨院で再現性検証
        ↓
標準化できることを確認
        ↓
2027年以降
法人化・正式販売体制
        ↓
LINE連携 / オンボーディング自動化
        ↓
接骨院 → 隣接Verticalへ展開
```

---

## 2. Product Positioning

### 売らないもの

- 高機能予約SaaS
- 電子カルテ
- 保険請求システム
- POS
- 汎用CRM
- Lステップ代替
- AIチャットボット
- 「何でもできる店舗DXプラットフォーム」

### 売るもの

> **空き枠、キャンセル、次回予約なし、離脱などの“売上漏れ”を見つけ、必要な患者だけに適切な導線を出して、予約・再来院へ戻す仕組み。**

顧客への訴求は「DX」「CRM」「AI」ではなく、次を中心にする。

- 空き枠を埋める
- キャンセル損失を減らす
- 次回予約の取りこぼしを減らす
- 離脱患者を戻す
- 営業時間外の予約機会損失を減らす

---

## 3. Revenue Leak Map

初期検証では、患者Journeyを以下のように分解する。

```text
集客
 ↓
初回予約
 ├─ 予約しない / 電話がつながらない ── LOSS 1
 ├─ キャンセル ─────────────────── LOSS 2
 └─ 来院
      ↓
    施術
      ↓
    次回予約
      ├─ あり
      └─ なし ──────────────────── LOSS 3
             ↓
       一定期間経過
             ↓
          離脱 ─────────────────── LOSS 4

予約枠
 ↓
キャンセル発生
 ↓
空き枠が埋まらない ───────────────── LOSS 5
```

MVPは、この5つ全部を作るのではなく、**実際の金額インパクトと実装難易度を見て上位1〜3個に絞る。**

---

## 4. 最重要設計原則｜カルテ統合ではなくRevenue Event取得

Revenue Loopが必要なのは医療・施術データではない。

### 原則として持たない

- 病名
- 症状詳細
- 施術内容
- 保険情報
- カルテ本文
- 詳細な身体情報

### 必要最小限として持つ候補

- tenant_id
- patient_id
- LINE userId（連携できる場合）
- 氏名 / 連絡先（必要な場合のみ）
- 予約日時
- 予約状態
- 来院状態
- キャンセル状態
- 次回予約の有無
- 最終来院日
- メッセージ同意・配信停止状態
- Revenue Loop経由の予約 / 回収イベント

つまり、既存の電子カルテや基幹システムを置き換えない。

> **「誰が、予約した / 来た / 来なかった / キャンセルした / 次回予約した」のRevenue Eventだけを取得する。**

これにより、API連携がない店舗でも導入余地を残す。

---

## 5. 最大のネックと対応方針

### Critical 1｜患者ID統合

LINE上のユーザーと院内の患者を同一人物として識別できないと、再来院や離脱判定が成立しない。

#### 方針

初回予約・初回連携時に、最低限の本人確認情報を使い、Revenue Loop側のpatient_idへ紐付ける。

```text
LINE / Web予約
   ↓
氏名・電話番号等の最小入力
   ↓
既存患者候補を照合
   ↓
Revenue Loop patient_id
   ↕
LINE userId / clinic patient reference
```

完全自動マッチングを前提にせず、曖昧一致時は人間確認へ落とす。

---

### Critical 2｜予約・来院データをどこから取るか

Revenue Loopの成否を決める最大の事業リスク。

予約や来院が紙、電話、Google Calendar、他社予約SaaS、電子カルテ等へ分散している場合、自動化が成立しない。

#### 方針

初期段階で各社SaaSへの全面API連携を行わない。

優先順位：

1. 既存データから自動取得できるEventは自動取得
2. Google Calendarで標準化できる予約EventはCalendarを活用
3. 自動取得できないEventだけ、スタッフの1〜2タップ入力で補う

例：

```text
田中 太郎

本日来院 ✓

次回予約
[ あり ] [ なし ]
```

この操作が現場で継続されない場合、Revenue Loopの状態機械が壊れるため、**入力継続率そのものをMVPの主要KPIにする。**

---

### Critical 3｜既存LINE連携との衝突

店舗が既にLステップ、L Message、予約Bot、CRM等をLINE Messaging APIへ接続している場合、Revenue Loopの接続方法によって既存運用を壊す可能性がある。

#### 方針

導入前に必ずLINE Connection Checkを行う。

```text
LINE公式アカウント
      ↓
Messaging API利用状況確認
      ↓
既存Webhook / Bot / CRM連携確認
      ↓
GREEN   : 競合なし
YELLOW  : 共存設計が必要
RED     : 初期版では非対応 / 別LINE等を提案
```

初期版で「全LINEツールとの完全共存」を目指さない。

---

### High 4｜誤配信・過剰配信

間違った患者、既に予約済みの患者、配信停止希望者へメッセージを送ると信頼を失う。

#### 方針

送信前に必ずGateを通す。

```text
Candidate
  ↓
Identity Gate
  ↓
Current Booking Gate
  ↓
Consent / Opt-out Gate
  ↓
Frequency Gate
  ↓
Message Policy Gate
  ↓
Send
```

AIが自由に判断して自動送信する構造にはしない。

---

### High 5｜法務・広告・個人情報

接骨院領域では、患者情報・施術情報・広告表現の扱いを慎重にする必要がある。

#### 方針

- Revenue Loopは診療 / 施術カルテを持たない
- 症状ベースの自動セグメントを初期版では行わない
- 「治る」「改善する」等の効能を自動生成しない
- 標準メッセージは予約・来院案内中心にする
- 必要な同意、プライバシーポリシー、利用規約、データ保持方針を販売前に整備する

---

## 6. Patient Lifecycle Engine

CRMの大量タグではなく、少数の状態で扱う。

```text
NEW
 ↓
BOOKED
 ↓
VISITED
 ├─→ NEXT_BOOKED
 └─→ NO_NEXT_BOOKING
          ↓
    RECALL_ELIGIBLE
          ↓
      RECALL_SENT
       ├──────┐
       ↓      ↓
   REBOOKED  DORMANT
```

空き枠側も状態機械として扱う。

```text
BOOKED_SLOT
   ↓ cancellation
OPEN_SLOT
   ↓ candidate match
OFFERED
   ↓ booking
RECOVERED
```

この状態遷移をRevenue LoopのCoreとする。

---

## 7. 患者側UX / 店舗側UX

### 患者側

原則として新しいアプリをインストールさせない。

```text
LINE公式アカウント
   ↓
リッチメニュー / メッセージ
   ↓
予約画面（Web / LIFF / Mini App等、実装方式は検証）
   ↓
予約完了
```

### 店舗側

「CRMを操作する」体験にはしない。

トップ画面の主語は顧客管理ではなく、**今日の売上回収機会**とする。

例：

```text
今日の回収チャンス

空き枠             2件
次回予約なし       7人
離脱候補          13人

[候補を見る]
```

予約運用は可能な限りGoogle Calendar等の既存ツールを活用し、Revenue Loop専用画面は「判断・回収・最小入力」に限定する。

---

## 8. Google Calendarの位置付け

既存の `TSUNAGI_LINE_GOOGLE_CALENDAR_RESERVATION_PROPOSAL.md` は、Revenue Loopの**予約Event取得・予約UXに関する実証仕様**として扱う。

Google Calendar連携自体を競争優位とはみなさない。

役割：

- 予約枠の可視化
- LINE/Web予約の登録
- 電話 / 店頭予約の共通台帳候補
- 二重予約防止のための空き確認

ただし、実証でGoogle Calendar運用が定着しない場合は「Google Calendarを正本にする」という仮説を捨てる。

**Revenue LoopというProduct定義はGoogle Calendarに依存させない。**

---

## 9. LINE連携方式｜法人化前 / 法人化後

### 法人化前

セルフオンボーディング完成を先に作らない。

- 予約リンク / Web画面中心で検証
- 必要に応じてMovanceがリッチメニュー等を手動設定
- Messaging API連携は店舗の既存構成を確認してから行う
- 少数実証なので手動作業を許容し、必ず作業時間を記録する

### 法人化後

実証で繰り返し発生した設定作業のみ自動化する。

目標UX：

```text
店舗登録
 ↓
LINE接続方式を診断
 ↓
「LINEと連携」
 ↓
管理者が必要な許可
 ↓
接続
 ↓
必要設定を自動生成
 ↓
利用開始
```

LINEの公式連携方式・利用条件・審査要件は、その時点の最新仕様を再確認して採用する。特定のChannel方式を今の段階で不可逆な前提にしない。

---

## 10. マルチテナント設計

2社目検証を前提に、データは最初からtenant単位で分離する。

最低限、以下へtenant_idを持たせる。

- patients
- appointments
- revenue_events
- lifecycle_states
- line_connections
- message_events
- consent / opt-out
- clinic_settings
- audit_logs

1社専用のハードコードは禁止。

---

## 11. MVP Scope

MVPを「予約機能一覧」で固定しない。

まずLeak Discoveryを行い、優先度を決める。

現時点のMVP候補：

1. LINE / Webからの予約
2. 来院Eventの記録
3. 次回予約なしの検知
4. キャンセル / 空き枠の回収
5. 再来院候補へのLINE導線

### 初期版でやらない

- 電子カルテ
- 保険請求
- POS / 決済
- 回数券
- 在庫
- 高度CRM
- AIチャット
- 自由文AI自動配信
- 高度BI
- 全予約SaaSとのAPI連携
- 全LINEマーケティングツールとの完全共存
- 大規模な自動オンボーディング

---

## 12. つなぎ接骨院で最初に取る数字

開発前 / 実証開始時に最低限、次を確認する。

1. 月間来院者数
2. 月間予約件数
3. キャンセル件数 / 率
4. No-show件数 / 率
5. 来院後に次回予約なしとなる人数 / 率
6. 30 / 60 / 90日未回来院人数
7. 平均来院単価（概算可）
8. LINE公式アカウント友だち数
9. 現在のLINE経由予約件数 / 比率
10. 現在使用中の予約・カルテ・LINEツール
11. 電話予約比率
12. 予約台帳の正本
13. 1日にスタッフが処理する予約 / 来院Event数

ここからRevenue Leakの金額を推定する。

例：

```text
次回予約なし 40人/月
× 回収可能率 20%
× 平均単価 5,000円
= 40,000円/月の回収余地
```

表示する場合は実売上と混同しないよう、**推定回収売上**と**Revenue Loop経由の確定予約件数**を分ける。

---

## 13. 実証KPI

### Revenue KPI

- Revenue Loop経由予約件数
- キャンセル枠回収件数
- 再来院件数
- 推定回収売上
- 1配信あたり予約 / 回収額

### Product KPI

- LINE→予約完了率
- 操作完了時間
- 来院Event入力率
- 次回予約状態入力率
- 誤送信件数
- 重複予約件数
- 店舗スタッフの週次操作時間

### Business KPI

- 初期導入作業時間
- 月次サポート時間
- 個別カスタマイズ時間
- 2社目での再利用率
- 月額価格に対する粗利 / サポート負荷

---

## 14. Go / No-Go Gate

### Gate A｜Revenue Leakage

店舗あたり、Revenue Loopで現実的に改善できる月間Leakが十分あること。

初期目安：**3万円/月以上**を検証ラインとする。固定基準ではなく、価格・粗利・導入負荷と合わせて判断する。

### Gate B｜Recoverable Leak

改善可能なLeakが少なくとも2種類ある、または1種類でも十分大きいこと。

### Gate C｜Data Feasibility

必要なRevenue Eventを、既存データ連携または継続可能な最小入力で取得できること。

### Gate D｜Operational Fit

追加操作が現場に定着すること。入力漏れが多く、誤配信リスクが高い場合はNo-Goまたは再設計。

### Gate E｜LINE Compatibility

既存LINE運用を壊さず導入できること。

### Gate F｜Cross-clinic Repeatability

別法人の接骨院でも、大きな個別開発なしで導入できること。

### Gate G｜Economics

月額収益に対して、初期導入・サポート・LINE設定・個別対応コストが成立すること。

---

## 15. 価格仮説

価格は機能数ではなく、Recoverable Revenueとサポートコストから決める。

初期検証では月額4,980円前後を1つの仮説として置けるが、確定価格ではない。

販売上の説明は、

> 「月額4,980円の予約システム」

ではなく、

> **「月1件程度の取りこぼしを戻せれば費用回収できる売上回収ツール」**

というPaid Reasonを検証する。

価格確定条件：

- 実際の回収件数
- 推定 / 実売上インパクト
- 継続利用率
- サポート時間
- LINE配信費等の外部コスト
- 導入作業時間

---

## 16. 法人化前→法人化後のロードマップ

### Phase 0｜Leak Discovery

つなぎ接骨院の現状数値とJourneyを取得し、最大Leakを特定。

### Phase 1｜Revenue MVP

上位1〜3 Leakだけ解く。予約機能が最重要なら、既存のLINE×Google Calendar案を使う。

### Phase 2｜Real Operation

実運用で回収売上、入力率、誤送信、サポート時間を測る。

### Phase 3｜Second Company

別法人で同じMVPを入れ、特殊仕様を除去する。

### Phase 4｜Productization

共通Coreを固定する。

```text
Revenue Loop Core
├─ Identity
├─ Appointment / Revenue Event
├─ Lifecycle
├─ Trigger
├─ Messaging
├─ Attribution
├─ Safety Gate
└─ Tenant
```

### Phase 5｜Corporation / Formal Distribution

法人化後、必要な契約・LINE連携・請求・サポート・オンボーディングを正式化する。

### Phase 6｜Vertical Expansion

接骨院でEvidenceを得た後、共通Leakが存在する業界へ横展開を検討する。

候補：

- 整体院
- 鍼灸院
- パーソナルジム
- 美容サロン
- ペットサロン

ただし、接骨院でのEvidence取得前に横展開を作り込まない。

---

## 17. 今すぐの実行順

1. つなぎ接骨院のRevenue Leak Mapをヒアリングで埋める
2. 12項目の基礎数値を取得する
3. 最大Leakを金額換算する
4. 最大Leakを解くのに必要なRevenue Eventを特定する
5. そのEventを「自動取得 / 1〜2タップ入力 / 取得不可」に分類する
6. 現在のLINE・予約・カルテ環境を棚卸しする
7. LINE Connection Checkを行う
8. 上位1〜3 LeakだけをMVP Scopeとして確定する
9. つなぎ接骨院で実運用する
10. KPIを取得して改善する
11. 別法人で再現性を確認する
12. その後に法人化後のセルフオンボーディングを作る

---

## 18. 既存資料との関係

### `TSUNAGI_LINE_GOOGLE_CALENDAR_RESERVATION_PROPOSAL.md`

Revenue Loopのうち、**予約導線 / Google Calendar利用を検証するSupporting Spec**。

「患者はLINEだけ。店舗はGoogle Calendarだけ。」というUX仮説は維持するが、Google CalendarがRevenue Loop全体の必須条件ではない。

### `LINE_RICH_MENU_SETUP.md`

現行LINE公式アカウントでのリッチメニュー設定実績。Revenue LoopのDistribution / Entry UXの実装参考として再利用する。

### `docs/LINE_OFFICIAL_ACCOUNT_DELIVERY_SOP.md`

LINE公式アカウントの導入・設定作業を標準化するためのDelivery SOPとして利用する。

---

## 19. 基本原則

> **予約機能を作ることを目的にしない。売上漏れを特定し、最小のデータ・最小の操作で回収することを目的にする。**

> **カルテを統合しない。Revenue Eventだけ取る。**

> **全部を自動化してから売らない。実際に発生した手作業だけを観測して自動化する。**

> **つなぎ接骨院専用にしない。2社目で再利用できない仕様はCoreへ入れない。**

> **AIを価値として売らない。Recovered Revenueと使いやすさを価値として売る。**

> **Evidence Before Expansion.**
