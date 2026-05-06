defmodule Gimnasio do
  @moduledoc """
  Módulo principal de la aplicación de gestión de socios de un gimnasio.
  Usa `use Application` para definir el punto de entrada de la aplicación OTP.
  Al ejecutar `mix run`, se invoca automáticamente la función `start/2`.
  """
  use Application

  @doc """
  Punto de entrada de la aplicación.
  Carga los datos desde el CSV e inicia el menú interactivo.
  """
  def start(_type, _args) do
    Gimnasio.Menu.iniciar()
    {:ok, self()}
  end
end
