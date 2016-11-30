defmodule Optimus.FormatableHelp do

  alias Optimus.ColumnFormatter, as: CF
  alias Optimus.Format

  @left_pading 4
  @separaion_padding 8

  @simple_separator ": "

  def formatable_help(title, formatables, max_width) when max_width > 0 do
    [title, ""] ++ formatted_help(formatables, max_width)
  end

  defp formatted_help(formatables, max_width) do
    widths = get_column_widths(formatables, max_width)
    formatables
    |> Enum.map(&(format_columns(widths, &1)))
    |> Enum.concat
    |> Enum.map(&(Enum.join(&1)))
  end

  defp format_columns({:ok, widths}, formatable) do
    {:ok, formatted} = CF.format(widths, ["", Format.format(formatable), "", Format.help(formatable)])
    formatted
  end
  defp format_columns(:not_enough_space, formatable) do
    [[Format.format(formatable), @simple_separator, Format.help(formatable)]]
  end

  defp get_formatable_max_width(formatables) do
    List.foldl(formatables, 0, &(max(String.length(Format.format(&1)), &2)))
  end

  defp get_column_widths(formatables, max_width) do
    formatable_column_width = get_formatable_max_width(formatables)
    probable_help_column_width = max_width - @left_pading - @separaion_padding - formatable_column_width
    if probable_help_column_width > formatable_column_width do # expected case, have many space for help column
      {:ok, [@left_pading, formatable_column_width, @separaion_padding, probable_help_column_width]}
    else
      :not_enough_space
    end
  end

end
