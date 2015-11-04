defmodule Georgi do
  use Application

  def start(_type, _args) do
    Georgi.Supervisor.start_link
  end
end
