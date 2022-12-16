import std/os
import std/unittest

import todoist
import dotenv

test "projects":
  load()
  var todoist = todoist(getEnv("Authorization"))
  echo todoist.projects()