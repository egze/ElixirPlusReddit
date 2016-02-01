defmodule ElixirPlusReddit.Parser do

  @moduledoc """
  A parser built on top of  Poison for decoding Reddit's various return
  structures.
  """

  def parse(%HTTPotion.Response{body: body, status_code: code}, strategy) do
    case code do
      _ ->
        body = Poison.decode!(body, keys: :atoms)
        parse(body, strategy)
    end
  end

  def parse(resp, :token) do
    "bearer #{resp.access_token}"
  end

  def parse(resp, :trophies) do
    Enum.map(resp.data.trophies, fn(trophy) -> trophy.data end)
  end

  def parse(resp, :listing) do
    Map.update!(resp.data, :children, fn(children) ->
      Enum.map(children, fn(child) ->
        child.data
      end)
    end)
  end

  def parse(resp, :reply) do
    errors = resp.json.errors
    things = resp.json.data.things |> List.first |> Map.get(:data)
    Map.put(things, :errors, errors)
  end

  def parse(resp, :submission) do
    resp.json.data
  end

  def parse(resp, :compose) do
    resp.json
  end

  def parse(resp, :no_data) do
    resp
  end

  def parse(resp, _) do
    resp
  end

end
