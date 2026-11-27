# 0424 App Edge Functions

Base URL:

```text
https://qxauaoytegxmrmtxdjqk.supabase.co/functions/v1
```

通用 Header:

```http
Authorization: Bearer <supabase_access_token>
Content-Type: application/json
```

注意：

- 除特別標註「不需登入」外，其餘 API 都需要 Supabase user access token。
- 回傳格式通常為 `{ "data": ... }`。

## 1. 啟動彈窗廣告

`GET /startup-popups?limit=10`

不需登入。

用途：

- App 一開始進入時顯示彈窗廣告。
- 內容可放註冊送什麼、訂閱每月一杯 shot、活動導流等。

Query Params:

- `limit`: 可選，預設 `10`，最大 `20`

Response:

```json
{
  "data": [
    {
      "id": 1,
      "title": "註冊禮",
      "subtitle": "新會員限定",
      "content": "註冊完成即送迎賓優惠",
      "image_url": "https://example.com/popup.jpg",
      "target_url": "https://example.com",
      "cta_text": "立即查看",
      "cta_action": "open_url",
      "cta_target": "https://example.com",
      "placement": "startup_popup",
      "sort_order": 1,
      "starts_at": null,
      "ends_at": null,
      "created_at": "2026-04-24T00:00:00.000Z"
    }
  ]
}
```

## 2. 糾團搜尋

`GET /search-group-activities?q=酒&limit=20&page=1`

不需登入。

用途：

- 搜尋一般使用者建立的糾團活動。
- 查詢來源為 `activities`。

Query Params:

- `q`: 搜尋文字，可搜尋標題、描述、地點
- `limit`: 可選，預設 `20`，最大 `100`
- `page`: 可選，預設 `1`
- `include_closed`: 可選，預設 `false`；`true` 時包含已關閉或過期資料

Response:

```json
{
  "data": [
    {
      "id": 12,
      "host_id": "user-uuid",
      "title": "週五酒吧團",
      "description": "一起喝一杯",
      "image_url": "https://example.com/activity.jpg",
      "location": "台北市",
      "map_data": null,
      "start_time": "2026-05-01T12:00:00.000Z",
      "max_participants": 6,
      "status": "open",
      "remarks": null,
      "created_at": "2026-04-24T00:00:00.000Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 20
}
```

## 3. 活動搜尋

`GET /search-activities?q=酒&limit=20`

不需登入。

用途：

- 搜尋 App 內活動。
- 同時查一般糾團 `activities` 和商家活動 `merchant_activities`。

Query Params:

- `q`: 搜尋文字，可搜尋標題、描述、地點
- `type`: 可選，`activity` / `merchant_activity`；不帶時搜尋全部
- `limit`: 可選，預設 `20`，最大 `100`
- `include_closed`: 可選，預設 `false`

Response:

```json
{
  "data": [
    {
      "id": 12,
      "type": "activity",
      "title": "週五酒吧團",
      "description": "一起喝一杯",
      "image_url": "https://example.com/activity.jpg",
      "location": "台北市",
      "map_data": null,
      "start_time": "2026-05-01T12:00:00.000Z",
      "max_participants": 6,
      "status": "open",
      "remarks": null,
      "created_at": "2026-04-24T00:00:00.000Z"
    },
    {
      "id": 88,
      "type": "merchant_activity",
      "merchant_id": "merchant-uuid",
      "title": "微醺之夜",
      "description": "商家活動",
      "image_url": "https://example.com/merchant-activity.jpg",
      "location": "台北市",
      "map_data": null,
      "start_time": "2026-05-02T12:00:00.000Z",
      "max_participants": 20,
      "status": "open",
      "remarks": null,
      "created_at": "2026-04-24T00:00:00.000Z"
    }
  ]
}
```

## 4. 地點搜尋

`GET /search-locations?q=台北&limit=20`

不需登入。

用途：

- 搜尋活動地點。
- 來源包含一般糾團和商家活動。
- 會依 `location` 去重。

Query Params:

- `q`: 搜尋文字，可搜尋地點、活動標題
- `type`: 可選，`activity` / `merchant_activity`；不帶時搜尋全部
- `limit`: 可選，預設 `20`，最大 `100`
- `include_closed`: 可選，預設 `false`
- `only_with_map`: 可選，`true` 時只回傳有 `map_data` 的地點

Response:

```json
{
  "data": [
    {
      "location": "台北市",
      "map_data": null,
      "first_activity_id": 12,
      "first_activity_type": "activity",
      "title": "週五酒吧團",
      "start_time": "2026-05-01T12:00:00.000Z",
      "image_url": "https://example.com/activity.jpg",
      "merchant_id": null
    }
  ]
}
```

