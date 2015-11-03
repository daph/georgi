defmodule Georgi.Brain.Server do
  use GenServer

  def init(file) do
    table = Georgi.Brain.load_text(file)
    {:ok, table}
  end

  def handle_call({:make_sentence, length}, _from, table) do
    sentence = Georgi.Brain.make_sentence(table, length)
    {:reply, sentence, table} 
  end
end
