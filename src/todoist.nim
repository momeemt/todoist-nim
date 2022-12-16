import std/json
import std/options
import std/strformat
import std/strutils
import std/httpclient

import jsony

type
  Project* = object
    id: Option[string]
    parentId: Option[string]
    order: Option[int]
    color: Color
    name: string
    commentCount: Option[int]
    isShared: Option[bool]
    isFavorite: bool
    isInboxProject: Option[bool]
    isTeamInbox: Option[bool]
    url: Option[string]
    viewStyle: Option[string]
  
  Color* {.pure.} = enum
    BerryRed = "berry_red"
    Red = "red"
    Orange = "orange"
    Yellow = "yellow"
    OliveGreen = "olive_green"
    LimeGreen = "lime_green"
    Green = "green"
    MintGreen = "mint_green"
    Teal = "teal"
    SkyBlue = "sky_blue"
    LightBlue = "light_blue"
    Blue = "blue"
    Grape = "grape"
    Violet = "violet"
    Lavender = "lavender"
    Magenta = "magenta"
    Salmon = "salmon"
    Charcoal = "charcoal"
    Grey = "grey"
    Taupe = "taupe"

const
  RestBaseUrl* = "https://api.todoist.com/rest/v2"

proc enumHook* (v: string): Color =
  result = parseEnum[Color](v)

proc todoist* (token: string): HttpClient =
  result = newHttpClient()
  result.headers["Authorization"] = &"Bearer {token}"

func initProject* (color: Color, name: string, isFavorite: bool = false): Project =
  result = Project(
    color: color,
    name: name,
    isFavorite: isFavorite,
  )

proc projects* (client: HttpClient): seq[Project] =
  let
    response = client.request(RestBaseUrl & "/projects", HttpGet)
    body = response.body.parseJson
  for elem in body:
    result.add ($elem).fromJson(Project)

proc addProject* (client: HttpClient, project: Project): Project =
  var client = client
  client.headers["Content-Type"] = "application/json"
  let response = client.request(RestBaseUrl & "/projects", HttpPost, project.toJson)
  result = response.body.fromJson(Project)
