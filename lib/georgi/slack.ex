defmodule Georgi.Slack do
  use Slack
  require Logger

  def handle_connect(slack, state) do
    Logger.info "Connected to slack as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(_message = %{subtype: "message_deleted"}, _slack, state) do
    {:ok, state}
  end

  def handle_event(_message = %{subtype: "message_changed"}, _slack, state) do
    {:ok, state}
  end

  def handle_event(_message= %{subtype: "message_replied"}, _slack, state) do
    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    if message.user != slack.me.name do
      if String.downcase(message.text) |> String.contains?(slack.me.name)
         or String.contains?(message.text, slack.me.id) do
           clean_msg = message.text
           |> String.downcase
           |> String.replace(slack.me.name, "")
           |> String.replace(slack.me.id, "")

           if clean_msg == "" do
             Georgi.Brain.Server.make_sentence
             |> send_message(message.channel, slack)
           else
             Georgi.Brain.Server.make_sentence(clean_msg)
             |> send_message(message.channel, slack)
           end
         end
    end
    {:ok, state}
  end

  def handle_event(_message, _slack, state) do
    {:ok, state}
  end

  def handle_info(_, _, state) do
    {:ok, state}
  end
end
