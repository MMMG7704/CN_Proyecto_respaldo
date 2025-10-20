#!/bin/bash
echo "Iniciando instalación completa del proyecto CN_Proyecto..."

# Variables
BACKEND_DIR="$HOME/CN_Proyecto/CN_api_bk"
FRONTEND_DIR="$HOME/CN_Proyecto/CN_React"
DB_NAME="proyecto"
DB_USER="postgres"
DB_PASSWORD=""
BACKEND_PORT=3000
FRONTEND_PORT=5173

# Crear carpetas
mkdir -p "$BACKEND_DIR" "$FRONTEND_DIR"

# ---------------------------
# Configurar base de datos
# ---------------------------
echo "Configurando base de datos PostgreSQL..."
# Crear base de datos si no existe
psql -U $DB_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
psql -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

# Crear tabla users y usuarios de ejemplo
psql -U $DB_USER -d $DB_NAME -c "CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(50), email VARCHAR(50));"
psql -U $DB_USER -d $DB_NAME -c "INSERT INTO users (name, email) VALUES
('Mariana', 'mariana@gmail.com'),
('Fany', 'fany@gmail.com'),
('Rubi', 'rubi@gmail.com')
ON CONFLICT DO NOTHING;"

# ---------------------------
# Backend
# ---------------------------
echo "Instalando dependencias del backend..."
cd "$BACKEND_DIR" || exit
if [ ! -f package.json ]; then
    npm init -y
fi
npm install express cors body-parser pg

# Crear archivo index.js
echo "Creando archivo index.js del backend..."
cat <<EOL > index.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const app = express();
app.use(cors());
app.use(bodyParser.json());

const { Pool } = require('pg');
const pool = new Pool({
  user: '$DB_USER',
  host: 'localhost',
  database: '$DB_NAME',
  password: '$DB_PASSWORD',
  port: 5432,
});

app.get('/users', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM users');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error en la base de datos');
    }
});

app.listen($BACKEND_PORT, () => console.log('Backend corriendo en puerto $BACKEND_PORT'));
EOL

# ---------------------------
# Frontend
# ---------------------------
echo "Instalando dependencias del frontend..."
cd "$FRONTEND_DIR" || exit
if [ ! -f package.json ]; then
    npm create vite@latest . -- --template react
fi
npm install

# Crear App.jsx básico
echo "Creando archivo App.jsx del frontend..."
cat <<EOL > src/App.jsx
import { useState, useEffect } from 'react';

function App() {
  const [usuarios, setUsuarios] = useState([]);

  useEffect(() => {
    fetch('http://localhost:$BACKEND_PORT/users')
      .then(res => res.json())
      .then(data => setUsuarios(data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div>
      <h1>Usuarios:</h1>
      <ul>
        {usuarios.map(u => (
          <li key={u.id}>{u.name} - {u.email}</li>
        ))}
      </ul>
    </div>
  );
}

export default App;
EOL

echo "Instalación completada correctamente."
echo "Para iniciar el backend: cd $BACKEND_DIR && node index.js"
echo "Para iniciar el frontend: cd $FRONTEND_DIR && npm run dev"
