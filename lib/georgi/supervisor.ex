defmodule Georgi.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @brain_name Georgi.Brain.Server

  def init(:ok) do
    corpus = Application.get_env(:georgi, :corpus)
    children = [
      worker(Georgi.Brain.Server, [[corpus], [name: @brain_name]])
    ]
    tokens = Application.get_env(:georgi, :slack_tokens)

    slack_children = for x <- tokens do
      worker(Georgi.Slack, [x, @brain_name], [id: x])
    end

    supervise(children ++ slack_children, strategy: :one_for_one)
  end
end
