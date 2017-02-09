defmodule Georgi.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @brain_name Georgi.Brain.Server

  def init(:ok) do
    corpus = Application.get_env(:georgi, :corpus)
    tuple_length = Application.get_env(:georgi, :tuple_length)
    children = [
      worker(Georgi.Brain.Server, [{corpus, tuple_length, :public}, [name: @brain_name]])
    ]
    tokens = Application.get_env(:georgi, :slack_tokens)

    slack_children = for x <- tokens do
      worker(Slack.Bot, [Georgi.Slack, [], x], [id: x])
    end

    supervise(children ++ slack_children, strategy: :one_for_one)
  end
end
