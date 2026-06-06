<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="includes/conexion.jspf" %>
<%
    // Verificar sesión
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Formatos de Grado - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (<%= session.getAttribute("usuario_rol") %>)
                </span>
                <a class="nav-link" href="logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>📋 Formatos de Grado</h2>
                    <a href="dashboard.jsp" class="btn btn-secondary">← Volver al Dashboard</a>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">📄 Formatos Disponibles</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Formato</th>
                                        <th>Descripción</th>
                                        <th>Tipo</th>
                                        <th>Fecha Publicación</th>
                                        <th>Descargar</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String sql = "SELECT nombre, descripcion, archivo, tipo, fecha_creacion FROM formatos_grado WHERE activo = true ORDER BY tipo, fecha_creacion DESC";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            
                                            while (rs.next()) {
                                    %>
                                    <tr>
                                        <td><strong><%= rs.getString("nombre") %></strong></td>
                                        <td><%= rs.getString("descripcion") %></td>
                                        <td>
                                            <span class="badge 
                                                <%= "anteproyecto".equals(rs.getString("tipo")) ? "bg-primary" : 
                                                   "trabajo_grado".equals(rs.getString("tipo")) ? "bg-success" : "bg-secondary" %>">
                                                <%= rs.getString("tipo") %>
                                            </span>
                                        </td>
                                        <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion")) %></td>
                                        <td>
                                            <%
                                                if (rs.getString("archivo") != null && !rs.getString("archivo").isEmpty()) {
                                            %>
                                            <a href="../formatos/<%= rs.getString("archivo") %>" class="btn btn-success btn-sm" download>
                                                📥 Descargar
                                            </a>
                                            <%
                                                } else {
                                            %>
                                            <span class="text-muted">No disponible</span>
                                            <%
                                                }
                                            %>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='5' class='text-center text-danger'>Error al cargar los formatos: " + e.getMessage() + "</td></tr>");
                                        } finally {
                                            if (rs != null) rs.close();
                                            if (pstmt != null) pstmt.close();
                                            if (conn != null) conn.close();
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Instrucciones -->
                <div class="row mt-4">
                    <div class="col-md-8">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">📝 Instrucciones para el Uso de Formatos</h6>
                            </div>
                            <div class="card-body">
                                <h6>Formato de Anteproyecto:</h6>
                                <ul>
                                    <li>Diligenciar todos los campos obligatorios marcados con (*)</li>
                                    <li>Utilizar letra Arial 12 puntos</li>
                                    <li>Márgenes: 3 cm superior e inferior, 2.5 cm izquierdo y derecho</li>
                                    <li>El documento no debe exceder las 20 páginas</li>
                                </ul>
                                
                                <h6>Formato de Trabajo de Grado:</h6>
                                <ul>
                                    <li>Seguir la estructura IMRaD (Introducción, Métodos, Resultados, Discusión)</li>
                                    <li>Incluir resumen en español e inglés</li>
                                    <li>Las referencias deben seguir normas APA 7ma edición</li>
                                    <li>Máximo 80 páginas incluyendo anexos</li>
                                </ul>
                                
                                <h6>Guía Metodológica:</h6>
                                <ul>
                                    <li>Consultar antes de iniciar la elaboración del trabajo</li>
                                    <li>Seguir las recomendaciones según el tipo de investigación</li>
                                    <li>Verificar los requisitos específicos de cada programa</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">⚠️ Recomendaciones</h6>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-warning">
                                    <strong>Importante:</strong>
                                    <ul class="mb-0 mt-2">
                                        <li>Guardar copia de seguridad del documento</li>
                                        <li>Revisar ortografía y gramática</li>
                                        <li>Verificar que todas las secciones estén completas</li>
                                        <li>Confirmar con el director antes de enviar</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>