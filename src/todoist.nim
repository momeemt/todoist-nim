import std/json
import std/options
import std/strformat
import std/httpclient

import jsony

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

proc todoist* (token: string): HttpClient =
  result = newHttpClient()
  result.headers["Authorization"] = &"Bearer {token}"

proc projects* (client: var HttpClient): seq[Project] =
  let
    response = client.request(RestBaseUrl & "/projects", HttpGet)
    body = response.body.parseJson
  for elem in body:
    result.add ($elem).fromJson(Project)
