defmodule Inventario do
  @moduledoc """
  Módulo principal de la aplicación de inventario de productos.
  Usa `use Application` para definir el punto de entrada de la aplicación OTP.
  La persistencia se realiza en formato JSON usando la librería Jason.
  """
  use Application

  @doc """
  Punto de entrada de la aplicación.
  Carga los productos desde JSON e inicia el menú interactivo.
  """
  def start(_type, _args) do
    Inventario.Menu.iniciar()
    {:ok, self()}
  end
end
