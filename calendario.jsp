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
    <title>Calendario Académico - UTS</title>
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
                    <h2>📅 Calendario Académico</h2>
                    <a href="dashboard.jsp" class="btn btn-secondary">← Volver al Dashboard</a>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">🗓️ Fechas Importantes</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Actividad</th>
                                        <th>Descripción</th>
                                        <th>Fecha Inicio</th>
                                        <th>Fecha Fin</th>
                                        <th>Tipo</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String sql = "SELECT titulo, descripcion, fecha_inicio, fecha_fin, tipo FROM calendario_academico WHERE activo = true ORDER BY fecha_inicio";
                                            pstmt = conn.prepareStatement(sql);
                                            rs = pstmt.executeQuery();
                                            
                                            java.util.Date hoy = new java.util.Date();
                                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
                                            
                                            while (rs.next()) {
                                                String fechaInicio = rs.getString("fecha_inicio");
                                                String fechaFin = rs.getString("fecha_fin");
                                                String estado = "Próximo";
                                                String badgeClass = "bg-secondary";
                                                
                                                if (hoy.after(sdf.parse(fechaInicio)) && hoy.before(sdf.parse(fechaFin))) {
                                                    estado = "En Curso";
                                                    badgeClass = "bg-success";
                                                } else if (hoy.after(sdf.parse(fechaFin))) {
                                                    estado = "Finalizado";
                                                    badgeClass = "bg-danger";
                                                }
                                    %>
                                    <tr>
                                        <td><strong><%= rs.getString("titulo") %></strong></td>
                                        <td><%= rs.getString("descripcion") %></td>
                                        <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(sdf.parse(fechaInicio)) %></td>
                                        <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(sdf.parse(fechaFin)) %></td>
                                        <td>
                                            <span class="badge 
                                                <%= "grado".equals(rs.getString("tipo")) ? "bg-primary" : 
                                                   "academico".equals(rs.getString("tipo")) ? "bg-info" : "bg-secondary" %>">
                                                <%= rs.getString("tipo") %>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="badge <%= badgeClass %>"><%= estado %></span>
                                        </td>
                                    </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='6' class='text-center text-danger'>Error al cargar el calendario: " + e.getMessage() + "</td></tr>");
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

                <!-- Información adicional -->
                <div class="row mt-4">
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-info text-white">
                                <h6 class="mb-0">ℹ️ Información Importante</h6>
                            </div>
                            <div class="card-body">
                                <ul>
                                    <li>Las fechas están sujetas a cambios según disposición de la institución</li>
                                    <li>Para solicitudes especiales contactar a coordinación</li>
                                    <li>Verificar frecuentemente las actualizaciones del calendario</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="card">
                            <div class="card-header bg-warning text-white">
                                <h6 class="mb-0">📞 Contacto</h6>
                            </div>
                            <div class="card-body">
                                <p><strong>Coordinación de Trabajos de Grado</strong></p>
                                <p>Email: coordinacion.grado@uts.edu.co</p>
                                <p>Teléfono: (601) 123-4567</p>
                                <p>Horario: Lunes a Viernes 8:00 AM - 6:00 PM</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>