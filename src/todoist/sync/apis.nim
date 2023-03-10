import std/json
import std/tables
import std/strformat
import std/httpclient

type
  SyncStatus* = object

  TodoistResult* = object
    fullSync: bool
    syncStatus: Table[string, SyncStatus]
    syncToken: string
    tempIdMapping*: Table[string, string]

const TodoistSyncAPIUrl* = "https://api.todoist.com/sync/v9/sync"

proc syncAPI* (token: string): AsyncHttpClient =
  result = newAsyncHttpClient()
  result.headers["Authorization"] = &"Bearer {token}"
  result.headers["Content-Type"] = "application/json"

func toTodoistResult* (res: JsonNode): TodoistResult =
  result = TodoistResult()
  result.fullSync = res["full_sync"].getBool
  for (key, value) in res["sync_status"].pairs:
    result.syncStatus[key] = SyncStatus() #value.getStr
  result.syncToken = res["sync_token"].getStr
  for (key, value) in res["temp_id_mapping"].pairs:
    result.tempIdMapping[key] = value.getStr