## 5. 搜尋聊天對象

`GET /search-chat-users?q=王&limit=20`

需要登入。

用途：

- 搜尋可以聊天的使用者。
- 不會回傳目前登入者自己。

Query Params:

- `q`: 必填，搜尋 `nickname`、`full_name`、`email`
- `limit`: 可選，預設 `20`，最大 `100`

Response:

```json
{
  "data": [
    {
      "id": "user-uuid",
      "display_name": "王小明",
      "avatar_url": "https://example.com/avatar.jpg",
      "full_name": "王小明",
      "nickname": "小明",
      "role": "user",
      "vip_level": 0
    }
  ]
}
```

## 6. 建立或取得聊天室

`POST /chat-rooms`

需要登入。

用途：

- 依活動建立或取得聊天室。
- 同一個 `activity_type + activity_id` 只會有一間聊天室。

Request Body:

```json
{
  "activity_type": "activity",
  "activity_id": 12
}
```

`activity_type` 可用：

- `activity`
- `merchant_activity`

Response:

```json
{
  "data": {
    "id": 8,
    "activity_type": "activity",
    "activity_id": 12,
    "title": "週五酒吧團 聊天室",
    "merchant_id": null,
    "created_by": "user-uuid",
    "room_close_at": "2026-05-04T12:00:00.000Z",
    "created_at": "2026-04-24T00:00:00.000Z",
    "updated_at": "2026-04-24T00:00:00.000Z",
    "is_closed": false
  }
}
```

## 7. 我的聊天室列表

`GET /get-my-chat-rooms`

需要登入。

用途：

- 取得目前登入者相關的聊天室列表。
- App 聊天列表使用。

Response:

```json
{
  "data": [
    {
      "id": 8,
      "activity_type": "activity",
      "activity_id": 12,
      "merchant_id": null,
      "title": "週五酒吧團 聊天室",
      "created_by": "user-uuid",
      "created_at": "2026-04-24T00:00:00.000Z",
      "room_close_at": "2026-05-04T12:00:00.000Z",
      "updated_at": "2026-04-24T09:00:00.000Z",
      "is_closed": false,
      "display_name": "王小明",
      "display_avatar_url": "https://example.com/avatar.jpg",
      "unread_count": 3,
      "last_message": "我大概 10 分鐘後到",
      "last_message_preview": "我大概 10 分鐘後到",
      "last_message_type": "text",
      "last_message_at": "2026-04-24T09:00:00.000Z",
      "last_sender_id": "user-uuid",
      "pinned": false,
      "muted": false,
      "last_read_at": "2026-04-24T09:10:00.000Z"
    }
  ]
}
```

重點欄位：

- `display_name`: 聊天列表顯示名稱
- `display_avatar_url`: 聊天列表頭像
- `unread_count`: 未讀數
- `last_message_preview`: 最後一則摘要
- `last_message_type`: `text` / `image` / `system`
- `pinned`: 是否置頂
- `muted`: 是否靜音
- `updated_at`: 排序時間
- `last_read_at`: 已讀輔助時間

## 8. 聊天室訊息

`GET /chat-messages?room_id=8&limit=50`

需要登入。

支援往前分頁：

`GET /chat-messages?room_id=8&before_message_id=36&limit=50`

Query Params:

- `room_id`: 必填
- `limit`: 可選，預設 `50`，最大 `200`
- `before_message_id`: 可選，取得指定訊息之前的更舊訊息

Response:

```json
{
  "data": [
    {
      "id": 36,
      "room_id": 8,
      "sender_id": "user-uuid",
      "sender_name": "Peter",
      "sender_avatar_url": "https://example.com/avatar.jpg",
      "message": "hello",
      "message_type": "text",
      "image_url": null,
      "is_deleted": false,
      "is_recalled": false,
      "deleted_at": null,
      "status": "sent",
      "read_at": null,
      "reply_to_message_id": null,
      "client_id": "client-message-id",
      "created_at": "2026-04-24T09:00:00.000Z"
    }
  ]
}
```

重點欄位：

- `sender_name`: 泡泡旁顯示名字
- `sender_avatar_url`: 泡泡旁顯示頭像
- `message_type`: `text` / `image` / `system`
- `image_url`: 圖片訊息 URL
- `reply_to_message_id`: 回覆某則訊息
- `is_recalled`: 是否收回
- `deleted_at`: 刪除時間
- `status`: `sent` / `delivered` / `read`
- `read_at`: 已讀時間
- `client_id`: 前端 optimistic update 對帳用

## 9. 發送聊天室訊息

`POST /chat-messages`

需要登入。

文字訊息 Request Body:

