import std/os
import std/unittest

import todoist
import dotenv

load()

# test "projects":
#   var todoist = todoist(getEnv("Authorization"))
#   echo todoist.projects()

# test "add project":
#   var todoist = todoist(getEnv("Authorization"))
#   echo todoist.addProject("Test Project")

test "add project":
  var client = todoist(getEnv("Authorization"))
  let project = initProject(todoist.Color.MintGreen, "myProject4")
  echo client.addProject(project)