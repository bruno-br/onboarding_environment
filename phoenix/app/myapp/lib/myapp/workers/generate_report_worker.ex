defmodule Myapp.Workers.GenerateReportWorker do
  alias Myapp.Services.{CsvFormatService, RedisService, ReportsMailerService}

  def perform(report_title, get_list_function, expiration_in_seconds \\ 60) do
    with :ok <- set_report_status(report_title, :generating, expiration_in_seconds),
         list <- get_list(get_list_function),
         {:ok, report_data} <- generate_report_data(list),
         :ok <- save_report(report_title, report_data),
         :ok <- set_report_status(report_title, :completed, expiration_in_seconds),
         {:ok, _message} <- send_report_email(report_title, report_data) do
      :ok
    else
      _error ->
        delete_report_status(report_title)
        :error
    end
  end

  defp generate_report_data(list), do: CsvFormatService.get_csv_string(list)

  defp get_report_status_key(report_title), do: "#{report_title}_status"

  defp set_report_status(report_title, report_status, expiration_in_seconds),
    do:
      RedisService.set(
        get_report_status_key(report_title),
        report_status,
        expiration_in_seconds
      )

  defp delete_report_status(report_title),
    do: RedisService.del(get_report_status_key(report_title))

  defp save_report(report_title, report_data), do: File.write("#{report_title}.csv", report_data)

  defp get_list(%{"module" => module, "function_name" => function_name, "args" => args}) do
    module_str = String.to_existing_atom(module)
    function_name_str = String.to_existing_atom(function_name)

    apply(module_str, function_name_str, args)
  end

  defp get_list(_invalid_params), do: :error

  defp send_report_email(report_title, report_data) do
    ReportsMailerService.send_email(report_title, %{
      content_type: "text/csv",
      filename: "#{report_title}.csv",
      data: report_data
    })
  end
end
