defmodule MyappWeb.Plugs.LogPlug do
  import Plug.Conn

  import Tirexs.HTTP

  def init(props) do
    props
  end

  def call(conn, _opts) do
    post_log(conn)
    conn
  end

  defp post_log(conn), do: post("/my_index/logs", generate_log(conn))

  defp generate_log(conn) do
    date =
      DateTime.utc_now()
      |> DateTime.to_iso8601()

    log = [
      date: date,
      method: conn.method,
      request_path: conn.request_path,
      req_headers: conn.req_headers,
      body_params: conn.body_params
    ]

    log
  end
end
