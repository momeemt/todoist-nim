from apis import TodoistSyncAPIUrl, TodoistResult, toTodoistResult
from ../colors import Color

import std/json
import std/options
import std/strutils
import std/httpclient

import uuids
import fusion/matching

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

func commandsData (typ, tempId, uuid: string): JsonNode =
  result = %*[
    {
      "type": typ,
      "temp_id": tempId,
      "uuid": uuid,
      "args": {}
    }
  ]

template `??=` [T] (left: untyped, right: T): untyped =
  if Some(@v) ?= right:
    left = %*v

proc updateProjectInstantly* (client: HttpClient,
                              id: string,
                              name = none[string](),
                              color = none[Color](),
                              collapsed = none[bool](),
                              isFavorite = none[bool](),
                              viewStyle = none[ViewStyleKind]()): TodoistResult =
  var
    client = client
    data = newMultipartData()
  let
    tempId = $genUUID()
    uuid = $genUUID()
  
  var cmds = commandsData("ptoject_update", tempId, uuid)
  cmds[0]["args"]["name"] ??= name
  cmds[0]["args"]["color"] ??= color
  cmds[0]["args"]["collapsed"] ??= collapsed
  cmds[0]["args"]["is_favorite"] ??= isFavorite
  cmds[0]["args"]["view_style"] ??= viewStyle
  data["commands"] = $cmds
  
  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult