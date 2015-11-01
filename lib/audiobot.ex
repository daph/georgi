defmodule AudioBot do
  def tokenize(line) do
    line
    |> String.downcase
    |> String.split(" ")
    |> Enum.map(&(String.replace(&1, ~r/[\p{P}\p{S}]/, "")))
    |> Enum.reject(&(&1 == ""))
  end

  def insert([w1|[w2|[nw|t]]], memory) do
    word_pair = {w1, w2}
    case memory do
      %{^word_pair => word_list} ->
        new_memory = Map.put(memory, word_pair, [nw|word_list])
        insert([w2|[nw|t]], new_memory)
      _ ->
        new_memory = Map.put(memory, word_pair, [nw])
        insert([w2|[nw|t]], new_memory)
    end
  end
  def insert([w1|[w2|[]]], memory) do
    word_pair = {w1, w2}
    case memory do
      %{^word_pair => _} ->
        memory
      _ ->
        new_memory = Map.put(memory, word_pair, [])
        new_memory
    end
  end
  def insert(_, memory) do
    memory
  end

  def make_sentence(memory, length) do
    {{w1, w2}, _} = Enum.random(memory)
    make_sentence(memory, length-2, {w1, w2}, [w1, w2])
    |> Enum.join(" ")
  end

  defp make_sentence(memory, 0, _, acc), do: acc
  defp make_sentence(memory, length, {w1, w2}, acc) do
    case list = memory[{w1, w2}] do
      [] ->
        acc
      _ ->
        nw = Enum.random(list)
        make_sentence(memory, length-1, {w2, nw}, acc ++ [nw])
    end
  end
end
