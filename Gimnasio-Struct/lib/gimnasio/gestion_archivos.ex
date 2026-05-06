defmodule Gimnasio.GestionArchivos do
  @moduledoc """
  Módulo para lectura y escritura de socios en formato CSV.
  Formato: cedula,nombre,edad,clases
  Las clases se separan con punto y coma (;).
  """

  alias Gimnasio.Socio

  @archivo "socios.csv"

  @doc """
  Retorna la ruta del archivo CSV.
  """
  def ruta_archivo do
    Path.join(File.cwd!(), @archivo)
  end

  @doc """
  Lee los socios desde el archivo CSV.
  Retorna {:ok, mapa_socios} o {:error, motivo}.
  Crea el archivo si no existe.
  """
  def cargar_socios do
    archivo = ruta_archivo()

    if File.exists?(archivo) do
      case File.read(archivo) do
        {:ok, contenido} ->
          socios = parsear_csv(contenido)
          {:ok, socios}

        {:error, razon} ->
          IO.puts("Error al leer el archivo: #{inspect(razon)}")
          {:error, :error_lectura}
      end
    else
      # Crear archivo con encabezado si no existe
      case File.write(archivo, "cedula,nombre,edad,clases\n") do
        :ok ->
          {:ok, %{}}

        {:error, razon} ->
          IO.puts("Error al crear el archivo: #{inspect(razon)}")
          {:error, :error_escritura}
      end
    end
  end

  @doc """
  Guarda los socios en el archivo CSV.
  Retorna :ok o {:error, motivo}.
  """
  def guardar_socios(socios) do
    archivo = ruta_archivo()
    encabezado = "cedula,nombre,edad,clases"

    lineas =
      socios
      |> Map.values()
      |> Enum.map(fn socio ->
        clases_str = Enum.join(socio.clases, ";")
        "#{socio.cedula},#{socio.nombre},#{socio.edad},#{clases_str}"
      end)

    contenido = Enum.join([encabezado | lineas], "\n") <> "\n"

    case File.write(archivo, contenido) do
      :ok ->
        :ok

      {:error, razon} ->
        IO.puts("Error al guardar el archivo: #{inspect(razon)}")
        {:error, :error_escritura}
    end
  end

  # --- Funciones privadas ---

  defp parsear_csv(contenido) do
    contenido
    |> String.trim()
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.reduce(%{}, fn linea, acc ->
      linea = String.trim(linea)

      case String.split(linea, ",") do
        [cedula, nombre, edad_str, clases_str] ->
          case Integer.parse(edad_str) do
            {edad, _} ->
              clases =
                clases_str
                |> String.split(";")
                |> Enum.reject(&(&1 == ""))

              socio = %Socio{cedula: cedula, nombre: nombre, edad: edad, clases: clases}
              Map.put(acc, cedula, socio)

            :error ->
              acc
          end

        [cedula, nombre, edad_str] ->
          case Integer.parse(edad_str) do
            {edad, _} ->
              socio = %Socio{cedula: cedula, nombre: nombre, edad: edad, clases: []}
              Map.put(acc, cedula, socio)

            :error ->
              acc
          end

        _ ->
          acc
      end
    end)
  end
end
