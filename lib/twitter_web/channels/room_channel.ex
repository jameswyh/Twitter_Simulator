defmodule TwitterWeb.RoomChannel do
  use Phoenix.Channel
  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end
  def join(_room, _params, _socket) do
    {:error, %{reason: "you can only join the lobby"}}
  end

  def handle_in("registerUser", %{"body" => body}, socket) do
    user = socket.assigns[:username]
    if user != nil do
      push socket, "new_msg", %{body: "Error: You have already registered!"}
      {:noreply, socket}
    else
      content = body |> String.trim()
      list = String.split(content, " ", trim: true)
      [username, password] =
        if length(list) == 2 do
          list
        else
          [nil, nil]
        end
      {_, success} =
        if username != nil do
          GenServer.call(:Server, {:registerUser, username, password, self()})
        else
          {"null", false}
        end
      socket =
        if success do
          assign(socket, :username, username)
        else
          socket
        end
      result =
        if success do
          "#{username} registered successfully!"
        else
          if username == nil do
            "Error: Please input username and password with space in between!"
          else
            "Error: #{username} exists!"
          end
        end
      push socket, "new_msg", %{body: result}
      {:noreply, socket}
    end
  end

  def handle_in("deleteUser", %{"body" => body}, socket) do
    username = socket.assigns[:username]
    password = body |> String.trim()
    {_, success} = GenServer.call(:Server, {:deleteUser, username, password})
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        if success do
          "#{username} deleted successfully!"
        else
          "Error: Wrong Password!"
        end
      end
    socket =
      if success do
        assign(socket, :username, nil)
      else
        socket
      end
    push socket, "new_msg", %{body: result}
    {:noreply, socket}
  end

  def handle_in("tweet", %{"body" => body}, socket) do
    username = socket.assigns[:username]
    tweet = body |> String.trim()
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        GenServer.call(:Server, {:sendTweet, username, tweet})
        "Tweet Successfully!"
      end
    push(socket, "new_msg", %{body: result})
    {:noreply, socket}
  end

  def handle_in("retweet", %{"body" => body}, socket) do
    username = socket.assigns[:username]
    tweetid = body |> String.trim()
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        id = Integer.parse(tweetid)
        if id == :error do
          "Error: The Tweet ID is invalid!"
        else
          {_, success} = GenServer.call(:Server, {:reTweet, username, tweetid})
          if success do
            "Retweet Successfully!"
          else
            "Error: The Tweet ID is invalid!"
          end
        end
      end
    push(socket, "new_msg", %{body: result})
    {:noreply, socket}
  end

  def handle_in("addSubscribe", %{"body" => body}, socket) do
    username = socket.assigns[:username]
    userToSubscribe = body |> String.trim()
    {_, success} =
      if username != nil do
        GenServer.call(:Server, {:addSubscribe, username, userToSubscribe})
      else
        {"null", false}
      end
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        if success do
          "Subscribe to #{userToSubscribe} successfully!"
        else
          "Error: #{userToSubscribe} does not exists!"
        end
      end
    push(socket, "new_msg", %{body: result})
    {:noreply, socket}
  end

  def handle_in("queryHashtagTweets", %{"body" => body}, socket) do
    username = socket.assigns[:username]
    tag = body |> String.trim()
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        list = GenServer.call(:Server, {:queryHashtagTweets, tag})
        IO.inspect list
        if list != [] do
          Enum.map(list, fn {username,tweet} -> push(socket, "new_msg", %{body: "#{username}: #{tweet}"}) end)
          "Query successfully!"
        else
          "No result!"
        end
      end
    push(socket, "new_msg", %{body: result})
    {:noreply, socket}
  end

  def handle_in("queryMentionTweets", %{"body" => body}, socket) do
    username = socket.assigns[:username]
    tag = body |> String.trim()
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        list = GenServer.call(:Server, {:queryMentionTweets, tag})
        if list != [] do
          Enum.map(list, fn {username,tweet} -> push(socket, "new_msg", %{body: "#{username}: #{tweet}"}) end)
          "Query successfully!"
        else
          "No result!"
        end
      end
    push(socket, "new_msg", %{body: result})
    {:noreply, socket}
  end

  def handle_in("querySubscribedTweets", %{}, socket) do
    username = socket.assigns[:username]
    result =
      if username == nil do
        "Error: You need to register first!"
      else
        list = GenServer.call(:Server, {:querySubscribedTweets, username})
        if list != [] do
          Enum.map(list, fn {usernames,tweet} -> push(socket, "new_msg", %{body: "#{usernames}: #{Enum.join(tweet, ",")}"}) end)
          "Query successfully!"
        else
          "No result!"
        end
      end
    push(socket, "new_msg", %{body: result})
    {:noreply, socket}
  end

  def handle_info({:tweet, username, tweet, tweetid}, socket) do
      result = "#{tweetid}: #{username} tweets: #{tweet}"
      push socket, "new_msg", %{body: result}
      {:noreply, socket}
  end

#   def handle_in("new_message", body, socket) do
#     broadcast! socket, "new_message", body
#   {:noreply, socket}
# end

end
