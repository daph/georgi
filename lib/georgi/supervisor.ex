defmodule Georgi.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @brain_name Georgi.Brain.Server

end
