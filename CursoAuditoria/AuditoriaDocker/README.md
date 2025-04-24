# 🔎​🐳​ Auditoría Docker

Es una herramienta de auditoría forense para entornos Docker.El script en Bash/PowerShell recopila información detallada del entorno Docker en la máquina que incluye:

- **Información General:** Versiones, detalles del daemon y uso del sistema.
- **Contenedores:** Inspección completa, comando de inicio, logs (últimas 200 líneas) y, en lo posible, historial interno de comandos.
- **Imágenes:** Inspección completa e historial de construcción (docker history).
- **Redes, Volúmenes y Plugins:** Listado e inspección detallada.
- **Resumen Final:** Tabla con la versión de Docker y el total de contenedores, imágenes, redes, volúmenes y plugins.

![DockerAuditor](img/foto.png)

## ⚠️​ Requisitos

- Docker instalado y en ejecución.
- Shell Bash (disponible en la mayoría de distribuciones Linux).

## ​🛠️​ Instalación y Uso

1. Clona este repositorio o descarga el script `DockerAuditor.sh` si estásn en Linux y `DockerAuditor.ps1` si estás en Windows:

(Opcional pero recomendado) Crea un entorno virtual:
```bash
python -m venv venv
venv\Scripts\Activate
```

2. Instala las dependencias necesarias con:
```bash
pip install -r requirements.txt
```

3. SOLO PARA LINUX - Asigna permisos de ejecución al script:
```bash
chmod +x DockerAuditor.sh
```

4. Ejecuta el script desde la terminal:
```bash
./DockerAuditor.ps1       #Linux: ./DockerAuditor.sh
```
El script solicitará la ruta y nombre del archivo para guardar el informe de auditoría. Una vez completado, el informe estará disponible en el archivo especificado.

![DockerAuditorResultado](img/foto2.png)
![InformeDockerAuditor](img/foto3.png)

