############# VPC ##############
resource "aws_vpc" "VPC_LaboratorioITM_Terraform" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "VPC_LaboratorioITM_Terraform"
  }
}

############# Subnets #############

resource "aws_subnet" "SUBNET_LaboratorioITM_Public" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_public_cidr}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Public"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

resource "aws_subnet" "SUBNET_LaboratorioITM_Public2" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_public2_cidr}"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Public2"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

resource "aws_subnet" "SUBNET_LaboratorioITM_Private" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_private_cidr}"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Private"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

resource "aws_subnet" "SUBNET_LaboratorioITM_Private2" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  cidr_block = "${var.subnet_private2_cidr}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "SUBNET_LaboratorioITM_Private2"
    "Env" = "LAB"
  }
  depends_on = [
    aws_vpc.VPC_LaboratorioITM_Terraform
  ]
}

############# Public Subnet Network ACL #############

resource "aws_network_acl" "NACL_Public_Subnet_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  subnet_ids = [aws_subnet.SUBNET_LaboratorioITM_Public.id,aws_subnet.SUBNET_LaboratorioITM_Public2.id]

  egress {
    rule_no      = 100
    action       = "allow"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_block   = "0.0.0.0/0"
  }

  ingress {
    rule_no      = 100
    action       = "allow"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_block   =  "${var.vpc_cidr}" # IP local de la vpc
  }

    ingress {
    rule_no      = 200
    action       = "allow"
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_block   = "0.0.0.0/0"  # trafico http desde cualquier lugar en puerto 80
  }

  ingress {
    rule_no      = 300
    action       = "allow"
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_block  = "${var.public_ip}" # ip publica para tener acceso a la instancia EC2
  }

  ingress {
    rule_no      = 400
    action       = "allow"
    from_port    = 1025
    to_port      = 65535
    protocol     = "tcp"  # trafico TCP
    cidr_block   = "0.0.0.0/0"
  }

  tags = {
    Name = "NACL_Public_Subnet"
  }
}

############# Private Subnet Network ACL #############
resource "aws_network_acl" "NACL_Private_Subnet_Terraform" {
  vpc_id     = aws_vpc.VPC_LaboratorioITM_Terraform.id
  subnet_ids = [aws_subnet.SUBNET_LaboratorioITM_Private.id,aws_subnet.SUBNET_LaboratorioITM_Private2.id]

  egress {
    rule_no      = 100
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "0.0.0.0/0"
  }

  ingress {
    rule_no      = 100
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "${var.vpc_cidr}" # IP local de la vpc
  }

  ingress {
    rule_no      = 200
    action      = "allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_block  = "${var.public_ip}" # ip publica para tener acceso a la RDS
  }

  tags = {
    Name = "NACL_Private_Subnet"
  }
}





############# Webserver Security Group #############

resource "aws_security_group" "SG_WebServer_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id

    ingress {
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]  
  }

    ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["${var.public_ip}"] 
  }
  
ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks   =  ["${var.vpc_cidr}"] 
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_Webserver_Terraform"
  }
}

############# RDS Security Group #############

resource "aws_security_group" "SG_RDS_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id

    ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["${var.public_ip}"] 
  }
  
ingress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks   =  ["${var.vpc_cidr}"] 
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_RDS_Terraform"
  }
}


############# Internet Gateway #############

resource "aws_internet_gateway" "IG_ITMLab_Terraform" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id

    tags = {
    Name = "IG_ITMLab_Terraform"
  }
}

############# Route Table #############
resource "aws_route_table" "RT_ITMIaC_VSCode" {
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG_ITMLab_Terraform.id
  }
 depends_on = [aws_internet_gateway.IG_ITMLab_Terraform]

     tags = {
    Name = "RT_ITMLab_Terraform"
  }
}

resource "aws_main_route_table_association" "RT_Asociation" {
  route_table_id = aws_route_table.RT_ITMIaC_VSCode.id 
  vpc_id = aws_vpc.VPC_LaboratorioITM_Terraform.id
}


############# RDS Subnet Group #############

resource "aws_db_subnet_group" "SNG_TerraformDB" {
  name       = var.rds_db_subnet_group_name
  subnet_ids = [
    aws_subnet.SUBNET_LaboratorioITM_Private.id, aws_subnet.SUBNET_LaboratorioITM_Private2.id
  ]
    tags = {
    Name = "TerraformDBSubnetGroup"
  }
}


############# RDS MySQL #############

resource "aws_db_instance" "RDS_TerraformDB" {
  identifier           = "${var.rds_identifier}"
  allocated_storage    = "${var.rds_allocated_storage}"
  engine               = "${var.rds_engine}"
  engine_version       = "${var.rds_engine_version}"
  instance_class       = "${var.rds_instance_class}"
  username             = "${var.rds_username}"
  password             = "${var.rds_password}"
  db_subnet_group_name = aws_db_subnet_group.SNG_TerraformDB.name
  vpc_security_group_ids = [aws_security_group.SG_RDS_Terraform.id]
  multi_az             = "${var.rds_multi_az}"
  publicly_accessible  = "${var.rds_publicly_accessible}"
  skip_final_snapshot  = true
}


############# EC2 Joomla Instance #############

resource "aws_instance" "EC2_Terraform_Lab_1_VSCode" {
  ami = "${var.ec2_terraform_ami}"
  instance_type = "${var.ec2_joomla_instance_type}"
  count = "${var.ec2_terraform_instance_quantity}"
  subnet_id = aws_subnet.SUBNET_LaboratorioITM_Public.id
  key_name = "${var.aws_keypair}"
  security_groups = [aws_security_group.SG_WebServer_Terraform.id]
  tags = {
    Name = "${var.ec2_terraform_instance_name}"
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
amazon-linux-extras enable php8.1
yum clean metadata
yum install -y php php-common php-pear
yum install -y php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip}
mkdir /var/www/html/myapp
cd /var/www/html/myapp
    echo '<!DOCTYPE html>
    <head>
        <title>Cell-Land</title>
        <link rel="stylesheet" type="text/css" href="misEstilos.css">
        <script src="https://unpkg.com/axios@1.3.4/dist/axios.min.js"></script>
        <script src="misScripts.js"></script>
    </head>
    <body onload="obtenerTodos()">
        <div class="titulo">
            <h1>Cell-Land</h1>
            <img src="logo.png" alt="Icono">
        </div>
         <hr class="linea"/>
      <div>
          <h2>Administración de productos</h2>
          <table>
              <thead>
                  <tr>
                      <th>ID</th>
                      <th>Nombre</th>
                      <th>Modelo</th>
                      <th>Color</th>
                      <th>Almacenamiento</th>
                      <th>Procesador</th>
                  </tr>
              </thead>    
              <tbody id="tblContenido">
              </tbody>
          </table>
      </div>
      <div>
          <div>
              <h4>Consultar artículo</h4>
              <input type="numer" id="txtConsulta" placeholder="Ingrese su ID">
              <button onclick="consultarUno()">Consultar</button><br/><br/>
          </div>
          <div>
              <label for="consultaNombre">Nombre:</label>
              <textarea id="consultaNombre" rows="1" cols="30"></textarea>
          </div>
          <div>
              <label for="consultaModelo">Modelo:</label>
              <textarea id="consultaModelo" rows="1" cols="30"></textarea>
          </div>
          <div>
              <label for="consultaColor">Color:</label>
              <textarea id="consultaColor" rows="1" cols="30"></textarea>
          </div>
          <div>
              <label for="consultaAlmacenamiento">Almacenamiento:</label>
              <textarea id="consultaAlmacenamiento" rows="1" cols="30"></textarea>
          </div>
          <div>
              <label for="consultaProcesador">Procesador:</label>
              <textarea id="consultaProcesador" rows="1" cols="30"></textarea>
          </div><br/>
          <button onclick="modificarUno()">Modificar</button>
          <button onclick="eliminarUno()">Eliminar</button>
      </div>
      <div>
          <div>
              <h4>Agregar artículo</h4>
              <input type="text" id="inputMarca" placeholder="Marca">
              <input type="text" id="inputModelo" placeholder="Modelo">
              <input type="text" id="inputColor" placeholder="Color">
              <input type="text" id="inputAlmacenamiento" placeholder="Almacenamiento (GB)">
              <input type="text" id="inputProcesador" placeholder="Procesador"><br/><br/>
              <button onclick="agregarUno()">Agregar Nuevo</button>
          </div>
      </div>
    </body>
    </html>' > /var/www/html/myapp/index.html
      echo 'body {
    width: 80%;
    margin: 0 auto;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #D0D977;
}

.titulo {
    display: flex;
    justify-content: center;
}

h1 {
    position: absolute;
    margin-top: 12px;
    border: 1px solid #ddd;
    border-radius: 10px;
    padding: 5px;
    background-color: #FFFFE0;
    box-shadow: 0 2px 2px rgba(0, 0, 0, 0.1);
    text-align: center;
}

img {
    position: relative;
    width: 100px;
    margin-left: 220px;
}

.linea {
    margin-top: -1px;
    border-color: black;
}

h2 {
    text-align: center;
}

h4 {
    font-size: 18px;
    text-decoration: underline;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 10px 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 8px; 
    text-align: left;
}

th {
    background-color: darkolivegreen;
    font-weight: bold;
    text-align: center;
    color: white;
}

td {
    background-color: #FFFFE0;
}

input {
    background-color: #FFFFE0;
    padding: 10px 10px;
    font-size: 15px;
    width: 150px;
    border: none;
    border-bottom: solid 1px;
}

button {
    background-color: darkolivegreen;
    color: white;
    height: 35px;
    font-size: 15px;
    width: 170px;
    cursor: pointer;
}

label {
    display: inline-block;
    width: 130px; /* ajusta el ancho según tus necesidades */
    vertical-align: top;
    line-height: 50px;
}

textarea {
    background-color: #f7f7f7;
    border: 1px solid #ccc;
    box-shadow: 1px 1px 2px #ccc;
    cursor: text;
    font-family: inherit;
    font-size: 100%;
    padding: 8px;
    resize: none;
    text-align: left;
    height: 30px;
}
' > /var/www/html/myapp/misEstilos.css
chown -R apache:apache /var/www/html/myapp
chmod -R 755 /var/www/html/myapp
chmod -R 777 /var/www/
systemctl restart httpd
EOF
}