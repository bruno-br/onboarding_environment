defmodule Myapp.Workers.GenerateReportWorker do
  alias Myapp.Services.RedisService
  alias Myapp.Services.CsvFormatService

  def perform(report_title, get_list_function, expiration_in_seconds \\ 60) do
    with redis_client <- RedisService.start(),
         :ok <- set_report_status(redis_client, report_title, :generating, expiration_in_seconds),
         list <- get_list(get_list_function),
         {:ok, report_data} <- generate_report_data(report_title, list),
         :ok <- save_report(report_title, report_data),
         :ok <- set_report_status(redis_client, report_title, :completed, expiration_in_seconds) do
      :ok
    else
      error -> delete_report_status(report_title)
    end
  end

  defp generate_report_data(report_title, list) do
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

  defp get_report_status_key(report_title), do: "#{report_title}_status"

  defp set_report_status(redis_client, report_title, report_status, expiration_in_seconds),
    do: RedisService.set(redis_client, get_report_status_key(report_title), report_status, expiration_in_seconds)

  defp delete_report_status(report_title),
    do: RedisService.start() |> RedisService.del(get_report_status_key(report_title))

  defp save_report(report_title, report_data), do: File.write("#{report_title}.csv", report_data)

  defp get_list(%{"module" => module, "function_name" => function_name, "args" => args}) do
    module_str = String.to_existing_atom(module)
    function_name_str = String.to_existing_atom(function_name)
    list = apply(module_str, function_name_str, args)
    list
  end

  defp get_list(invalid_params), do: :error
end
