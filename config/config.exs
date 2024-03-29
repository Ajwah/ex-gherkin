import Config
gherkin_languages = "gherkin-languages"

config :my_ex_gherkin,
  file: %{
    source: "#{gherkin_languages}.json",
    resource: "#{gherkin_languages}.few.terms"
  },
  homonyms: ["Агар ", "* ", "अनी ", "Tha ", "Þá ", "Ða ", "Þa "],
  debug: %{
    tokenizer: false,
    prepare: false,
    parser: false,
    format_message: false,
    parser_raise: false
  }

import_config "#{Mix.env()}.exs"
