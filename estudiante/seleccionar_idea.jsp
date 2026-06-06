<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    Integer usuarioId = (Integer) session.getAttribute("usuario_id");
    if (usuarioRol == null || !"estudiante".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Seleccionar Idea de Proyecto - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Estudiante)
                </span>
                <a class="nav-link" href="../logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>💡 Seleccionar Idea de Proyecto</h2>
                    <div>
                        <a href="mis_anteproyectos.jsp" class="btn btn-secondary">📚 Mis Proyectos</a>
                        <a href="subir_anteproyecto.jsp" class="btn btn-success">📤 Subir Anteproyecto</a>
                    </div>
                </div>

                <div class="alert alert-info">
                    <h5>📋 Instrucciones</h5>
                    <p>Selecciona una de las ideas de proyecto disponibles o crea tu propia idea. Una vez seleccionada, podrás desarrollar el anteproyecto completo.</p>
                </div>

                <!-- Ideas de proyecto disponibles -->
                <div class="row">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-primary text-white">
                                <h5 class="mb-0">🎯 Ideas Disponibles</h5>
                            </div>
                            <div class="card-body">
                                <div class="list-group">
                                    <div class="list-group-item">
                                        <h6>🤖 Sistema de Gestión Académica</h6>
                                        <p class="mb-1">Desarrollo de plataforma web para gestión integral de procesos académicos.</p>
                                        <small class="text-muted">Área: Ingeniería de Software</small>
                                        <div class="mt-2">
                                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalIdeas">Seleccionar</button>
                                        </div>
                                    </div>
                                    
                                    <div class="list-group-item">
                                        <h6>🏥 IA para Diagnóstico Médico</h6>
                                        <p class="mb-1">Aplicación de inteligencia artificial en diagnóstico asistido por imágenes médicas.</p>
                                        <small class="text-muted">Área: Inteligencia Artificial</small>
                                        <div class="mt-2">
                                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalIdeas">Seleccionar</button>
                                        </div>
                                    </div>
                                    
                                    <div class="list-group-item">
                                        <h6>📱 App Móvil para Agricultura</h6>
                                        <p class="mb-1">Desarrollo de aplicación móvil para optimización de procesos agrícolas.</p>
                                        <small class="text-muted">Área: Desarrollo Móvil</small>
                                        <div class="mt-2">
                                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalIdeas">Seleccionar</button>
                                        </div>
                                    </div>
                                    
                                    <div class="list-group-item">
                                        <h6>🌐 Plataforma E-learning</h6>
                                        <p class="mb-1">Sistema de aprendizaje en línea con herramientas interactivas.</p>
                                        <small class="text-muted">Área: Educación Digital</small>
                                        <div class="mt-2">
                                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalIdeas">Seleccionar</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0">✨ Crear Mi Propia Idea</h5>
                            </div>
                            <div class="card-body">
                                <form action="procesar_idea.jsp" method="POST">
                                    <div class="mb-3">
                                        <label class="form-label">Título de la Idea *</label>
                                        <input type="text" class="form-control" name="titulo_idea" required 
                                               placeholder="Ej: Sistema de Gestión para Biblioteca">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Descripción *</label>
                                        <textarea class="form-control" name="descripcion_idea" rows="4" required 
                                                  placeholder="Describe detalladamente tu idea de proyecto..."></textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Área de Conocimiento *</label>
                                        <select class="form-select" name="area" required>
                                            <option value="">Seleccionar área</option>
                                            <option value="ingenieria_software">Ingeniería de Software</option>
                                            <option value="inteligencia_artificial">Inteligencia Artificial</option>
                                            <option value="desarrollo_movil">Desarrollo Móvil</option>
                                            <option value="base_datos">Base de Datos</option>
                                            <option value="redes">Redes y Telecomunicaciones</option>
                                            <option value="seguridad">Seguridad Informática</option>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Tecnologías Propuestas</label>
                                        <input type="text" class="form-control" name="tecnologias" 
                                               placeholder="Ej: Java, MySQL, React, Node.js">
                                    </div>
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-success">💡 Guardar Mi Idea</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Mis ideas guardadas -->
                        <div class="card mt-4">
                            <div class="card-header bg-info text-white">
                                <h5 class="mb-0">📓 Mis Ideas Guardadas</h5>
                            </div>
                            <div class="card-body">
                                <%
                                    try {
                                        // Verificar si el estudiante ya tiene ideas guardadas
                                        String sql = "SELECT COUNT(*) as total FROM anteproyectos WHERE estudiante_id = ?";
                                        pstmt = conn.prepareStatement(sql);
                                        pstmt.setInt(1, usuarioId);
                                        rs = pstmt.executeQuery();
                                        if (rs.next() && rs.getInt("total") > 0) {
                                %>
                                <div class="alert alert-warning">
                                    <p>Ya tienes <strong><%= rs.getInt("total") %> proyecto(s)</strong> en desarrollo.</p>
                                    <a href="mis_anteproyectos.jsp" class="btn btn-sm btn-warning">Ver Mis Proyectos</a>
                                </div>
                                <%
                                        } else {
                                %>
                                <p class="text-muted">Aún no has creado proyectos. Selecciona una idea o crea la tuya propia.</p>
                                <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<p class='text-danger'>Error al cargar información</p>");
                                    } finally {
                                        if (rs != null) rs.close();
                                        if (pstmt != null) pstmt.close();
                                        if (conn != null) conn.close();
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal para selección de ideas -->
    <div class="modal fade" id="modalIdeas" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">💡 Confirmar Selección</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>¿Estás seguro de que quieres seleccionar esta idea de proyecto?</p>
                    <p><strong>Una vez seleccionada, serás redirigido para completar el anteproyecto.</strong></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <a href="subir_anteproyecto.jsp?idea=seleccionada" class="btn btn-primary">✅ Seleccionar Idea</a>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>