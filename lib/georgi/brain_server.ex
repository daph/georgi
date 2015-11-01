defmodule Georgi.Brain.Server do
  use GenServer

  def init(file) do
    memory = Georgi.Brain.load_text(file)
    Agent.start_link(fn -> memory end)
  end

  def handle_call({:make_sentence, length}, _from, agent) do
    memory = Agent.get(agent, fn(mem) -> mem end)
    sentence = Georgi.Brain.make_sentence(memory, length)
    {:reply, sentence, agent} 
  end
end
