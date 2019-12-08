use Mix.Config
gherkin_languages = "gherkin-languages"

config :ex_gherkin,
  file: %{
    source: "#{gherkin_languages}.json",
    resource: "#{gherkin_languages}.few.terms",
  },
  homonyms: ["Агар ", "* ", "अनी ", "Tha ", "Þá ", "Ða ", "Þa "]

import_config "#{Mix.env()}.exs"
