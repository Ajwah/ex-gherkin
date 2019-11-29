use Mix.Config

config :mix_test_watch,
  clear: true,
  tasks: [
    "format",
    "test --stale --max-failures 1 --trace --seed 0"
  ]
