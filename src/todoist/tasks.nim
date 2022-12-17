import std/times
import std/options

type
  Task* = object
    id: string
    content: string
    description: string
    isCompleted: bool
    labels: seq[string]
    priority: range[1..4]
    due: Option[Due]
    assigneeId: Option[string]
    
    # read-only
    order: int
    projectId: string
    sectionId: Option[string]
    parentId: string
    url: string
    commentCount: int
    createdAt: DateTime
    creatorId: string
    assignerId: Option[string]
  
  Due* = object
    `string`: string
    date: DateTime
    isRecurring: bool
    dateTime: DateTime
    timezone: Timezone
