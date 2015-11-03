defmodule Georgi.Brain do
  def tokenize(line) do
    line
    |> String.downcase
    |> String.split(" ")
    |> Enum.map(&String.strip(&1))
    |> Enum.map(fn(x) -> if x =~ ~r/[\!\.\?]/ do x <> "STOP" else x end end)
    |> Enum.map(&(String.replace(&1, ~r/[\p{P}\p{S}]/, "")))
    |> Enum.reject(&(&1 == ""))
  end

  def insert([w1|[w2|[nw|t]]], table) do
    word_pair = {
      String.replace(w1, "STOP", ""),
      String.replace(w2, "STOP", "")
    }
    case :ets.member(table, word_pair) do
      true ->
        list = :ets.lookup_element(table, word_pair, 2)
        :ets.insert(table, {word_pair, [nw|list]})
      false ->
        :ets.insert(table, {word_pair, [nw]})
      end

      insert([w2|[nw|t]], table)
  end
  def insert([w1|[w2|[]]], table) do
    word_pair = {
      String.replace(w1, "STOP", ""),
      String.replace(w2, "STOP", "")
    }
    unless :ets.member(table, word_pair) do
      :ets.insert(table, {word_pair, []})
    end
    table
  end
  def insert(_, table) do
    table
  end

  # length here actually really operates as max length
  def make_sentence(table, length) do
    # This has to traverse the whole table. Ew.
    [{w1, w2}|_] = :ets.match(table, {:'$1', :'_'}) |> Enum.random
    if String.contains?(w1, "STOP") or
    String.contains?(w2, "STOP") do
      make_sentence(table, length)
    else
      make_sentence(table, length-2, {w1, w2}, [w1, w2])
      |> Enum.join(" ")
    end
  end

  defp make_sentence(_table, 0, _, acc), do: acc
  defp make_sentence(table, length, {w1, w2}, acc) do
    word_pair = {w1, w2}
    case :ets.member(table, word_pair) do
      false ->
        acc
      true ->
        nw = :ets.lookup_element(table, word_pair, 2) |> Enum.random
        if String.contains?(nw, "STOP") do
          nw_stop = String.replace(nw, "STOP", ".")
          make_sentence(table, 0, {}, acc ++ [nw_stop])
        else
          make_sentence(table, length-1, {w2, nw}, acc ++ [nw])
        end
    end
  end

  def load_text(file) do
    File.stream!(file)
    |> Enum.map(&tokenize(&1))
    |> List.flatten
    |> insert(:ets.new(:memory_table, [:set, :protected, {:read_concurrency, :true}]))
  end
end
