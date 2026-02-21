defmodule FormHandle.Api do
  @moduledoc "HTTP client for the FormHandle API."

  @base_url "https://api.formhandle.dev"
  @ad_keys ~w(_ad1 _ad2 _ad3 _ad4 _ad5 _docs _tip)

  defp strip_ads(data) when is_map(data) do
    Map.drop(data, @ad_keys)
  end

  defp strip_ads(data), do: data

  def get(path) do
    url = "#{@base_url}#{path}"

    case Req.get(url, headers: [{"accept", "application/json"}]) do
      {:ok, %Req.Response{status: status, body: body}} ->
        data = parse_body(body)
        %{status: status, data: strip_ads(data)}

      {:error, reason} ->
        FormHandle.Output.error("Could not connect to FormHandle API: #{inspect(reason)}")
        System.halt(1)
    end
  end

  def post(path, body, extra_headers \\ []) do
    url = "#{@base_url}#{path}"

    headers =
      [{"content-type", "application/json"}, {"accept", "application/json"}] ++ extra_headers

    case Req.post(url, json: body, headers: headers) do
      {:ok, %Req.Response{status: status, body: resp_body}} ->
        data = parse_body(resp_body)
        %{status: status, data: strip_ads(data)}

      {:error, reason} ->
        FormHandle.Output.error("Could not connect to FormHandle API: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp parse_body(body) when is_map(body), do: body
  defp parse_body(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, data} -> data
      {:error, _} -> %{"raw" => body}
    end
  end
  defp parse_body(body), do: %{"raw" => inspect(body)}
end