```json
{
  "room_id": 8,
  "message": "hello",
  "message_type": "text",
  "client_id": "client-message-id"
}
```

圖片訊息 Request Body:

```json
{
  "room_id": 8,
  "message_type": "image",
  "image_url": "https://example.com/photo.jpg",
  "client_id": "client-image-id"
}
```

Response:

```json
{
  "data": {
    "id": 36,
    "room_id": 8,
    "sender_id": "user-uuid",
    "sender_name": "Peter",
    "sender_avatar_url": "https://example.com/avatar.jpg",
    "message": "hello",
    "message_type": "text",
    "image_url": null,
    "is_deleted": false,
    "is_recalled": false,
    "deleted_at": null,
    "status": "sent",
    "read_at": null,
    "reply_to_message_id": null,
    "client_id": "client-message-id",
    "created_at": "2026-04-24T09:00:00.000Z"
  }
}
```

## 10. 更新已讀

`POST /chat-rooms/read`

需要登入。

Request Body:

```json
{
  "room_id": 8,
  "last_read_message_id": 36
}
```

Response:

```json
{
  "data": {
    "room_id": 8,
    "user_id": "user-uuid",
    "last_read_message_id": 36,
    "last_read_at": "2026-04-24T09:10:00.000Z",
    "pinned": false,
    "muted": false
  }
}
```

用途：

- 更新使用者在聊天室最後已讀訊息。
- 讓 `get-my-chat-rooms` 的 `unread_count` 正常計算。

## 11. 搜尋聊天室

`GET /search-chat-rooms?q=王`

需要登入。

用途：

- 搜尋目前登入者可看到的聊天室。
- 搜尋範圍包含聊天室顯示名稱、聊天室標題、最後訊息摘要。

Response:

```json
{
  "data": [
    {
      "id": 8,
      "activity_type": "activity",
      "activity_id": 12,
      "title": "週五酒吧團 聊天室",
      "display_name": "王小明",
      "display_avatar_url": "https://example.com/avatar.jpg",
      "unread_count": 0,
      "last_message_preview": "hello",
      "last_message_type": "text",
      "last_message_at": "2026-04-24T09:00:00.000Z",
      "pinned": false,
      "muted": false,
      "updated_at": "2026-04-24T09:00:00.000Z",
      "last_read_at": "2026-04-24T09:10:00.000Z",
      "is_closed": false
    }
  ]
}
```

## 12. 搜尋聊天室訊息

`GET /search-chat-messages?room_id=8&q=abc&limit=50`

需要登入。

支援往前分頁：

`GET /search-chat-messages?room_id=8&q=abc&before_message_id=36&limit=50`

Query Params:

- `room_id`: 必填
- `q`: 必填，搜尋訊息內容
- `limit`: 可選，預設 `50`，最大 `100`
- `before_message_id`: 可選，取得指定訊息之前的搜尋結果

Response:

```json
{
  "data": [
    {
      "id": 36,
      "room_id": 8,
      "sender_id": "user-uuid",
      "sender_name": "Peter",
      "sender_avatar_url": "https://example.com/avatar.jpg",
      "message": "abc test",
      "message_type": "text",
      "image_url": null,
      "is_deleted": false,
      "is_recalled": false,
      "deleted_at": null,
      "status": "sent",
      "read_at": null,
      "reply_to_message_id": null,
      "client_id": "client-message-id",
      "created_at": "2026-04-24T09:00:00.000Z"
    }
  ]
}
```

## 13. 完整註冊流程

`POST /complete-registration`

需要登入。

用途：

- 完成註冊資料補齊。
- 更新 auth user 的 email / password。
- 更新 `profiles` 的基本資料。

Request Body:

```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "王小明",
  "nickname": "小明",
  "birthday": "1995-01-01",
  "gender": "male"
}
```

Response:

```json
{
  "message": "Registration completed successfully"
}
```

## 線上驗證紀錄

使用測試帳號 `test@gmail.com` 實際登入後驗證：

- `startup-popups`: 回傳 `data` array，當時線上 0 筆
- `get-my-chat-rooms`: 回傳 4 筆，必要欄位與型別正確
- `chat-messages`: room `8` 回傳 1 筆，必要欄位與型別正確
- `chat-rooms/read`: 使用 message `36` 更新已讀成功
- `search-chat-users`: 回傳 5 筆，必要欄位與型別正確
- `search-locations`: 回傳 4 筆，必要欄位與型別正確
- `search-chat-rooms`: 回傳 0 筆，`data` array 正確
- `search-chat-messages`: 回傳 0 筆，`data` array 正確
- `search-activities`: 回傳 0 筆，`data` array 正確
- `search-group-activities`: 回傳 0 筆，`data / total / page / limit` 正確
