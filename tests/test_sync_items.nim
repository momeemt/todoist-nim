import std/os
import std/options
import std/unittest
import std/asyncdispatch

import todoist/sync
import dotenv

if fileExists(".env"):
  load()

suite "add item":
  setup:
    var client = syncAPI(getEnv("Authorization"))

  # test "add item with default arguments":
  #   discard client.addItem("add item with default arguments")
  #   check true
  
  test "add item with all arguments":
    echo "env: ", getEnv("Authorization")
    var item = waitFor client.addItem("add item with all arguments",
                         description = some("task created using todoist-nim"),
                         priority = some(3),
                         labels = some(@["test-label1", "test-label2"])
                       )
    item = waitFor client.completeItem(item)
