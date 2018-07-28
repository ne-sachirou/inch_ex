defmodule InchEx.CLI.Commands.SuggestCommand do
  alias InchEx.CLI.Options
  alias InchEx.CodeObject
  alias InchEx.Docs

  alias InchEx.CLI.Commands.SuggestOutput

  @doc false
  def call(argv) do
    argv
    |> locate_docs()
    |> fetch_and_evaluate_docs()
    |> display_results()
  end

  defp locate_docs(argv) do
    options = Options.parse(argv)

    Docs.beam_files(options.path)
  end

  defp fetch_and_evaluate_docs(beam_files) when is_list(beam_files) do
    beam_files
    |> Enum.map(&Task.async(fn -> fetch_and_evaluate_docs(&1) end))
    |> Enum.flat_map(&Task.await(&1, :infinity))
  end

  defp fetch_and_evaluate_docs(beam_file) when is_binary(beam_file) do
    beam_file
    |> Docs.get_docs()
    |> CodeObject.eval()
  end

  defp display_results(results) do
    SuggestOutput.call(results)
  end
end
