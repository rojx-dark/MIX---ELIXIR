defmodule Biblioteca do
  @moduledoc """
  Módulo principal de la aplicación de gestión de biblioteca.
  Usa `use Application` para definir el punto de entrada de la aplicación OTP.
  Gestiona libros, usuarios y préstamos con persistencia en CSV.
  """
  use Application

  @doc """
  Punto de entrada de la aplicación.
  Carga los datos desde CSV e inicia el menú interactivo.
  """
  def start(_type, _args) do
    Biblioteca.Menu.iniciar()
    {:ok, self()}
  end
end
