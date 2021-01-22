const String loadChats="""
query loadChats {
  data: chats(filter: {active: true}) {
    edges {
      node {
        ...ChatFragment
        ...ChatMessagesFragment
      }
    }
  }
}

fragment ChatFragment on IChat {
  id
  __typename
  sort
  pinned
  hidden
  notification
  notification_disabled_till
  created_at
  attached_files {
    edges {
      node {
        ...FileFragment
      }
    }
  }
  users_ids: users {
    edges {
      node {
        id
      }
    }
  }
  check_status {
    ...CheckStatusFragment
  }
  todos {
    edges {
      node {
        ...TodoFragment
      }
    }
  }
  favorite_count_id: favorite_messages {
    id: count
  }
  ... on Chat {
    title
    caption
    state
    creator_id: creator {
      id
    }
    issue_id: issue {
      id
    }
    image {
      ...FileFragment
    }
  }
  ... on PrivateChat {
    other_id: another_user {
      id
    }
  }
}

fragment ChatMessagesFragment on IChat {
  messages(first: 1) {
    ...MessagesListFragment
  }
}

fragment FileFragment on IFile {
  id
  content_length
  content_type
  key
  meta {
    width
    height
  }
  timestamp
  url
  ... on AttachedFile {
    file_name
    type
    attached_to_id: attached_to {
      id
    }
  }
  ... on MessageFile {
    file_name
    type
    message {
      chat_id: chat {
        id
      }
    }
  }
  ... on ChatImage {
    image_of_id: image_of_chat {
      id
    }
  }
  ... on UserImage {
    avatar_of_id: avatar_of {
      id
    }
  }
}

fragment CheckStatusFragment on CheckStatus {
  chat_id: chat {
    id
  }
  my_last_viewed
  last_viewed
  unread_count: unread_messages_count
  mentioned
}

fragment TodoFragment on Todo {
  id
  created_at
  state
  title
  start_date
  end_date
  caption
  chat_id: chat {
    id
  }
  sort
}

fragment MessagesListFragment on IChatMessageConnection {
  page_info: pageInfo {
    ...PageInfoFragment
  }
  edges {
    bookmark
    node_extended: node {
      ...MessageFragment
    }
  }
}

fragment PageInfoFragment on PageInfo {
  startCursor
  endCursor
  hasNextPage
  hasPreviousPage
}

fragment MessageFragment on IMessage {
  ...QuotedMessageFragment
  ... on RegularMessage {
    quoted: quoted_message {
      __typename
      ... on IMessage {
        ...QuotedMessageFragment
      }
    }
  }
  ... on FileMessage {
    quoted: quoted_message {
      __typename
      ... on IMessage {
        ...QuotedMessageFragment
      }
    }
  }
  ... on NotificationMessage {
    notification: data {
      ...NotificationElementFragment
    }
  }
}

fragment QuotedMessageFragment on IMessage {
  id
  __typename
  timestamp
  user_id: user {
    id
  }
  chat_id: chat {
    id
  }
  is_my
  order
  is_favorite
  ... on RegularMessage {
    message
    links {
      ...LinkInfoFragment
    }
    edited
    mentioned_users {
      edges {
        node {
          id
          profile {
            first_name
            last_name
          }
        }
      }
    }
  }
  ... on FileMessage {
    file {
      ...FileFragment
    }
  }
}

fragment NotificationElementFragment on INotificationText {
  __typename
  text
}

fragment LinkInfoFragment on LinkInfo {
  author
  date
  description
  _image: image
  lang
  logo
  publisher
  title
  url
  video
  error
  pending
  _message: message {
    id
    timestamp
    user {
      is_my
      profile {
        first_name
      }
    }
  }
}""";

