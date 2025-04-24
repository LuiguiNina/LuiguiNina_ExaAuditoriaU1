# DockerAuditor - Auditoría Forense de Docker en Windows
Clear-Host
Write-Host "   ____             _                  _             _ _ _      "
Write-Host "  |  _ \  ___   ___| | _____ _ __     / \  _   _  __| (_) |_ ___  _ __ "
Write-Host "  | | | |/ _ \ / __| |/ / _ \ '__|   / _ \| | | |/ _\ | | __/ _ \| __|"
Write-Host "  | |_| | (_) | (__|   <  __/ |     / ___ \ |_| | (_| | | || (_) | |   "
Write-Host "  |____/ \___/ \___|_|\_\___|_|    /_/   \_\__,_|\__,_|_|\__\___/|_|   "
Write-Host ""
Write-Host "---- By: MARH - Adaptado a Windows por Oscar Jimenez-------------------------------------------------"
Write-Host ""

# Solicitar la ruta de salida
$OUTPUT_DIR = Read-Host "Ingrese la ruta completa donde desea guardar el informe (ejemplo: C:\\AuditoriaDocker\\)"

# Verificar si la ruta ingresada existe
if (-not (Test-Path -Path $OUTPUT_DIR -PathType Container)) {
    Write-Host "Error: La ruta ingresada no existe. Abortando."
    exit
}

# Generar el nombre del archivo con timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$OUTPUT_FILE = "$OUTPUT_DIR\docker_audit_$timestamp.txt"

# Inicializar el archivo de informe
@"
=============================================
             DockerAuditor                 
       Auditoría Forense de Docker         
=============================================
Fecha: $(Get-Date)
=============================================

"@ | Out-File -FilePath $OUTPUT_FILE -Encoding UTF8

Write-Host "Iniciando la auditoría de Docker..."

# Información General
Write-Host "[1] Información General de Docker..."
@"
*****************************
1. INFORMACIÓN GENERAL
*****************************
$(docker version)
$(docker info)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Uso del sistema
Write-Host "[2] Uso del sistema Docker..."
@"
*****************************
2. USO DEL SISTEMA
*****************************
$(docker system df)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Auditoría de Contenedores
Write-Host "[3] Analizando contenedores..."
@"
*****************************
3. CONTENEDORES
*****************************
$(docker ps -a)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Auditoría de Imágenes
Write-Host "[4] Analizando imágenes..."
@"
*****************************
4. IMÁGENES
*****************************
$(docker images)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Auditoría de Redes
Write-Host "[5] Analizando redes..."
@"
*****************************
5. REDES
*****************************
$(docker network ls)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Auditoría de Volúmenes
Write-Host "[6] Analizando volúmenes..."
@"
*****************************
6. VOLÚMENES
*****************************
$(docker volume ls)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Auditoría de Plugins
Write-Host "[7] Analizando plugins..."
@"
*****************************
7. PLUGINS
*****************************
$(docker plugin ls)
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8

Start-Sleep -Seconds 2

# Implementación de Checkov
Write-Host "[8] Ejecutando Checkov para análisis de seguridad..."
if (!(Test-Path -Path "Dockerfile") -and !(Test-Path -Path "docker-compose.yml")) {
    @"
*****************************
8. CHECKOV
*****************************
No se encontraron archivos Dockerfile o docker-compose.yml en el directorio actual.
No se realizó el análisis de seguridad con Checkov.
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8
} else {
    checkov -d . --output json | Out-File -FilePath "$OUTPUT_DIR\checkov_output.json" -Encoding UTF8
    if ($?) {
        @"
*****************************
8. CHECKOV
*****************************
Análisis de Checkov completado con éxito. Resultados guardados.
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8
    } else {
        @"
*****************************
8. CHECKOV
*****************************
Error al ejecutar Checkov, pero el análisis continuará.
"@ | Out-File -FilePath $OUTPUT_FILE -Append -Encoding UTF8
    }
}

Start-Sleep -Seconds 2

# Guardar tabla resumen en CSV
$summary_file = "$OUTPUT_DIR\docker_audit_summary_$timestamp.csv"
@"
Categoria,Cantidad
Docker Version,$(docker version --format '{{.Server.Version}}')
Total Contenedores,$(docker ps -aq | Measure-Object | % Count)
Contenedores Activos,$(docker ps -q | Measure-Object | % Count)
Total Imágenes,$(docker images -q | Measure-Object | % Count)
Total Redes,$(docker network ls -q | Measure-Object | % Count)
Total Volúmenes,$(docker volume ls -q | Measure-Object | % Count)
Total Plugins,$(docker plugin ls -q | Measure-Object | % Count)
"@ | Out-File -FilePath $summary_file -Encoding UTF8

# Mostrar tabla resumen en consola
Write-Host ""
Write-Host "================ Resumen de Auditoría ================"
Write-Host "Información General: Docker version: $(docker version --format '{{.Server.Version}}')"
Write-Host "Contenedores: Total: $(docker ps -aq | Measure-Object | % Count), Activos: $(docker ps -q | Measure-Object | % Count)"
Write-Host "Imágenes: Total: $(docker images -q | Measure-Object | % Count)"
Write-Host "Redes: Total: $(docker network ls -q | Measure-Object | % Count)"
Write-Host "Volúmenes: Total: $(docker volume ls -q | Measure-Object | % Count)"
Write-Host "Plugins: Total: $(docker plugin ls -q | Measure-Object | % Count)"
Write-Host "======================================================"

Write-Host "La auditoría se completó. El informe se ha guardado en: $OUTPUT_FILE"
Write-Host "El resumen se ha guardado en: $summary_file"
