import std/os
import std/unittest

import todoist
import dotenv

test "projects":
  load()
  echo todoist.projects(getEnv("Authorization"))