String flowQuery = """
  query Chats{
  set
  chats{
    pageInfo{
      startCursor
    }
  }
  }
""";