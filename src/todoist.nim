import std/json
import std/strformat
import std/httpclient

type
  Project* = object
    id: string
    parentId: string
    order: int
    color: string
    name: string
    commentCount: int
    isShared: bool
    isFavorite: bool
    isInboxProject: bool
    isTeamInbox: bool
    url: string
    viewStyle: string

const
  RestBaseUrl* = "https://api.todoist.com/rest/v2"

proc client* (token: string): HttpClient =
  result = newHttpClient()
  result.headers["Authorization"] = &"Bearer {token}"

func to* (json: JsonNode, _: typedesc[Project]): Project =
  result.id = json["id"].getStr

  result.parentId = json["parent_id"].getStr
  result.order = json["order"].getInt
  result.color = json["color"].getStr
  result.name = json["name"].getStr
  result.commentCount = json["comment_count"].getInt
  result.isShared = json["is_shared"].getBool
  result.isFavorite = json["is_favorite"].getBool
  result.isInboxProject = json["is_inbox_project"].getBool
  result.isTeamInbox = json["is_team_inbox"].getBool
  result.url = json["url"].getStr
  result.viewStyle = json["view_style"].getStr

proc projects* (client: var HttpClient): seq[Project] =
  let
    response = client.request(RestBaseUrl & "/projects", HttpGet)
    body = response.body.parseJson
  for elem in body:
    result.add elem.to(Project)
