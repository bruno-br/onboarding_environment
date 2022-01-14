defmodule Myapp.Workers.GenerateReportWorker do
  alias Myapp.Services.RedisService
  alias Myapp.Services.CsvFormatService
  alias Myapp.Management

  def perform(report_title, get_list_function) do
    list = get_list(get_list_function)
    generate_report(report_title, list)
  end

  defp generate_report(report_title, list) do
    with [%{} | _] <- list,
         csv <- CsvFormatService.get_csv_string(list) do
      save_report(report_title, csv)
    else
      [] ->
        save_report(report_title, "")

      error ->
        :error
    end
  end

  defp save_report(report_title, report_data) do
    RedisService.start()
    |> RedisService.set(report_title, report_data)
  end

  defp get_list(%{"module" => module, "function_name" => function_name, "args" => args}) do
    module_str = String.to_existing_atom(module)
    function_name_str = String.to_existing_atom(function_name)
    apply(module_str, function_name_str, args)
  end
end
