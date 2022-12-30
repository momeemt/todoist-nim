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

func commandsData (typ, uuid: string): JsonNode =
  result = %*[
    {
      "type": typ,
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
  
  var cmds = commandsData("project_update", tempId, uuid)
  cmds[0]["args"]["name"] ??= name
  cmds[0]["args"]["color"] ??= color
  cmds[0]["args"]["collapsed"] ??= collapsed
  cmds[0]["args"]["is_favorite"] ??= isFavorite
  cmds[0]["args"]["view_style"] ??= viewStyle
  data["commands"] = $cmds

  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult

proc moveProjectInstantly* (client: HttpClient, id, parentId: string): TodoistResult =
  let (tempId, uuid) = ($genUUID(), $genUUID())
  var
    client = client
    data = newMultipartData()
    cmds = commandsData("project_move", tempId, uuid)
  cmds[0]["args"]["id"] = %*id
  cmds[0]["args"]["parent_id"] = %*parentId
  data["commands"] = $cmds

  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult

proc deleteProjectInstantly* (client: HttpClient, id: string): TodoistResult =
  let uuid = $genUUID()
  var
    client = client
    data = newMultipartData()
    cmds = commandsData("project_delete", uuid)
  cmds[0]["args"]["id"] = %*id
  data["commands"] = $cmds

  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult

proc archiveProjectInstantly* (client: HttpClient, id: string): TodoistResult =
  let uuid = $genUUID()
  var
    client = client
    data = newMultipartData()
    cmds = commandsData("project_archive", uuid)
  cmds[0]["args"]["id"] = %*id
  data["commands"] = $cmds

  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult

proc unarchiveProjectInstantly* (client: HttpClient, id: string): TodoistResult =
  let uuid = $genUUID()
  var
    client = client
    data = newMultipartData()
    cmds = commandsData("project_unarchive", uuid)
  cmds[0]["args"]["id"] = %*id
  data["commands"] = $cmds

  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  result = response.parseJson.toTodoistResult

proc reorderProjectInstantly* (client: HttpClient, id: string): TodoistResult =
  discard

proc getProjectInfo* (client: HttpClient): TodoistResult = discard
proc getProjectData* (client: HttpClient): TodoistResult = discard
proc getArchivedProjects* (client: HttpClient): TodoistResult = discard

