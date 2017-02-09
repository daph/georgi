defmodule Georgi.Brain.Server do
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def make_sentence do
    GenServer.call(__MODULE__, {:make_sentence, 300})
  end

  def make_sentence(message) do
    GenServer.call(__MODULE__, {:make_sentence, 300, message})
  end

  def init({file, tuple_length, :public}) do
    Logger.info "Initializing brain"
    :rand.seed(:exsplus, :os.timestamp)
    table = :ets.new(:memory_table, [:set, :public, {:read_concurrency, :true}])
    Georgi.Brain.load_text(file, tuple_length, table)
    {:ok, table}
  end

  def init({file, tuple_length}) do
    Logger.info "Initializing brain"
    :rand.seed(:exsplus, :os.timestamp)
    table = Georgi.Brain.load_text(file, tuple_length)
    {:ok, table}
  end

  def handle_call({:make_sentence, length}, _from, table) do
    sentence = Georgi.Brain.make_sentence(table, length)
    {:reply, sentence, table}
  end

  def handle_call({:make_sentence, length, msg}, _from, table) do
    sentence = Georgi.Brain.make_sentence_context(table, length, msg)
    {:reply, sentence, table}
  end
end
