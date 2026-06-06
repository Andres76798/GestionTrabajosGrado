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

    String id = request.getParameter("id");
    if (id == null) {
        response.sendRedirect("mis_anteproyectos.jsp");
        return;
    }

    // Cargar datos del anteproyecto
    String titulo = "", descripcion = "", objetivoGeneral = "", objetivosEspecificos = "", justificacion = "", metodologia = "";
    String estado = "", directorNombre = "", evaluadorNombre = "";
    
    try {
        String sql = "SELECT a.titulo, a.descripcion, a.objetivo_general, a.objetivos_especificos, a.justificacion, a.metodologia, " +
                   "a.estado, d.nombre as director, ev.nombre as evaluador " +
                   "FROM anteproyectos a " +
                   "LEFT JOIN usuarios d ON a.director_id = d.id " +
                   "LEFT JOIN usuarios ev ON a.evaluador_id = ev.id " +
                   "WHERE a.id = ? AND a.estudiante_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        pstmt.setInt(2, usuarioId);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            titulo = rs.getString("titulo");
            descripcion = rs.getString("descripcion");
            objetivoGeneral = rs.getString("objetivo_general");
            objetivosEspecificos = rs.getString("objetivos_especificos");
            justificacion = rs.getString("justificacion");
            metodologia = rs.getString("metodologia");
            estado = rs.getString("estado");
            directorNombre = rs.getString("director");
            evaluadorNombre = rs.getString("evaluador");
        } else {
            response.sendRedirect("mis_anteproyectos.jsp?error=1");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }

    // Procesar actualización
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        titulo = request.getParameter("titulo");
        descripcion = request.getParameter("descripcion");
        objetivoGeneral = request.getParameter("objetivo_general");
        objetivosEspecificos = request.getParameter("objetivos_especificos");
        justificacion = request.getParameter("justificacion");
        metodologia = request.getParameter("metodologia");
        
        try {
            // Solo permitir edición si está en estado borrador
            if ("borrador".equals(estado)) {
                String sql = "UPDATE anteproyectos SET titulo = ?, descripcion = ?, objetivo_general = ?, " +
                           "objetivos_especificos = ?, justificacion = ?, metodologia = ? " +
                           "WHERE id = ? AND estudiante_id = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, titulo);
                pstmt.setString(2, descripcion);
                pstmt.setString(3, objetivoGeneral);
                pstmt.setString(4, objetivosEspecificos);
                pstmt.setString(5, justificacion);
                pstmt.setString(6, metodologia);
                pstmt.setString(7, id);
                pstmt.setInt(8, usuarioId);
                
                int result = pstmt.executeUpdate();
                if (result > 0) {
                    response.sendRedirect("mis_anteproyectos.jsp?mensaje=2");
                    return;
                }
            } else {
                out.println("<div class='alert alert-warning'>No puedes editar un proyecto que ya está en revisión.</div>");
            }
        } catch (Exception e) {
            out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Editar Anteproyecto - Estudiante</title>
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
                    <h2>✏️ Editar Mi Anteproyecto</h2>
                    <div>
                        <a href="mis_anteproyectos.jsp" class="btn btn-secondary">← Volver</a>
                        <a href="ver_anteproyecto.jsp?id=<%= id %>" class="btn btn-info">👁️ Ver</a>
                    </div>
                </div>

                <!-- Información del Estado -->
                <div class="card mb-4">
                    <div class="card-header 
                        <%= "borrador".equals(estado) ? "bg-warning" : 
                           "en_revision".equals(estado) ? "bg-info" : 
                           "aprobado_director".equals(estado) ? "bg-primary" : 
                           "aprobado_evaluador".equals(estado) ? "bg-success" : "bg-danger" %> text-white">
                        <h5 class="mb-0">📊 Estado Actual del Proyecto</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Estado:</th>
                                        <td>
                                            <span class="badge 
                                                <%= "borrador".equals(estado) ? "bg-warning" : 
                                                   "en_revision".equals(estado) ? "bg-info" : 
                                                   "aprobado_director".equals(estado) ? "bg-primary" : 
                                                   "aprobado_evaluador".equals(estado) ? "bg-success" : "bg-danger" %>">
                                                <%= estado %>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Director:</th>
                                        <td><%= directorNombre != null ? directorNombre : "<span class='text-muted'>No asignado</span>" %></td>
                                    </tr>
                                    <tr>
                                        <th>Evaluador:</th>
                                        <td><%= evaluadorNombre != null ? evaluadorNombre : "<span class='text-muted'>No asignado</span>" %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <%
                                    if (!"borrador".equals(estado)) {
                                %>
                                <div class="alert alert-warning">
                                    <h6>⚠️ Restricciones de Edición</h6>
                                    <p class="mb-0">No puedes editar este proyecto porque ya está <strong><%= estado %></strong>.</p>
                                    <p class="mb-0">Solo los proyectos en estado <strong>"borrador"</strong> pueden ser editados.</p>
                                </div>
                                <%
                                    } else {
                                %>
                                <div class="alert alert-info">
                                    <h6>💡 Información</h6>
                                    <p class="mb-0">Puedes editar libremente tu proyecto mientras esté en estado <strong>"borrador"</strong>.</p>
                                    <p class="mb-0">Una vez enviado a revisión, no podrás modificarlo.</p>
                                </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </div>

                <form method="POST" <%= !"borrador".equals(estado) ? "onsubmit='return false;'" : "" %>>
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">📝 Información del Anteproyecto</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label">Título del Anteproyecto *</label>
                                <input type="text" class="form-control" name="titulo" value="<%= titulo %>" 
                                       <%= !"borrador".equals(estado) ? "readonly" : "required" %>>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Descripción General *</label>
                                <textarea class="form-control" name="descripcion" rows="4" 
                                          <%= !"borrador".equals(estado) ? "readonly" : "required" %>><%= descripcion != null ? descripcion : "" %></textarea>
                                <div class="form-text">Describe de manera clara y concisa tu proyecto de grado.</div>
                            </div>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0">🎯 Objetivos del Proyecto</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label">Objetivo General *</label>
                                <textarea class="form-control" name="objetivo_general" rows="3" 
                                          <%= !"borrador".equals(estado) ? "readonly" : "required" %>><%= objetivoGeneral != null ? objetivoGeneral : "" %></textarea>
                                <div class="form-text">Define el objetivo principal que quieres alcanzar con tu proyecto.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Objetivos Específicos *</label>
                                <textarea class="form-control" name="objetivos_especificos" rows="4" 
                                          <%= !"borrador".equals(estado) ? "readonly" : "required" %>><%= objetivosEspecificos != null ? objetivosEspecificos : "" %></textarea>
                                <div class="form-text">Lista los objetivos específicos que te permitirán alcanzar el objetivo general (uno por línea).</div>
                            </div>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-header bg-info text-white">
                            <h5 class="mb-0">💡 Justificación y Metodología</h5>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <label class="form-label">Justificación *</label>
                                <textarea class="form-control" name="justificacion" rows="4" 
                                          <%= !"borrador".equals(estado) ? "readonly" : "required" %>><%= justificacion != null ? justificacion : "" %></textarea>
                                <div class="form-text">Explica por qué es importante desarrollar este proyecto y qué problemática resuelve.</div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Metodología *</label>
                                <textarea class="form-control" name="metodologia" rows="4" 
                                          <%= !"borrador".equals(estado) ? "readonly" : "required" %>><%= metodologia != null ? metodologia : "" %></textarea>
                                <div class="form-text">Describe la metodología que utilizarás para desarrollar el proyecto (ágil, tradicional, etc.).</div>
                            </div>
                        </div>
                    </div>

                    <div class="card mt-4">
                        <div class="card-body">
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <a href="mis_anteproyectos.jsp" class="btn btn-secondary me-md-2">❌ Cancelar</a>
                                <%
                                    if ("borrador".equals(estado)) {
                                %>
                                <button type="submit" class="btn btn-primary">✅ Guardar Cambios</button>
                                <%
                                    } else {
                                %>
                                <button type="button" class="btn btn-primary" disabled>❌ No Editable</button>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                </form>

                <!-- Información adicional -->
                <div class="card mt-4">
                    <div class="card-header bg-light">
                        <h6 class="mb-0">📋 Información Adicional</h6>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h6>📅 Próximos Pasos</h6>
                                <ul>
                                    <li>Completa todos los campos obligatorios (*)</li>
                                    <li>Guarda los cambios mientras esté en estado "borrador"</li>
                                    <li>Una vez listo, solicita la revisión a coordinación</li>
                                    <li>Revisa frecuentemente las observaciones de los evaluadores</li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <h6>📞 Contacto</h6>
                                <p>Si necesitas ayuda con tu anteproyecto:</p>
                                <ul>
                                    <li>Contacta a tu director asignado</li>
                                    <li>Visita coordinación de trabajos de grado</li>
                                    <li>Consulta el calendario académico</li>
                                    <li>Revisa los formatos oficiales</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Deshabilitar envío del formulario si no está en borrador
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector('form');
            if (form.hasAttribute('onsubmit')) {
                const inputs = form.querySelectorAll('input, textarea, select');
                inputs.forEach(input => {
                    if (input.readOnly) {
                        input.style.backgroundColor = '#f8f9fa';
                        input.style.cursor = 'not-allowed';
                    }
                });
            }
        });
    </script>
</body>
</html>