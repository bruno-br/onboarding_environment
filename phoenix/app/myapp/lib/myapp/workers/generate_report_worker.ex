defmodule Myapp.Workers.GenerateReportWorker do
  alias Myapp.Services.RedisService
  alias Myapp.Services.CsvFormatService

  def perform(report_title, get_list_function) do
    with redis_client <- RedisService.start(),
         :ok <- save_report(redis_client, report_title, :generating, ""),
         list <- get_list(get_list_function),
         {:ok, report_data} <- generate_report(report_title, list),
         :ok <- save_report(redis_client, report_title, :completed, report_data) do
      :ok
    end
  end

  defp generate_report(report_title, list) do
    with [%{} | _] <- list,
         csv <- CsvFormatService.get_csv_string(list) do
      {:ok, csv}
    else
      [] ->
        {:ok, ""}

      error ->
        {:error, error}
    end
  end

  defp save_report(redis_client, report_title, report_status, report_data) do
    report = %{status: report_status, data: report_data}
    RedisService.set(redis_client, report_title, report)
  end

  defp get_list(%{"module" => module, "function_name" => function_name, "args" => args}) do
    module_str = String.to_existing_atom(module)
    function_name_str = String.to_existing_atom(function_name)
    apply(module_str, function_name_str, args)
  end
end
