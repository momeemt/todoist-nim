import apis

import std/json
import std/times
import std/tables
import std/options
import std/httpclient

import uuids
import fusion/matching

type
  Due* = object

  Item* = object
    id: string
    userId: Option[string]
    projectId: Option[string]
    content: string
    description: string
    due: Option[Due]
    priority: int
    parentId: Option[string]
    childOrder: Option[int]
    sectionId: Option[string]
    dayOrder: int
    collapsed: bool
    labels: seq[string]
    addedByUid: Option[string]
    assignedByUid: string
    responsibleUid: Option[string]
    checked: bool
    isDeleted: bool
    syncId: Option[string]
    completedAt: Option[DateTime]
    addedAt: DateTime
  
  ItemOrder* = object
    id: string
    childOrder: string

template `??=` [T] (left: untyped, right: T): untyped =
  if Some(@v) ?= right:
    left = %*v

proc addItem* (client: HttpClient,
               content: string,
               description = none[string](),
               projectId = none[string](),
               due = none[Due](),
               priority = none[int](),
               parentId = none[string](),
               childOrder = none[int](),
               sectionId = none[string](),
               dayOrder = none[int](),
               collapsed = none[bool](),
               labels = none[seq[string]](),
               assignedByUid = none[string](),
               responsibleUid = none[string](),
               autoReminder = none[bool](),
               autoParseLabels = none[bool]()): Item =
  var client = client
  client.headers["Content-Type"] = "application/json"
  var data = newMultipartData()
  let (tempId, uuid) = ($genUUID(), $genUUID())
  var commands = %*[
    {
      "type": "item_add",
      "temp_id": tempId,
      "uuid": uuid,
      "args": {
        "content": content,
      }
    }
  ]
  commands[0]["args"]["description"] ??= description
  commands[0]["args"]["project_id"] ??= projectId
  commands[0]["args"]["due"] ??= due
  commands[0]["args"]["priority"] ??= priority
  commands[0]["args"]["parent_id"] ??= parentId
  commands[0]["args"]["child_order"] ??= childOrder
  commands[0]["args"]["section_id"] ??= sectionId
  commands[0]["args"]["day_order"] ??= dayOrder
  commands[0]["args"]["collapsed"] ??= collapsed
  commands[0]["args"]["labels"] ??= labels
  commands[0]["args"]["assigned_by_uid"] ??= assignedByUid
  commands[0]["args"]["responsible_uid"] ??= responsibleUid
  commands[0]["args"]["auto_reminder"] ??= autoReminder
  commands[0]["args"]["auto_parse_labels"] ??= autoParseLabels

  data["commands"] = $commands
  let response = client.postContent(TodoistSyncAPIUrl, multipart=data)
  let todoistRes = response.parseJson.toTodoistResult
  result = Item(
    id: todoistRes.tempIdMapping[tempId],
    content: content,
    description: description.get(""),
    projectId: projectId,
    due: due,
    priority: priority.get(1),
    parentId: parentId,
    childOrder: childOrder,
    sectionId: sectionId,
    dayOrder: dayOrder.get(-1),
    collapsed: collapsed.get(false),
    labels: labels.get(@[]),
    assignedByUid: assignedByUid.get(""),
    responsibleUid: responsibleUid,
    checked: false,
    isDeleted: false
  )

proc updateItem* (client: HttpClient,
                  id: string,
                  content = none[string](),
                  description = none[string](),
                  due = none[Due](),
                  priority = none[int](),
                  collapsed = none[bool](),
                  labels = none[seq[string]](),
                  assignedByUid = none[string](),
                  responsibleUid = none[string](),
                  dayOrder = none[int]()): TodoistResult =
  discard

proc moveItem* (client: HttpClient,
                id: string,
                parentId = none[string](),
                sectionId = none[string](),
                projectId = none[string]()): TodoistResult =
  discard

proc reorderItem* (client: HttpClient, items: seq[ItemOrder]): TodoistResult =
  discard

proc deleteItem* (client: HttpClient, item: Item): Item =
  result = item
  result.isDeleted = true
  var
    client = client
    data = newMultipartData()
  let uuid = $genUUID()
  let commands = %*[
    {
      "type": "item_delete",
      "uuid": uuid,
      "args": {
        "id": result.id
      }
    }
  ]
  data["commands"] = $commands
  let _ = client.postContent(TodoistSyncAPIUrl, multipart=data)

proc completeItem* (client: HttpClient, item: Item, dateCompleted = none[DateTime]()): Item =
  result = item
  result.checked = true
  var
    client = client
    data = newMultipartData()
  let commands = %*[
    {
      "type": "item_complete",
      "uuid": $genUUID(),
      "args": {
        "id": result.id
      }
    }
  ]
  if Some(@dateCompleted) ?= dateCompleted:
    commands[0]["args"]["date_completed"] = %*(dateCompleted.format("yyyy-MM-dd'T'HH:mm:ss'.'ffffff'Z'"))
  data["commands"] = $commands
  let _ = client.postContent(TodoistSyncAPIUrl, multipart=data)

proc uncompleteItem* (client: HttpClient, item: Item): Item =
  result = item
  result.checked = false
  var
    client = client
    data = newMultipartData()
  let commands = %*[
    {
      "type": "item_uncomplete",
      "uuid": $genUUID(),
      "args": {
        "id": result.id
      }
    }
  ]
  data["commands"] = $commands
  let _ = client.postContent(TodoistSyncAPIUrl, multipart=data)

proc updateDateCompleteItem* (client: HttpClient, id: string, due = none[Due]()): TodoistResult =
  discard

proc closeItem* (client: HttpClient, id: string): TodoistResult =
  discard

proc updateDayOrdersItem* (client: HttpClient, id: string): TodoistResult =
  discard

proc getItemInfo* (client: HttpClient, itemId: string, allData: bool = true): TodoistResult =
  discard

proc getCompletedItems* (client: HttpClient,
                         projectId: string,
                         limit: int,
                         offset: int,
                         until: string,
                         since: string,
                         annotateNotes: bool): TodoistResult =
  discard

proc quickAddItem* (client: HttpClient,
                    text: string,
                    note = none[string](),
                    reminder = none[string](),
                    autoReminder = none[bool]()): TodoistResult =
  discard

proc addItemWithoutSync* (client: HttpClient,
                          content: string,
                          description = none[string](),
                          projectId = none[string](),
                          due = none[Due](),
                          priority = none[int](),
                          parentId = none[string](),
                          childOrder = none[int](),
                          sectionId = none[string](),
                          dayOrder = none[int](),
                          collapsed = none[bool](),
                          labels = none[seq[string]](),
                          assignedByUid = none[string](),
                          responsibleUid = none[string](),
                          autoReminder = none[bool](),
                          autoParseLabels = none[bool]()): TodoistResult =
  discard
