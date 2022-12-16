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

proc projects* (token: string): seq[Project] =
  var client = newHttpClient()
  client.headers["Authorization"] = &"Bearer {token}"
  let
    response = client.request(RestBaseUrl & "/projects", HttpGet)
    body = response.body.parseJson
  for elem in body:
    result.add Project(
      id: elem["id"].getStr,
      parentId: elem["parent_id"].getStr,
      order: elem["order"].getInt,
      color: elem["color"].getStr,
      name: elem["name"].getStr,
      commentCount: elem["comment_count"].getInt,
      isShared: elem["is_shared"].getBool,
      isFavorite: elem["is_favorite"].getBool,
      isInboxProject: elem["is_inbox_project"].getBool,
      isTeamInbox: elem["is_team_inbox"].getBool,
      url: elem["url"].getStr,
      viewStyle: elem["view_style"].getStr
    )
