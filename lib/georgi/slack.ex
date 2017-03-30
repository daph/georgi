defmodule Georgi.Slack do
  use Slack
  require Logger

  def handle_connect(slack, state) do
    Logger.info "Connected to slack as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{type: "message", subtype: "bot_message"}, slack, state) do
    message.text
    |> respond(message.user, slack.me.name, slack.me.id)
    |> send_message(message.channel, slack)
    {:ok, state}
  end
  def handle_event(_message = %{subtype: _subtype}, _slack, state) do
    {:ok, state}
  end
  def handle_event(message = %{type: "message"}, slack, state) do
    message.text
    |> respond(message.user, slack.me.name, slack.me.id)
    |> send_message(message.channel, slack)
    {:ok, state}
  end
  def handle_event(_message, _slack, state) do
    {:ok, state}
  end

  def handle_info(_, _, state) do
    {:ok, state}
  end

  def respond(text, their_id, my_name, my_id) do
    if their_id != my_id do
      if String.downcase(text) |> String.contains?(my_name)
      or String.contains?(text, my_id) do
        clean_msg = text
        |> String.downcase
        |> String.replace(my_name, "")
        |> String.replace(my_id, "")

        if clean_msg == "" do
          Georgi.Brain.Server.make_sentence
        else
          Georgi.Brain.Server.make_sentence(clean_msg)
        end
      end
    end
  end
end
