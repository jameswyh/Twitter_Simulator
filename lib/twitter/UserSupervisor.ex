defmodule UserSupervisor do
  use Supervisor

  def start_link(arg) do
    {num_user, _num_msg} = arg
    if num_user != 0 do
      Supervisor.start_link(__MODULE__, arg)
    end
  end

  def init({num_user, num_msg}) do
    children = Enum.map(1..num_user, fn(x) ->
      worker(Client, [x, num_user, num_msg], [id: x, restart: :transient])
    end)
    supervise(children, strategy: :one_for_one)
  end
end
