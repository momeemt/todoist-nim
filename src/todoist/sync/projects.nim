from apis import TodoistSyncAPIUrl, TodoistResult, toTodoistResult
from ../colors import Color

import std/json
import std/strutils
import std/httpclient

import uuids

type
  ViewStyleKind* {.pure.} = enum
    List = "list"
    Board = "board"

  Project* = object
    id: string
    name: string
    color: Color
    parentId: string
    childOrder: int
    collapsed: bool
    shared: bool
    isDeleted: bool
    isArchived: bool
    isFavorite: bool
    syncId: string
    indexProject: bool
    teamInbox: bool
    viewStyle: ViewStyleKind

proc addProjectInstantly* (client: HttpClient,
                  name: string,
                  color: Color = Color.Charcoal,
                  parentId: string = "",
                  childOrder: int = -1,
                  isFavorite: bool = false,
                  viewStyle: ViewStyleKind = ViewStyleKind.List): TodoistResult =
  var client = client
  client.headers["Content-Type"] = "application/json"
  var data = newMultipartData()
  var commands = %*[
    {
      "type": "project_add",
      "temp_id": $genUUID(),
      "uuid": $genUUID(),
      "args": {
        "name": name,
        "color": $color,
        "is_favorite": isFavorite,
        "view_style": $viewStyle
      }
    }
  ]
  if parentId != "":
    commands[0]["args"]["parent_id"] = %*parentId
  if childOrder >= 0:
    commands[0]["args"]["child_order"] = %*childOrder
  data["commands"] = $commands
  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult