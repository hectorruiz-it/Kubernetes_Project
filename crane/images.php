<?php
	session_start();
	$username = $_SESSION['username'];
	echo $username;
	if ($username == '') {
		echo 'You are not allowed';
		session_destroy();
		header('Location: ../index.html');
	} else {
		echo 'welcome';
	}
?>
<!DOCTYPE html>
<html lang="en">

<head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="css/images.css">
        <title>CRANE</title>
</head>

<body>
        <header>
                <h1><a href="index.html">CRANE</a></h1>
                <div>
                        <a href="./connection.html">A Trabajar</a>
                        <a href="php/logout.php">Cerrar sesión</a>
                </div>
        </header>
        <section id="layout">
                <div class="image">
                        <a href="./alpine.html"><img src="img/icons/alpine.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./alpine.html">ALPINE</a>
                </div>
                <div class="image">
                        <a href="./ubuntu.html"><img src="img/icons/ubuntu.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./ubuntu.html">UBUNTU</a>
                </div>
                <div class="image">
                        <a href="./debian.html"><img src="img/icons/debian.png" alt="" srcset="" height="100px" width="auto"></a><br>    
                        <a href="./debian.html">DEBIAN</a> 
                </div>
                <div class="image">
                        <a href="./fedora.html"><img src="img/icons/fedora.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./fedora.html">FEDORA</a> </div>
                <div class="image">
                        <a href="./bash.html"><img src="img/icons/bash.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./bash.html">BASH</a> 
                </div>
                <div class="image">
                        <a href="./node.html"><img src="img/icons/node.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./node.html">NODEJS</a> 
                </div>
                <div class="image">
                        <a href="./python.html"><img src="img/icons/python.png" alt="" srcset="" height="100px" width="auto"> </a><br>
                        <a href="./python.html">PYTHON</a>
                </div>
                <div class="image">
                        <a href="./go.html"><img src="img/icons/golang.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./go.html">GOLANG</a>
                </div>
                <div class="image">
                        <a href="./mongo.html"><img src="img/icons/mongodb.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./mongo.html">MONGODB</a>
                </div>
                <div class="image">
                        <a href="./mariadb.html"><img src="img/icons/mariadb.svg" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./mariadb.html">MARIADB</a>
                </div>
                <div class="image">
                        <a href="./nginx.html"><img src="img/icons/nginx.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./nginx.html">NGINX</a>
                </div>
                <div class="image">
                        <a href="./apache.html"><img src="img/icons/apache.png" alt="" srcset="" height="100px" width="auto"></a><br>
                        <a href="./apache.html">HTTPD</a> 
                </div>
        </section>
</body>

</html>
