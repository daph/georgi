# Georgi

This is a toy markov chain chatbot for slack, written in Elixir.

If you would like to run it, rename config/example.prod.exs to config/prod.exs, put your slack token(s) in there, and change :corpus to point to your corpus text.
After that run ```MIX_ENV=prod mix run --no-halt```

