<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Gestión Trabajos de Grado UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --uts-blue: #0056b3;
            --uts-dark-blue: #004494;
            --uts-gold: #FFD700;
            --uts-light: #f8f9fa;
        }
        
        body {
            background: linear-gradient(135deg, var(--uts-blue) 0%, var(--uts-dark-blue) 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
        }
        
        .login-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        .uts-header {
            background: var(--uts-blue);
            color: white;
            padding: 2rem;
            text-align: center;
        }
        
        .uts-logo {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        
        .uts-subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        
        .login-form {
            padding: 2.5rem;
        }
        
        .credentials-panel {
            background: var(--uts-light);
            border-left: 4px solid var(--uts-gold);
            padding: 2rem;
        }
        
        .role-badge {
            font-size: 0.75rem;
            padding: 0.35rem 0.65rem;
        }
        
        .btn-uts {
            background: var(--uts-blue);
            border-color: var(--uts-blue);
            color: white;
            font-weight: 600;
            padding: 0.75rem 2rem;
        }
        
        .btn-uts:hover {
            background: var(--uts-dark-blue);
            border-color: var(--uts-dark-blue);
            color: white;
        }
        
        .form-control {
            border-radius: 8px;
            padding: 0.75rem 1rem;
            border: 2px solid #e9ecef;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            border-color: var(--uts-blue);
            box-shadow: 0 0 0 0.2rem rgba(0, 86, 179, 0.25);
        }
        
        .credential-item {
            background: white;
            border-radius: 8px;
            padding: 1rem;
            margin-bottom: 1rem;
            border: 1px solid #dee2e6;
            transition: transform 0.2s ease;
        }
        
        .credential-item:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .system-info {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-top: 2rem;
        }
        
        @media (max-width: 768px) {
            .credentials-panel {
                border-left: none;
                border-top: 4px solid var(--uts-gold);
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-10">
                <div class="login-container">
                    <div class="row g-0">
                        <!-- Panel de Login -->
                        <div class="col-md-7">
                            <div class="uts-header">
                                <div class="uts-logo">🎓 UTS</div>
                                <div class="uts-subtitle">Unidades Tecnológicas de Santander</div>
                                <h3 class="mt-3 mb-0">Sistema de Gestión de Trabajos de Grado</h3>
                            </div>
                            
                            <div class="login-form">
                                <h4 class="mb-4 text-center">Iniciar Sesión</h4>
                                
                                <form action="login.jsp" method="POST">
                                    <div class="mb-3">
                                        <label for="email" class="form-label">Correo Electrónico</label>
                                        <div class="input-group">
                                            <span class="input-group-text">📧</span>
                                            <input type="email" class="form-control" id="email" name="email" 
                                                   placeholder="usuario@uts.edu.co" required>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-4">
                                        <label for="password" class="form-label">Contraseña</label>
                                        <div class="input-group">
                                            <span class="input-group-text">🔒</span>
                                            <input type="password" class="form-control" id="password" name="password" 
                                                   placeholder="Ingresa tu contraseña" required>
                                        </div>
                                    </div>
                                    
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-uts btn-lg">
                                            🚀 Ingresar al Sistema
                                        </button>
                                    </div>
                                </form>
                                
                                <%
                                    String error = request.getParameter("error");
                                    if (error != null) {
                                %>
                                    <div class="alert alert-danger mt-3" role="alert">
                                        <strong>❌ Error de autenticación:</strong>
                                        <%= "1".equals(error) ? "Credenciales incorrectas" : 
                                           "2".equals(error) ? "Usuario inactivo" : 
                                           "Error al iniciar sesión" %>
                                    </div>
                                <%
                                    }
                                %>
                                
                                <!-- Información del Sistema -->
                                <div class="system-info mt-4">
                                    <h5>📋 Acerca del Sistema</h5>
                                    <p class="mb-2">Plataforma integral para la gestión y seguimiento de trabajos de grado de la UTS.</p>
                                    <small> - 2025 - </small>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Panel de Credenciales -->
                        <div class="col-md-5">
                            <div class="credentials-panel h-100">
                                <h5 class="mb-4"></h5>
                                <p class="text-muted mb-4"></p>
                                
                                <!-- Administrador -->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">👑 Administrador</h6>
                                        <span class="badge bg-danger role-badge">Admin</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">admin@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">admin123</div>
                                    </div>
                                    <small class="text-muted">Acceso total al sistema</small>
                                </div>
                                
                                <!-- Coordinación -->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">🎯 Coordinación</h6>
                                        <span class="badge bg-primary role-badge">Coordinador</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">coordinacion@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">coord123</div>
                                    </div>
                                    <small class="text-muted">Gestión de anteproyectos</small>
                                </div>
                                
                                <!-- Director -->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">🧑‍🏫 Director</h6>
                                        <span class="badge bg-warning role-badge">Director</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">cmendoza@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">director123</div>
                                    </div>
                                    <small class="text-muted">Evaluación de proyectos</small>
                                </div>
                                
                                <!-- Evaluador 1-->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">⭐ Evaluador 1</h6>
                                        <span class="badge bg-info role-badge">Evaluador</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">alopez@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">evaluador123</div>
                                    </div>
                                    <small class="text-muted">Evaluación final</small>
                                </div>

                                <!-- Evaluador 2-->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">⭐ Evaluador 2</h6>
                                        <span class="badge bg-info role-badge">Evaluador</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">rsilva@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">evaluador123</div>
                                    </div>
                                    <small class="text-muted">Evaluación final</small>
                                </div>
                                
                                <!-- Estudiante 1 -->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">🎓 Estudiante 1</h6>
                                        <span class="badge bg-success role-badge">Estudiante</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">jperez@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">estudiante123</div>
                                    </div>
                                    <small class="text-muted">Gestión de proyectos</small>
                                </div>

                                <!-- Estudiante 2 -->
                                <div class="credential-item">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">🎓 Estudiante 2</h6>
                                        <span class="badge bg-success role-badge">Estudiante</span>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Email:</small>
                                        <div class="fw-bold text-primary">mgonzalez@uts.edu.co</div>
                                    </div>
                                    <div class="mb-2">
                                        <small class="text-muted">Contraseña:</small>
                                        <div class="fw-bold">estudiante123</div>
                                    </div>
                                    <small class="text-muted">Gestión de proyectos</small>
                                </div>
                                
                                <!-- Instrucciones -->
                               
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <div class="text-center mt-4">
                    <p class="text-white mb-0">
                        &copy; 2024 Unidad Tecnológica de Santander - Sistema de Gestión de Trabajos de Grado
                    </p>
                    <small class="text-white-50">Desarrollado por el Departamento de Sistemas</small>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Función para copiar credenciales al hacer clic
            const credentialItems = document.querySelectorAll('.credential-item');
            
            credentialItems.forEach(item => {
                item.addEventListener('click', function() {
                    const email = this.querySelector('.text-primary').textContent.trim();
                    const password = this.querySelector('.fw-bold:not(.text-primary)').textContent.trim();
                    
                    // Llenar automáticamente el formulario
                    document.getElementById('email').value = email;
                    document.getElementById('password').value = password;
                    
                    // Efecto visual de selección
                    credentialItems.forEach(i => i.style.borderColor = '#dee2e6');
                    this.style.borderColor = '#0056b3';
                    this.style.borderWidth = '2px';
                    
                    // Mostrar mensaje temporal
                    const originalText = this.querySelector('h6').textContent;
                    this.querySelector('h6').textContent = '✅ Credenciales copiadas!';
                    
                    setTimeout(() => {
                        this.querySelector('h6').textContent = originalText;
                    }, 1500);
                });
            });
            
            // Efecto de focus en inputs
            const inputs = document.querySelectorAll('.form-control');
            inputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.parentElement.parentElement.classList.add('focused');
                });
                
                input.addEventListener('blur', function() {
                    this.parentElement.parentElement.classList.remove('focused');
                });
            });
        });
    </script>
</body>
</html>