defmodule Myapp.Services.ReportsService do
  alias Myapp.Services.RedisService
  alias Myapp.Workers.GenerateReportWorker
  alias Myapp.Management

  def request_report(report_title, get_list_function) do
    with {:ok, :completed} <- get_report_status(report_title),
         {:ok, report_data} <- get_saved_report(report_title) do
      {:ok, report_data}
    else
      {:ok, :generating} ->
        {:service_unavailable, "This report is still being generated"}

      {:error, :not_found} ->
        enqueue_report(report_title, get_list_function)

      error ->
        {:error, error}
    end
  end

  defp get_report_status(report_title) do
    RedisService.start()
    |> RedisService.get("#{report_title}_status")
  end

  defp get_saved_report(report_title) do
    case File.read("#{report_title}.csv") do
      {:ok, data} -> {:ok, data}
      _ -> {:error, :not_found}
    end
  end

  defp enqueue_report(report_title, get_list_function) do
    case Exq.enqueue(Exq, "report", GenerateReportWorker, [report_title, get_list_function]) do
      {:ok, _jid} -> {:accepted, "The report will be generated"}
      error -> {:error, "There was an error trying to generate the report"}
    end
  end
end
