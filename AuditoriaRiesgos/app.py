from openai import OpenAI
from flask import Flask, send_from_directory, request, jsonify
import re

app = Flask(__name__)

# Simulación de base de datos de usuarios (clave: usuario, valor: contraseña)
usuarios = {
    "admin": "1234",
    "usuario": "contraseña",
    "demo": "demo123"
}

@app.route('/', methods=["GET", "POST"])
def serve_index():
    return send_from_directory('dist', 'index.html')

@app.route('/<path:path>')
def serve_static(path):
    return send_from_directory('dist', path)

# Ruta para login ficticio
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    usuario = data.get('usuario')
    contrasena = data.get('contrasena')

    if not usuario or not contrasena:
        return jsonify({"error": "Faltan campos de usuario o contraseña"}), 400

    if usuarios.get(usuario) == contrasena:
        return jsonify({"mensaje": "Inicio de sesión exitoso", "usuario": usuario})
    else:
        return jsonify({"error": "Credenciales incorrectas"}), 401

client = OpenAI(
    base_url='http://localhost:11434/v1',
    api_key='ollama',
)

@app.route('/analizar-riesgos', methods=['POST'])
def analizar_riesgos():
    data = request.get_json()
    activo = data.get('activo')
    if not activo:
        return jsonify({"error": "El campo 'activo' es necesario"}), 400

    riesgos, impactos = obtener_riesgos(activo)
    return jsonify({"activo": activo, "riesgos": riesgos, "impactos": impactos})

@app.route('/sugerir-tratamiento', methods=['POST'])
def sugerir_tratamiento():
    data = request.get_json()
    activo = data.get('activo')
    riesgo = data.get('riesgo')
    impacto = data.get('impacto')

    if not activo or not riesgo or not impacto:
        return jsonify({"error": "Los campos 'activo', 'riesgo' e 'impacto' son necesarios"}), 400

    entrada_tratamiento = f"{activo};{riesgo};{impacto}"
    tratamiento = obtener_tratamiento(entrada_tratamiento)

    return jsonify({"activo": activo, "riesgo": riesgo, "impacto": impacto, "tratamiento": tratamiento})

def obtener_tratamiento(riesgo):
    response = client.chat.completions.create(
        model="ramiro:instruct",
        messages=[
            {"role": "system", "content": "Responde en español..."},
            {"role": "user", "content": "mi telefono movil;Acceso no autorizado;..."},
            {"role": "assistant",  "content": "Establecer un bloqueo..."},
            {"role": "user", "content": riesgo }
        ]
    )
    return response.choices[0].message.content

def obtener_riesgos(activo):
    response = client.chat.completions.create(
        model="ramiro:instruct",
        messages=[
            {"role": "system", "content": "Responde en español..."},
            {"role": "user", "content": "mi raspberry pi"},
            {"role": "assistant",  "content": """• **Acceso no autorizado**: ...
            """ },
            {"role": "user", "content": activo }
        ]
    )
    answer = response.choices[0].message.content
    patron = r'\*\*\s*(.+?)\*\*:\s*(.+?)\.(?=\s*\n|\s*$)'
    resultados = re.findall(patron, answer)
    riesgos = [resultado[0] for resultado in resultados]
    impactos = [resultado[1] for resultado in resultados]
    return riesgos, impactos

if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port="5500")
