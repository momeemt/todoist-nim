# Package

version       = "0.1.0"
author        = "Mutsuha Asada"
description   = "Client library for Todoist"
license       = "Apache-2.0"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.8"
requires "dotenv >= 2.0.0"
requires "jsony >= 1.1.3"
requires "uuids >= 0.1.11"
requires "fusion >= 1.2"

task docs, "Generate documents":
  exec "nimble doc --index:on --project src/todoist/sync.nim -o:docs"
