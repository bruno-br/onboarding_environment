defmodule Myapp.Services.ReportsService do
  alias Myapp.Services.RedisService
  alias Myapp.Workers.GenerateReportWorker
  alias Myapp.Management

  def request_report(report_title, get_list_function) do
    case get_saved_report(report_title) do
      {:ok, report} ->
        {:ok, report}

      {:error, :not_found} ->
        generate_report(report_title, get_list_function)
        {:accepted, "The report is being generated"}

      error ->
        {:error, error}
    end
  end

  defp get_saved_report(report_title) do
    RedisService.start()
    |> RedisService.get(report_title)
  end

  defp generate_report(report_title, get_list_function) do
    Exq.enqueue(Exq, "report", GenerateReportWorker, [report_title, get_list_function])
  end
end
