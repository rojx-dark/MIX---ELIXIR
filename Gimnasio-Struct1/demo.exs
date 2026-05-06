# Demo del sistema de Gimnasio (sin menú interactivo)
IO.puts("\n=====================================")
IO.puts("   DEMO - SISTEMA DE GIMNASIO")
IO.puts("=====================================\n")

# Cargar datos desde CSV
{:ok, socios} = Gimnasio.GestionArchivos.cargar_socios()
IO.puts("Socios cargados desde CSV: #{map_size(socios)}\n")

# 1. Listar socios
IO.puts("--- 1. LISTAR SOCIOS ---")
Enum.each(socios, fn {_cedula, socio} ->
  clases = Enum.join(socio.clases, ", ")
  IO.puts("  [#{socio.cedula}] #{socio.nombre} - Edad: #{socio.edad} | Clases: #{clases}")
end)

# 2. Agregar un socio de prueba
IO.puts("\n--- 2. AGREGAR SOCIO DE PRUEBA ---")
case Gimnasio.Gimnasio.registrar_socio(socios, "99999", "Carlos Demo", 28, ["Yoga", "Spinning"]) do
  {:ok, socios_act} ->
    IO.puts("  ✅ Socio 'Carlos Demo' agregado exitosamente")
    IO.puts("  Total socios ahora: #{map_size(socios_act)}")
  {:error, razon} ->
    IO.puts("  Error: #{inspect(razon)}")
end

IO.puts("\n✅ Demo Gimnasio completada!")
