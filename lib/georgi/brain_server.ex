defmodule Georgi.Brain.Server do
  use GenServer

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def make_sentence do
    GenServer.call(__MODULE__, {:make_sentence, 300})
  end

  def init({file, :public}) do
    :random.seed(:os.timestamp)
    table = :ets.new(:memory_table, [:set, :public, {:read_concurrency, :true}])
    Georgi.Brain.load_text(file, table)
    {:ok, table}
  end

  def init(file) do
    :random.seed(:os.timestamp)
    table = Georgi.Brain.load_text(file)
    {:ok, table}
  end

  def handle_call({:make_sentence, length}, _from, table) do
    sentence = Georgi.Brain.make_sentence(table, length)
    {:reply, sentence, table}
  end
end
