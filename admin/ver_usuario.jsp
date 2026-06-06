<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="../includes/conexion.jspf" %>
<%
    // Verificar sesión y rol
    String usuarioRol = (String) session.getAttribute("usuario_rol");
    if (usuarioRol == null || !"administrador".equals(usuarioRol)) {
        response.sendRedirect("../index.jsp");
        return;
    }

    String id = request.getParameter("id");
    if (id == null) {
        response.sendRedirect("usuarios.jsp");
        return;
    }

    // Cargar datos del usuario
    String codigo = "", nombre = "", email = "", rol = "", estado = "", telefono = "", programa = "", fechaCreacion = "";
    
    try {
        String sql = "SELECT codigo, nombre, email, rol, estado, telefono, programa_academico, fecha_creacion FROM usuarios WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, id);
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            codigo = rs.getString("codigo");
            nombre = rs.getString("nombre");
            email = rs.getString("email");
            rol = rs.getString("rol");
            estado = rs.getString("estado");
            telefono = rs.getString("telefono");
            programa = rs.getString("programa_academico");
            fechaCreacion = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("fecha_creacion"));
        } else {
            response.sendRedirect("usuarios.jsp");
            return;
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error: " + e.getMessage() + "</div>");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ver Usuario - UTS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-info text-white">
                        <h4 class="mb-0">👁️ Detalles del Usuario</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <h5>Información Personal</h5>
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Código:</th>
                                        <td><strong><%= codigo %></strong></td>
                                    </tr>
                                    <tr>
                                        <th>Nombre:</th>
                                        <td><%= nombre %></td>
                                    </tr>
                                    <tr>
                                        <th>Email:</th>
                                        <td><%= email %></td>
                                    </tr>
                                    <tr>
                                        <th>Teléfono:</th>
                                        <td><%= telefono != null ? telefono : "N/A" %></td>
                                    </tr>
                                </table>
                            </div>
                            <div class="col-md-6">
                                <h5>Información Académica</h5>
                                <table class="table table-bordered">
                                    <tr>
                                        <th>Rol:</th>
                                        <td>
                                            <span class="badge 
                                                <%= "administrador".equals(rol) ? "bg-danger" : 
                                                   "coordinacion".equals(rol) ? "bg-primary" :
                                                   "director".equals(rol) ? "bg-warning" :
                                                   "evaluador".equals(rol) ? "bg-info" : "bg-success" %>">
                                                <%= rol %>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Estado:</th>
                                        <td>
                                            <span class="badge <%= "activo".equals(estado) ? "bg-success" : "bg-danger" %>">
                                                <%= estado %>
                                            </span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Programa:</th>
                                        <td><%= programa != null ? programa : "N/A" %></td>
                                    </tr>
                                    <tr>
                                        <th>Fecha Registro:</th>
                                        <td><%= fechaCreacion %></td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                        
                        <div class="mt-4">
                            <h5>Estadísticas</h5>
                            <div class="row">
                                <%
                                    try {
                                        // Contar anteproyectos si es estudiante
                                        if ("estudiante".equals(rol)) {
                                            String sqlCount = "SELECT COUNT(*) as total FROM anteproyectos WHERE estudiante_id = ?";
                                            pstmt = conn.prepareStatement(sqlCount);
                                            pstmt.setString(1, id);
                                            ResultSet rsCount = pstmt.executeQuery();
                                            if (rsCount.next()) {
                                %>
                                <div class="col-md-4">
                                    <div class="card text-white bg-primary">
                                        <div class="card-body text-center">
                                            <h4><%= rsCount.getInt("total") %></h4>
                                            <p>Anteproyectos</p>
                                        </div>
                                    </div>
                                </div>
                                <%
                                            }
                                        }
                                        
                                        // Contar proyectos dirigidos si es director
                                        if ("director".equals(rol)) {
                                            String sqlCount = "SELECT COUNT(*) as total FROM anteproyectos WHERE director_id = ?";
                                            pstmt = conn.prepareStatement(sqlCount);
                                            pstmt.setString(1, id);
                                            ResultSet rsCount = pstmt.executeQuery();
                                            if (rsCount.next()) {
                                %>
                                <div class="col-md-4">
                                    <div class="card text-white bg-warning">
                                        <div class="card-body text-center">
                                            <h4><%= rsCount.getInt("total") %></h4>
                                            <p>Proyectos Dirigidos</p>
                                        </div>
                                    </div>
                                </div>
                                <%
                                            }
                                        }
                                    } catch (Exception e) {
                                        // Ignorar errores en estadísticas
                                    }
                                %>
                            </div>
                        </div>
                        
                        <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                            <a href="usuarios.jsp" class="btn btn-secondary me-md-2">← Volver</a>
                            <a href="editar_usuario.jsp?id=<%= id %>" class="btn btn-warning me-md-2">✏️ Editar</a>
                            <a href="eliminar_usuario.jsp?id=<%= id %>" class="btn btn-danger" 
                               onclick="return confirm('¿Está seguro de eliminar al usuario <%= nombre %>?')">🗑️ Eliminar</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>