defmodule Mix.Tasks.AstNdjson do
  @moduledoc """
  Parse feature file to .ast.ndjson format
  """
  use Mix.Task

  @shortdoc "Parse feature file to .ast.ndjson format"

  def run(args) do
    path = validate_preconditions_fulfilled(args)

    "#{path}/*.feature"
    |> Path.wildcard()
    |> Enum.each(fn path ->
      file =
        path
        |> String.split()
        |> List.last()

      IO.puts("Parsing #{file} to `.ast.ndjson` format")
      r = gherkin(file)

      File.write!("#{file}.ast.ndjson", r)
    end)
  end

  @spec validate_preconditions_fulfilled(any) :: no_return
  defp validate_preconditions_fulfilled(args) do
    with {_, :ok} <- {:gherkin_check, validate_gherkin_installed()},
         {_, {:ok, path}} <- {:options_check, validate_options(args)} do
      path
    else
      {:gherkin_check, {:error, {_code, message}}} -> raise message
      {:options_check, {:error, message}} -> raise message
      error -> error
    end
  end

  @spec validate_options(any) :: {:ok, String.t()} | {:error, String.t()}
  defp validate_options(args) do
    {opts, _, _} =
      OptionParser.parse(args,
        switches: [
          source: :string
        ]
      )

    if opts[:source] do
      {:ok, opts[:source]}
    else
      {:error, "Kindly supply --source /path/to/feature_files"}
    end
  end

  @spec validate_gherkin_installed :: :ok | {:error, {atom, String.t()}}
  defp validate_gherkin_installed do
    try do
      System.cmd("gherkin", ["--help"])
      :ok
    rescue
      error ->
        details =
          error
          |> case do
            %ErlangError{original: :system_limit} ->
              {:system_limit,
               "error_code: :system_limit. All available ports in the Erlang emulator are in use"}

            %ErlangError{original: :enomem} ->
              {:enomem, "error_code: :enomem. There was not enough memory to create the port"}

            %ErlangError{original: :eagain} ->
              {:eagain,
               "error_code: :eagain. There are no more available operating system processes"}

            %ErlangError{original: :enametoolong} ->
              {:enametoolong,
               "error_code: :enametoolong. The external command given was too long"}

            %ErlangError{original: :emfile} ->
              {:emfile,
               "error_code: :emfile. There are no more available file descriptors (for the operating system process that the Erlang emulator runs in)"}

            %ErlangError{original: :enfile} ->
              {:enfile,
               "error_code: :enfile. The file table is full (for the entire operating system)"}

            %ErlangError{original: :eacces} ->
              {:eacces,
               "error_code: :eacces. The command does not point to an executable file\nKindly ensure `gem install gherkin` completed successfully and that `gherkin --help` on your local works."}

            %ErlangError{original: :enoent} ->
              {:enoent,
               "error_code: :enoent. The command does not point to an existing file\nKindly ensure `gem install gherkin` completed successfully and that `gherkin --help` on your local works."}
          end

        {:error, details}
    end
  end

  # defp gherkin(file) do
  #   "/usr/local/bin/gherkin --format ndjson --predictable-ids --ast --no-source --no-pickles #{file}"
  #   |> to_charlist
  #   |> :os.cmd
  #   |> to_string
  # end

  defp gherkin(file) do
    {r, _} =
      System.cmd("/usr/local/bin/gherkin", [
        "--format",
        "ndjson",
        "--predictable-ids",
        "--no-source",
        "--no-pickles",
        "--ast",
        file
      ])

    r
  end
end
