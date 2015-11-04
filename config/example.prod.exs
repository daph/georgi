use Mix.Config
config :georgi,

# Slack tokens must be a list
# This allows one app to connect to multiple slack chats
  slack_tokens: ["token1", "token2"],

# The input text file
  corpus: "example.txt"
