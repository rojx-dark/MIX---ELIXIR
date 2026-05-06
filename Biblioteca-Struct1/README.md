# Biblioteca - Sistema de Gestión

## Descripción

Sistema de gestión de biblioteca implementado en Elixir usando Mix con Application.
Gestiona libros, usuarios y préstamos con persistencia en CSV y reportes avanzados.

### Funcionalidades
- CRUD de libros y usuarios con validaciones
- Registro de préstamos y devoluciones (máximo 3 por usuario)
- Reportes: libros más prestados, préstamos vencidos, por género, disponibilidad, clásicos
- Persistencia automática en CSV (`libros.csv`, `usuarios.csv`, `prestamos.csv`)

### Estructura de módulos
- `Biblioteca.Libro` - Struct de libro
- `Biblioteca.Usuario` - Struct de usuario
- `Biblioteca.Prestamo` - Struct de préstamo
- `Biblioteca.Biblioteca` - Lógica de negocio
- `Biblioteca.GestionArchivos` - Lectura/escritura CSV
- `Biblioteca.Menu` - Menú interactivo por consola

## Ejecución

```bash
cd biblioteca
mix run --no-halt
```

## Aprendizajes

- Manejo de múltiples structs interrelacionados
- Uso de `with` para encadenar operaciones con manejo de errores
- Persistencia en múltiples archivos CSV sincronizados
- Reportes usando Enum (group_by, filter, sort_by)
- Manejo de fechas con el módulo Date

## Uso de IA

Se utilizó inteligencia artificial como apoyo para:
- Migración de scripts .exs a proyecto Mix con Application
- Implementación del sistema de préstamos con validaciones
- Generación de reportes con procesamiento funcional
- Diseño del menú interactivo con persistencia automática
