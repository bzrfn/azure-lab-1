# Microsoft Azure — Lab 1

Práctica académica para crear un entorno de desarrollo en Microsoft Azure y comprobar la supervisión de una Web App mediante Application Insights y Log Analytics.

## Arquitectura

```text
Usuario
  ↓
Azure Web App (Windows + Node.js 24 LTS)
  ↓
Application Insights
  ↓
Log Analytics Workspace
```

Todos los componentes se agrupan dentro de `rg-utvt-integradora-dev-mxc-001`. El grupo de recursos conserva la ubicación México Central indicada en la práctica. La suscripción académica bloqueó los recursos de servicio en esa región mediante una directiva de Azure, por lo que Log Analytics, Application Insights, App Service Plan y Web App se desplegaron en Chile Central.

## Componentes del laboratorio

| Componente | Nombre | Configuración principal |
| --- | --- | --- |
| Resource Group | `rg-utvt-integradora-dev-mxc-001` | México Central |
| Log Analytics Workspace | `log-utvt-integradora-dev-mxc-001` | Chile Central, Pay-as-you-go / Per GB 2018 |
| Application Insights | `appi-utvt-integradora-dev-mxc-001` | Chile Central, basado en Workspace |
| App Service Plan | `asp-utvt-integradora-dev-mxc-001` | Chile Central, Windows, Free F1, 1 GB |
| Web App | `app-utvt-integradora-web-dev-mxc-001` | Chile Central, Code, Node.js 24 LTS |

## Etiquetas

- `cost_center=utvt`
- `environment=dev`
- `managed_by=portal`
- `owner=equipo-integradora`

El Resource Group utiliza las etiquetas mostradas por el profesor y los recursos de aplicación agregan `environment=dev`.

## Procedimiento general

1. Crear el Resource Group.
2. Crear Log Analytics Workspace.
3. Crear Application Insights y asociarlo al Workspace.
4. Crear el App Service Plan de Windows con SKU F1.
5. Crear la Web App con Node.js 24 LTS.
6. Vincular la Web App con el Application Insights existente.
7. Validar los recursos, el runtime y el acceso HTTPS.

## Seguridad y costos

El repositorio no almacena tokens, contraseñas, connection strings ni claves de instrumentación. El App Service Plan usa el nivel gratuito F1. Log Analytics y Application Insights pueden generar cargos por ingesta, por lo que se mantienen con tráfico mínimo durante la práctica.

## Scripts

- `scripts/deploy-resources.sh`: reproduce el despliegue ejecutado con Azure CLI. Obtiene la suscripción desde la sesión activa y no contiene secretos.
- `scripts/validate-resources.sh`: realiza consultas de solo lectura para comprobar nombres, ubicaciones, SKU, runtime y seguridad.

## Resultado validado

- Los cuatro recursos de servicio aparecen en el grupo de recursos esperado.
- El App Service Plan es Windows Free F1.
- La Web App se encuentra en estado `Running` y responde por HTTPS con código HTTP 200.
- Node.js está configurado como `~24`.
- HTTPS obligatorio está habilitado, TLS mínimo es 1.2 y FTPS está deshabilitado.
- Las políticas de publicación básica para SCM y FTP tienen `allow=false`.
- La Web App contiene la referencia de conexión a Application Insights sin publicar su valor.

## Repositorio base

<https://github.com/jorgealmeidamontiel/azure-laboratories/tree/main/Lab%201>

