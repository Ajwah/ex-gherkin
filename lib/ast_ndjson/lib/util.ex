defmodule ExGherkin.AstNdjson.Util do
  @moduledoc false

  def normalize(""), do: nil
  def normalize([]), do: nil
  def normalize(a), do: a

  def parse_sentence(s) when is_binary(s) do
    {vars, template_parts} =
      s
      |> String.split(" ")
      |> Enum.reduce({[], []}, fn
        e = <<"<", remaining::binary>>, a ->
          remaining |> String.trim_trailing(">") |> handle_acc(remaining, e, a)

        e = <<"'<", remaining::binary>>, a ->
          remaining |> String.trim_trailing(">'") |> handle_acc(remaining, e, a, "'")

        e = <<"\"<", remaining::binary>>, a ->
          remaining |> String.trim_trailing(">\"") |> handle_acc(remaining, e, a, "\"")

        e, {vars, template_parts} ->
          {vars, [e | template_parts]}
      end)

    if vars == [] do
      false
    else
      %{vars: Enum.reverse(vars), template: template_parts |> Enum.reverse() |> Enum.join(" ")}
    end
  end

  def parse_sentence(_), do: %{vars: [], template: ""}

  defp handle_acc(var, remaining, original, {vars, template_parts}, quotes \\ "") do
    if var == remaining do
      {vars, [original | template_parts]}
    else
      {[var | vars], [quotes <> "%" <> quotes | template_parts]}
    end
  end
end
