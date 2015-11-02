defmodule Georgi.Slack do
  use Slack

  def init(initial_state, slack) do
    IO.puts "Connected as #{slack.me.name}"
    IO.inspect initial_state
    {:ok, initial_state}
  end

  def handle_message(message = %{subtype: "message_changed"}, _slack, state) do
    {:ok, state}
  end

  def handle_message(message = %{type: "message"}, slack, state) do
    if message.user != slack.me.name do
      if String.contains?(message.text, slack.me.name)
         or String.contains?(message.text, slack.me.id) do
           sentence = GenServer.call(state, {:make_sentence, 300})
           send_message(sentence, message.channel, slack)
         end
    end
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end
end
