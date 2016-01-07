defmodule Georgi.Brain do
  def tokenize(line) do
    line
    |> String.downcase
    |> String.split(" ")
    |> Enum.map(&token_rules(&1))
    |> Enum.reject(&(&1 == "" or &1 == "STOP"))
  end

  defp token_rules(w) do
    stripped = String.strip(w)
    word = if stripped =~ ~r/[\!\.\?]/ do
      stripped <> "STOP"
    else
      stripped
    end
    String.replace(word, ~r/[\p{P}\p{S}]/, "")
  end

  def insert(list, table, tuplen) when length(list) > tuplen do
    key_words = Enum.take(list, tuplen)
    word_tuple = key_words |> Enum.map(&String.replace(&1, "STOP", "")) |> List.to_tuple

    [nw|_] = Enum.drop(list, tuplen)
    [_|next_list] = list

    case :ets.member(table, word_tuple) do
      true ->
        word_list = :ets.lookup_element(table, word_tuple, 2)
        :ets.insert(table, {word_tuple, [nw|word_list]})
      false ->
        :ets.insert(table, {word_tuple, [nw]})
      end
    insert(next_list, table, tuplen)
  end
  def insert(_, table, _) do
    table
  end

  # length here actually really operates as max length
  def make_sentence(table, length) do
    # This has to traverse the whole table. Ew.
    [word_tuple|_] = :ets.match(table, {:'$1', :'_'}) |> Enum.random
    make_sentence(table, length-2, word_tuple, Tuple.to_list(word_tuple)) |> Enum.join(" ")
  end

  defp make_sentence(_table, 0, _, acc), do: acc
  defp make_sentence(table, length, word_tuple, acc) do

    case :ets.member(table, word_tuple) do
      false ->
        acc
      true ->
        nw = :ets.lookup_element(table, word_tuple, 2) |> Enum.random
        next_tuple = word_tuple |> Tuple.delete_at(0) |> Tuple.append(nw)
        if String.contains?(nw, "STOP") do
          nw_stop = String.replace(nw, "STOP", ".")
          make_sentence(table, 0, {}, acc ++ [nw_stop])
        else
          make_sentence(table, length-1, next_tuple, acc ++ [nw])
        end
    end
  end

  def make_sentence_context(table, length, message) do
    case tokenize(message) |> find_context_start(table) do
      :no_context ->
        make_sentence(table, length)
      word_tuple ->
        make_sentence(table, length-2, word_tuple, Tuple.to_list(word_tuple))
        |> Enum.join(" ")
    end
  end

  defp find_context_start(list, table) do
    tuplen = :ets.first(table) |> tuple_size
    if length(list) < tuplen do
      :no_context
    else
      word_tuple = list |> Enum.take(tuplen) |> List.to_tuple
      if :ets.member(table, word_tuple) do
        word_tuple
      else
        find_context_start(Enum.drop(list, 1), table)
      end
    end
  end

  def load_text(file, tuple_length, table \\ :undefined) do
    file = File.stream!(file)
    |> Enum.map(&tokenize(&1))
    |> List.flatten
    case table do
      :undefined ->
        insert(file, :ets.new(:memory_table, [:set, :protected, {:read_concurrency, :true}]), tuple_length)
      _ ->
        insert(file, table, tuple_length)
    end
  end
end
