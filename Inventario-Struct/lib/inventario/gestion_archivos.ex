defmodule Inventario.GestionArchivos do
  @moduledoc """
  Módulo para lectura y escritura de productos en formato JSON.
  """

  alias Inventario.Producto

  @archivo "productos.json"

  @doc """
  Retorna la ruta del archivo JSON.
  """
  def ruta_archivo do
    Path.join(File.cwd!(), @archivo)
  end

  @doc """
  Carga los productos desde el archivo JSON.
  Retorna {:ok, mapa_productos} o {:error, motivo}.
  Crea el archivo si no existe.
  """
  def cargar_productos do
    archivo = ruta_archivo()

    if File.exists?(archivo) do
      case File.read(archivo) do
        {:ok, contenido} ->
          case Jason.decode(contenido) do
            {:ok, mapa_json} ->
              productos = parsear_json(mapa_json)
              {:ok, productos}
            {:error, _} ->
              IO.puts("Error al decodificar el archivo JSON.")
              {:error, :error_json}
          end

        {:error, razon} ->
          IO.puts("Error al leer el archivo: #{inspect(razon)}")
          {:error, :error_lectura}
      end
    else
      # Crear archivo vacío si no existe
      case File.write(archivo, "{}") do
        :ok ->
          {:ok, %{}}

        {:error, razon} ->
          IO.puts("Error al crear el archivo: #{inspect(razon)}")
          {:error, :error_escritura}
      end
    end
  end

  @doc """
  Guarda los productos en el archivo JSON.
  Retorna :ok o {:error, motivo}.
  """
  def guardar_productos(inventario) do
    archivo = ruta_archivo()

    # El inventario es un mapa de {codigo => %Producto{}}.
    # Al codificar a JSON, las llaves de mapa quedan como strings.
    case Jason.encode(inventario, pretty: true) do
      {:ok, json_string} ->
        case File.write(archivo, json_string) do
          :ok ->
            :ok

          {:error, razon} ->
            IO.puts("Error al guardar el archivo: #{inspect(razon)}")
            {:error, :error_escritura}
        end
      {:error, _} ->
        IO.puts("Error al codificar el inventario a JSON.")
        {:error, :error_json}
    end
  end

  # --- Funciones privadas ---

  defp parsear_json(mapa_json) do
    Enum.reduce(mapa_json, %{}, fn {codigo, datos}, acc ->
      producto = %Producto{
        codigo: codigo,
        nombre: Map.get(datos, "nombre"),
        precio: Map.get(datos, "precio"),
        cantidad: Map.get(datos, "cantidad")
      }
      Map.put(acc, codigo, producto)
    end)
  end
end
