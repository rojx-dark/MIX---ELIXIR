defmodule Gimnasio.Socio do
  @moduledoc """
  Struct que representa un socio del gimnasio.
  Cada socio tiene: cédula, nombre, edad y lista de clases.
  """

  @enforce_keys [:cedula, :nombre, :edad]
  defstruct [:cedula, :nombre, :edad, clases: []]

  @doc """
  Crea un nuevo socio con validaciones.
  Retorna {:ok, socio} o {:error, motivo}.
  """
  def nuevo(cedula, nombre, edad) do
    cond do
      String.trim(cedula) == "" ->
        {:error, :cedula_vacia}

      String.trim(nombre) == "" ->
        {:error, :nombre_vacio}

      not is_integer(edad) or edad <= 0 ->
        {:error, :edad_invalida}

      true ->
        {:ok, %__MODULE__{cedula: cedula, nombre: nombre, edad: edad, clases: []}}
    end
  end

  @doc """
  Inscribe al socio en una clase.
  No permite clases duplicadas.
  """
  def inscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    clase = String.trim(clase)

    if clase == "" do
      {:error, :clase_vacia}
    else
      if tiene_clase?(socio, clase) do
        {:error, :ya_inscrito}
      else
        {:ok, %{socio | clases: clases ++ [clase]}}
      end
    end
  end

  @doc """
  Desinscribe al socio de una clase.
  """
  def desinscribir_clase(%__MODULE__{clases: clases} = socio, clase) do
    if tiene_clase?(socio, clase) do
      {:ok, %{socio | clases: List.delete(clases, clase)}}
    else
      {:error, :no_inscrito}
    end
  end

  @doc """
  Verifica si el socio está inscrito en una clase.
  """
  def tiene_clase?(%__MODULE__{clases: clases}, clase) do
    Enum.member?(clases, clase)
  end
end
