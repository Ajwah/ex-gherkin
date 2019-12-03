use Mix.Config

# config :ex_unit_notifier, notifier: ExUnitNotifier.Notifiers.TerminalNotifier
config :mix_test_watch,
  clear: true,
  tasks: [
    "format",
    "test --stale --max-failures 1 --trace --seed 0"
  ]
