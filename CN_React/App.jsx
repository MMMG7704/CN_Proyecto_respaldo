import { useState, useEffect } from 'react';

function App() {
  const [usuarios, setUsuarios] = useState([]);

  useEffect(() => {
    fetch('http://localhost:3000/users')
      .then(response => response.json())
      .then(data => setUsuarios(data))
      .catch(error => console.error('Error al cargar usuarios:', error));
  }, []);

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial' }}>
      <h1>French</h1>
      <div style={{ marginTop: '10px' }}>
        {usuarios.length > 0 ? (
          <ul>
            {usuarios.map(usuario => (
              <li key={usuario.id}>{usuario.name}</li>
            ))}
          </ul>
        ) : (
          <p>Cargando usuarios...</p>
        )}
      </div>
    </div>
  );
}

export default App;
