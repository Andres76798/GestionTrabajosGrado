<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"administrador".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="../assets/css/style.css" rel="stylesheet">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.jsp">UTS - Trabajos de Grado</a>
            <div class="navbar-nav ms-auto">
                <span class="navbar-text me-3">
                    <%= session.getAttribute("usuario_nombre") %> (Administrador)
                </span>
                <a class="nav-link" href="../logout.jsp">Cerrar Sesión</a>
            </div>
        </div>
    </nav>

    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>📊 Gestión de Usuarios</h2>
                    <div>
                        <a href="crear_usuario.jsp" class="btn btn-success">➕ Nuevo Usuario</a>
                        <a href="../calendario.jsp" class="btn btn-info">📅 Calendario</a>
                        <a href="../formatos.jsp" class="btn btn-secondary">📋 Formatos</a>
                    </div>
                </div>

                <%
                    String mensaje = request.getParameter("mensaje");
                    if (mensaje != null) {
                %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <%= "1".equals(mensaje) ? "✅ Usuario creado exitosamente" : 
                           "2".equals(mensaje) ? "✏️ Usuario actualizado exitosamente" :
                           "3".equals(mensaje) ? "🗑️ Usuario eliminado exitosamente" : "" %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <%
                    }
                %>

                <!-- Filtros -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">🔍 Filtros de Búsqueda</h5>
                    </div>
                    <div class="card-body">
                        <form method="GET" class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Rol</label>
                                <select class="form-select" name="rol">
                                    <option value="">Todos los roles</option>
                                    <option value="estudiante">Estudiante</option>
                                    <option value="director">Director</option>
                                    <option value="evaluador">Evaluador</option>
                                    <option value="coordinacion">Coordinación</option>
                                    <option value="administrador">Administrador</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Estado</label>
                                <select class="form-select" name="estado">
                                    <option value="">Todos los estados</option>
                                    <option value="activo">Activo</option>
                                    <option value="inactivo">Inactivo</option>
                                </select>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Buscar</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" name="busqueda" placeholder="Código, nombre o email">
                                    <button type="submit" class="btn btn-primary">Buscar</button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h5 class="mb-0">👥 Lista de Usuarios Registrados</h5>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead class="table-dark">
                                    <tr>
                                        <th>Código</th>
                                        <th>Nombre Completo</th>
                                        <th>Email</th>
                                        <th>Rol</th>
                                        <th>Programa</th>
                                        <th>Teléfono</th>
                                        <th>Estado</th>
                                        <th>Fecha Registro</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try {
                                            String filtroRol = request.getParameter("rol");
                                            String filtroEstado = request.getParameter("estado");
                                            String busqueda = request.getParameter("busqueda");
                                            
                                            StringBuilder sql = new StringBuilder(
                                                "SELECT id, codigo, nombre, email, rol, estado, telefono, programa_academico, fecha_creacion " +
                                                "FROM usuarios WHERE 1=1"
                                            );
                                            
                                            if (filtroRol != null && !filtroRol.isEmpty()) {
                                                sql.append(" AND rol = ?");
                                            }
                                            if (filtroEstado != null && !filtroEstado.isEmpty()) {
                                                sql.append(" AND estado = ?");
                                            }
                                            if (busqueda != null && !busqueda.isEmpty()) {
                                                sql.append(" AND (codigo LIKE ? OR nombre LIKE ? OR email LIKE ?)");
                                            }
                                            sql.append(" ORDER BY fecha_creacion DESC");
                                            
                                            pstmt = conn.prepareStatement(sql.toString());
                                            int paramIndex = 1;
                                            
                                            if (filtroRol != null && !filtroRol.isEmpty()) {
                                                pstmt.setString(paramIndex++, filtroRol);
                                            }
                                            if (filtroEstado != null && !filtroEstado.isEmpty()) {
                                                pstmt.setString(paramIndex++, filtroEstado);
                                            }
                                            if (busqueda != null && !busqueda.isEmpty()) {
                                                String likeParam = "%" + busqueda + "%";
                                                pstmt.setString(paramIndex++, likeParam);
                                                pstmt.setString(paramIndex++, likeParam);
                                                pstmt.setString(paramIndex++, likeParam);
                                            }
                                            
                                            rs = pstmt.executeQuery();
                                            
                                            while (rs.next()) {
                                    %>
                                        <tr>
                                            <td><strong><%= rs.getString("codigo") != null ? rs.getString("codigo") : "N/A" %></strong></td>
                                            <td>
                                                <div><strong><%= rs.getString("nombre") %></strong></div>
                                                <small class="text-muted">ID: <%= rs.getInt("id") %></small>
                                            </td>
                                            <td><%= rs.getString("email") %></td>
                                            <td>
                                                <span class="badge 
                                                    <%= "administrador".equals(rs.getString("rol")) ? "bg-danger" : 
                                                       "coordinacion".equals(rs.getString("rol")) ? "bg-primary" :
                                                       "director".equals(rs.getString("rol")) ? "bg-warning" :
                                                       "evaluador".equals(rs.getString("rol")) ? "bg-info" : "bg-success" %>">
                                                    <%= rs.getString("rol") %>
                                                </span>
                                            </td>
                                            <td><%= rs.getString("programa_academico") != null ? rs.getString("programa_academico") : "N/A" %></td>
                                            <td><%= rs.getString("telefono") != null ? rs.getString("telefono") : "N/A" %></td>
                                            <td>
                                                <span class="badge <%= "activo".equals(rs.getString("estado")) ? "bg-success" : "bg-danger" %>">
                                                    <%= rs.getString("estado") %>
                                                </span>
                                            </td>
                                            <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(rs.getTimestamp("fecha_creacion")) %></td>
                                            <td>
                                                <div class="btn-group btn-group-sm">
                                                    <a href="ver_usuario.jsp?id=<%= rs.getInt("id") %>" class="btn btn-info" title="Ver detalles">👁️</a>
                                                    <a href="editar_usuario.jsp?id=<%= rs.getInt("id") %>" class="btn btn-warning" title="Editar">✏️</a>
                                                    <a href="eliminar_usuario.jsp?id=<%= rs.getInt("id") %>" class="btn btn-danger" title="Eliminar" 
                                                       onclick="return confirm('¿Está seguro de eliminar al usuario <%= rs.getString("nombre") %>?')">🗑️</a>
                                                </div>
                                            </td>
                                        </tr>
                                    <%
                                            }
                                        } catch (Exception e) {
                                            out.println("<tr><td colspan='9' class='text-danger text-center'>Error: " + e.getMessage() + "</td></tr>");
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
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>