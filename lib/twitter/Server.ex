defmodule Server do

  use GenServer
  def start_link(num_user) do
    GenServer.start_link(__MODULE__, num_user, name: :Server)
  end

  def init(num_user) do
    :ets.new(:accountList, [:set, :public, :named_table])
    :ets.new(:tweetsList, [:set, :public, :named_table])
    :ets.new(:subscribeList, [:set, :public, :named_table])
    :ets.new(:hashtagList, [:set, :public, :named_table])
    :ets.new(:mentionList, [:set, :public, :named_table])
    :ets.new(:retweetList, [:set, :public, :named_table])
    :ets.new(:subscribedTweetList, [:set, :public, :named_table])

    :ets.new(:channelList, [:set, :public, :named_table])
    IO.puts("Server Start")
    userlist = []
    tweetlist = []
    {:ok, {num_user, userlist, tweetlist}}
  end

  def handle_call({:registerUser, username, password, channel_pid}, _from, {num_user, userlist, tweetlist}) do
    userslist = registerUser(username, password, channel_pid, userlist)
    success =
      if length(userlist) == length(userslist) do
        false;
      else
        true;
    end
    {:reply, {username, success}, {num_user, userslist, tweetlist}}
  end

  def handle_call({:deleteUser, username, password}, _from, {num_user, userlist, tweetlist}) do
    userslist = deleteUser(username, password, userlist)
    success =
      if length(userlist) == length(userslist) do
        false;
      else
        true;
    end
    {:reply, {username, success}, {num_user, userslist, tweetlist}}
  end

  def handle_call({:sendTweet, username, tweet}, _from, {num_user, userlist, tweetlist}) do
    tweetlists = sendTweet(username, tweet, userlist, tweetlist)
    {:reply, username, {num_user, userlist, tweetlists}}
  end

  # def handle_cast({:sendTweet, username, tweet}, {num_user, userlist}) do
  #   sendTweet(username, tweet, userlist)
  #   {:noreply, {num_user, userlist}}
  # end

  def handle_call({:getTweets, username}, _from, {num_user, userlist, tweetlist}) do
    [existingTweets] = :ets.lookup(:tweetsList, username)
    tList = elem(existingTweets, 1)
    IO.puts(tList)
    {:reply, tList, {num_user, userlist, tweetlist}}
  end

  def handle_call({:addSubscribe, username, nameOfSubscribe}, _from, {num_user, userlist, tweetlist}) do
    success = addSubscribe(username, nameOfSubscribe)
    {:reply, {username, success}, {num_user, userlist, tweetlist}}
  end

  def handle_call({:reTweet, username, tweetid}, _from, {num_user, userlist, tweetlist}) do
    tweetlists = reTweet(username, tweetid, userlist, tweetlist)
    success =
      if length(tweetlists) == length(tweetlist) do
        false;
      else
        true;
    end
    {:reply, {username, success}, {num_user, userlist, tweetlists}}
  end

  def handle_call({:querySubscribedTweets, username}, _from, {num_user, userlist, tweetlist}) do
    list = querySubscribedTweets(username)
    {:reply, list, {num_user, userlist, tweetlist}}
  end

  def handle_call({:queryHashtagTweets, hashtag}, _from, {num_user, userlist, tweetlist}) do
    list = queryHashtagTweets(hashtag)
    {:reply, list, {num_user, userlist, tweetlist}}
  end

  def handle_call({:queryMentionTweets, username}, _from, {num_user, userlist, tweetlist}) do
    list = queryMentionTweets(username)
    {:reply, list, {num_user, userlist, tweetlist}}
  end

  # def handle_cast({:clientReady, username}, {num_user, userlist}) do
  #   num_users = num_user - 1
  #   if num_users == 0 do
  #     Enum.map(userlist, fn x -> GenServer.cast(toAtom(x), {:startTweet, username}) end)
  #   end
  #   {:noreply, {num_users, userlist}}
  # end



  def registerUser(username, password, channel_pid, userlist) do
    passwordEncrypted = :crypto.hash(:sha256, password) |> Base.encode16()
    if :ets.insert_new(:accountList, {username, passwordEncrypted}) do
      :ets.insert(:tweetsList, {username, []})
      :ets.insert(:subscribeList, {username, []})
      :ets.insert(:mentionList, {username, []})
      :ets.insert(:retweetList, {username, []})
      :ets.insert(:subscribedTweetList, {username, []})
      :ets.insert(:channelList, {username, channel_pid})
      IO.puts("#{username} registered successfully")
      userlist ++ [username]
    else
      IO.puts("#{username} exists")
      userlist
    end
  end

  def deleteUser(username, password, userlist) do
    if :ets.lookup(:accountList, username) == [] do
      IO.puts("#{username} does not exist")
      userlist
    else
      [{_, userPassword}] = :ets.lookup(:accountList, username)
      if :crypto.hash(:sha256, password) |> Base.encode16() == userPassword do
        :ets.delete(:accountList, username)
        :ets.delete(:tweetsList, username)
        :ets.delete(:subscribeList, username)
        :ets.delete(:mentionList, username)
        :ets.delete(:retweetList, username)
        IO.puts("#{username} deleted successfully")
        List.delete(userlist, username)
      else
        IO.puts("Wrong password")
        userlist
      end
    end
  end

  def sendTweet(username, tweet, userlist, tweetlist) do
    mList = Regex.scan(~r/(?<=@)[^\s]+/, tweet)
    hList = Regex.scan(~r/(?<=#)[^\s]+/, tweet)
    Enum.map(mList, fn [x] -> addMention(x, {username, tweet}) end)
    Enum.map(hList, fn [x] -> addHashtag(x, {username, tweet}) end)
    [existingTweets] = :ets.lookup(:tweetsList, username)
    tList = elem(existingTweets, 1)
    tList = [tweet|tList]
    :ets.insert(:tweetsList, {username, tList})
    distributeTweet(username, tweet, length(tweetlist), userlist)
    tweetlist ++ [tweet]
  end

  def addMention(mention, tweet) do
    case :ets.lookup(:accountList, mention) do
      [{_, _}] ->
        [existingTweets] = :ets.lookup(:mentionList, mention)
        tList = elem(existingTweets, 1)
        tList = [tweet|tList]
        :ets.insert(:mentionList, {mention, tList})
        [] ->
          "do nothing"
        end
  end

  def addHashtag(hashtag, tweet) do
    hashList = :ets.lookup(:hashtagList, hashtag)
    if hashList == [] do
      :ets.insert(:hashtagList, {hashtag, [tweet]})
    else
      [existingHash] = :ets.lookup(:hashtagList, hashtag)
      htList = elem(existingHash, 1)
      htList = [tweet|htList]
      :ets.insert(:hashtagList, {hashtag, htList})
    end
  end

  def distributeTweet(username, tweet, tweetid, userlist) do
    Enum.map(userlist, fn x -> [{_, x}] = :ets.lookup(:channelList, x)
      send(x, {:tweet, username, tweet, tweetid}) end)
  end

  def addSubscribe(username, nameOfSubscribe) do
    if :ets.lookup(:accountList, nameOfSubscribe) == [] do
      IO.puts("#{username} does not exist")
      false
    else
      [existingSubscribes] = :ets.lookup(:subscribeList, username)
      sList = elem(existingSubscribes, 1)
      sList = [nameOfSubscribe | sList]
      :ets.insert(:subscribeList, {username, sList})
      IO.puts("#{username} subscribe #{nameOfSubscribe} successfully")
      true
    end
  end

  def reTweet(username, tweetid, userlist, tweetlist) do
    # [existingTweets] = :ets.lookup(:retweetList, username)
    # tList = elem(existingTweets, 1)
    # tList = [tweet|tList]
    # :ets.insert(:retweetList, {username, tList})
    id = String.to_integer(tweetid)
    if length(tweetlist) > id do
      tweet = "Re: #{Enum.at(tweetlist, id)}"
      distributeTweet(username, tweet, length(tweetlist), userlist)
      tweetlist ++ [tweet]
    else
      tweetlist
    end
  end

  def querySubscribedTweets(username) do
    [existingTweets] = :ets.lookup(:subscribeList, username)
    sList = elem(existingTweets, 1)
    IO.inspect sList
    Enum.map(sList, fn x ->
      [existingSubscribes] = :ets.lookup(:subscribedTweetList, username)
      stList = elem(existingSubscribes, 1)
      stList =
        if stList == [] do
          :ets.lookup(:tweetsList, x)
        else
          stList ++ :ets.lookup(:tweetsList, x)
      end
      :ets.insert(:subscribedTweetList, {username, stList}) end)
    [existing] = :ets.lookup(:subscribedTweetList, username)
    :ets.insert(:subscribedTweetList, {username, []})
    tList = elem(existing, 1)
    IO.inspect tList
    tList
  end

  def queryHashtagTweets(hashtag) do
    if :ets.lookup(:hashtagList, hashtag) != [] do
      [existingHash] = :ets.lookup(:hashtagList, hashtag)
      htList = elem(existingHash, 1)
      htList
    else
      []
    end
  end

  def queryMentionTweets(username) do
    if :ets.lookup(:mentionList, username) != [] do
      [existingMention] = :ets.lookup(:mentionList, username)
      mList = elem(existingMention, 1)
      mList
   else
     []
   end
  end

  def toAtom(arg) do
    if is_integer(arg) do
      arg |> Integer.to_string() |> String.to_atom()
    else
      arg |> String.to_atom()
    end
  end

end
