# Salesforce Five9 Integration

Este repositorio contiene un **Lightning Web Component (LWC)** y clases **Apex** que integran Salesforce con la central telefónica **Five9**.  

---

## 🚀 Componentes principales

### 🔹 LWC: `taskComponent`
Componente Lightning Web que permite la visualización e interacción con las tareas relacionadas a llamadas y registros provenientes de Five9.

**Características:**
- Interfaz dinámica desarrollada en HTML, CSS y JavaScript.
- Propiedades reactivas con `@track` y `@api`.
- Lógica encapsulada para comunicación con Apex Controllers.
- Tests unitarios incluidos en `__tests__/`.

Archivos:
- `taskComponent.html` → estructura de la UI.  
- `taskComponent.js` → lógica del componente (JS + llamadas Apex).  
- `taskComponent.css` → estilos específicos.  
- `taskComponent.js-meta.xml` → visibilidad y configuración en Salesforce.  
- `__tests__/taskComponent.test.js` → pruebas unitarias del componente.  

---

### 🔹 Apex Classes
#### 1. `IL_TaskController.cls`
- Controlador principal para manejo de **Tasks** en Salesforce relacionadas a llamadas Five9.  
- Expone métodos que permiten crear, actualizar y consultar registros de Tareas.  
- Encapsula la lógica de negocio asegurando consistencia con los objetos estándar de Salesforce.

#### 2. `IL_CustomSearch.cls`
- Clase utilitaria que ofrece **búsquedas personalizadas** dentro del contexto de integración con Five9.  
- Optimizada para consultas específicas de usuarios, cuentas y llamadas.  


---


