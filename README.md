# AUTOMATIZACI-N_DE_REPORTES
PROYECTO AUTOMATIZACIÓN E INTEGRACIÓN DE REPORTES OPERATIVOS

# 🌴 PALMERAS DEL LLANO SAS BIC- Sistema de Dashboards

## 📊 Descripción General

Sistema de monitoreo y visualización de datos en tiempo real para la producción de palma y lechería. Permite a los equipos operativos y gerenciales acceder a indicadores clave actualizados automáticamente, facilitando la toma de decisiones basada en datos.

## 🎯 Objetivos

- Centralizar la información de producción en una sola plataforma
- Visualizar datos en tiempo real con actualización automática
- Proveer acceso remoto seguro desde cualquier ubicación
- Automatizar procesos de extracción y transformación de datos
- Integrar asistente de IA para consultas en lenguaje natural

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Grafana** | 10.0+ | Dashboards y visualización de datos |
| **SQL Server** | 2019+ | Data Warehouse y procesos ETL |
| **n8n** | 1.0+ | Orquestación de workflows y asistente IA |
| **Google Gemini** | 1.5 Pro | Asistente de IA (LIA) |
| **FortiGate** | - | Firewall y acceso remoto seguro |

## 📈 Dashboards

| Dashboard | Nombre | Descripción |
|-----------|--------|-------------|
| **T1** | Producción por finca y tercero | Monitoreo de fruta por finca propia y proveedores |
| **T2** | Producción por material | Análisis por material Híbrido (HIB) y Guineensis (GIN) |
| **T3** | Producción de leche diaria | Litros, vacas en ordeño y días en leche (DIM) |
| **T4** | Despacho y conciliación | Comparación de leche producida vs despachada |

## 🤖 Asistente IA - LIA

Asistente conversacional integrado en los dashboards que permite realizar consultas en lenguaje natural.

**Capacidades:**
- Consultar producción por finca, fecha o material
- Obtener resúmenes de lechería
- Comparar períodos y tendencias

## 🔐 Accesos

| Ambiente | URL | Disponibilidad |
|----------|-----|----------------|
| **Producción (Externo)** | `http://200.91.230.156:9144` | 24/7 |
| **Producción (Interno)** | `http://192.168.10.29:3000` | 24/7 |

## 📁 Estructura del Repositorio
palmeras-dashboards/
├── dashboards/ # Archivos JSON de Grafana
├── etl/ # Stored procedures ETL
├── ddl/ # Scripts de estructura de BD
├── views/ # Vistas SQL del DW
├── queries/ # Queries de validación
├── jobs/ # Jobs de SQL Server Agent
├── docs/ # Manuales y guías
└── ia/ # Configuración de asistente LIA

text

## 👥 Equipo del Proyecto

| Rol | Nombre |
|-----|--------|
| **Líder Técnico** | Dairo Ortega |
| **Analista de Datos** | José Luis Casilimas |
| **Operaciones** | Doc Carlos Eduardo Riveros |

## 📅 Mantenimiento

| Tarea | Horario |
|-------|---------|
| ETL Producción Palma | Cada hora |
| ETL Lechería Diaria | 21:30 PM |
| Restore DDM_Mirror | 06:00, 13:00, 19:00, 21:00 |

---

⭐ **Desarrollado por el equipo de Sistemas de PALMERAS DEL LLANO SAS BIC**
