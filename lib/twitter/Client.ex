defmodule Client do
  # use GenServer

  # def start_link(x, num_user, num_msg) do
  #   GenServer.start_link(__MODULE__, {x, num_user, num_msg}, name: Server.toAtom(x))
  #   #IO.puts "Client#{x} start"
  # end
  #
  # def init({x, num_user, num_msg}) do
  #   GenServer.call(:Server, {:registerUser, x, x|> Integer.to_string()})
  #   GenServer.cast(:Server, {:clientReady, x})
  #   {:ok, {x, num_user, num_msg}}
  # end
  #
  # def handle_cast({:startTweet, username}, {x, num_user, num_msg}) do
  #   if num_msg > 0 do
  #     Enum.map(1..num_msg, fn(n) -> GenServer.cast(:Server, {:sendTweet, x, "user#{x}, No.#{n} Tweet"}) end)
  #   end
  #   {:noreply, {x, num_user, num_msg}}
  # end
  #
  # def handle_cast({:receiveTweet, username, tweet}, {x, num_user, num_msg}) do
  #   IO.puts "#{x} Received from #{username}: #{tweet}"
  #   {:noreply, {x, num_user, num_msg}}
  # end

end
