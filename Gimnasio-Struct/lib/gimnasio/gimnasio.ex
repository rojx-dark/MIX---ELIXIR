defmodule Gimnasio.Gimnasio do
  @moduledoc """
  Módulo de lógica de negocio para la gestión de socios del gimnasio.
  Usa un Map donde la clave es la cédula y el valor es el struct Socio.
  """

  alias Gimnasio.Socio

  @doc """
  Crea un nuevo socio y lo agrega al mapa.
  No permite cédulas duplicadas.
  """
  def crear_socio(socios, cedula, nombre, edad) do
    case Socio.nuevo(cedula, nombre, edad) do
      {:ok, nuevo_socio} ->
        if Map.has_key?(socios, cedula) do
          {:error, :cedula_duplicada}
        else
          {:ok, Map.put(socios, cedula, nuevo_socio)}
        end

      {:error, razon} ->
        {:error, razon}
    end
  end

  @doc """
  Elimina un socio del mapa por su cédula.
  """
  def eliminar_socio(socios, cedula) do
    if Map.has_key?(socios, cedula) do
      {:ok, Map.delete(socios, cedula)}
    else
      {:error, :no_encontrado}
    end
  end

  @doc """
  Inscribe a un socio en una clase.
  """
  def inscribir_clase(socios, cedula, clase) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, :no_encontrado}

      socio ->
        case Socio.inscribir_clase(socio, clase) do
          {:ok, actualizado} ->
            {:ok, Map.put(socios, cedula, actualizado)}

          {:error, razon} ->
            {:error, razon}
        end
    end
  end

  @doc """
  Desinscribe a un socio de una clase.
  """
  def desinscribir_clase(socios, cedula, clase) do
    case Map.get(socios, cedula) do
      nil ->
        {:error, :no_encontrado}

      socio ->
        case Socio.desinscribir_clase(socio, clase) do
          {:ok, actualizado} ->
            {:ok, Map.put(socios, cedula, actualizado)}

          {:error, razon} ->
            {:error, razon}
        end
    end
  end

  @doc """
  Busca un socio por su cédula.
  """
  def buscar_socio(socios, cedula) do
    case Map.get(socios, cedula) do
      nil -> {:error, :no_encontrado}
      socio -> {:ok, socio}
    end
  end

  @doc """
  Retorna la lista de todos los socios.
  """
  def listar_socios(socios), do: Map.values(socios)

  @doc """
  Lista todos los socios inscritos en una clase específica.
  """
  def socios_en_clase(socios, clase) do
    socios
    |> Map.values()
    |> Enum.filter(fn socio -> Socio.tiene_clase?(socio, clase) end)
  end

  @doc """
  Lista todas las clases de un socio dada su cédula.
  """
  def clases_de_socio(socios, cedula) do
    case Map.get(socios, cedula) do
      nil -> {:error, :no_encontrado}
      socio -> {:ok, socio.clases}
    end
  end
end
