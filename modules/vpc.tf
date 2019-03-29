resource "aws_vpc" "dev-vpc" {
	cidr_block = "10.0.0.0/16"
	instance_tenancy = "default"
	
	tags {
		Name = "dev-vpc"
	}
}

resource "aws_internet_gateway" "dev-igw" {
        vpc_id = "${aws_vpc.dev-vpc.id}"

        tags {
                Name = "dev-igw"
        }
}

resource "aws_subnet" "dev-sn-pri" {
	vpc_id = "${aws_vpc.dev-vpc.id}"
	cidr_block = "10.0.1.0/24"
	availability_zone = "eu-west-1a"
	
	tags {
		Name = "dev-sn-pri"
		Type = "private"
	}
}

resource "aws_subnet" "dev-sn-pub" {
	vpc_id = "${aws_vpc.dev-vpc.id}"
	cidr_block = "10.0.2.0/24"
	availability_zone = "eu-west-1b"
	map_public_ip_on_launch = "true"

	tags {
		Name = "dev-sn-pub"
		Type = "public"
	}
}

resource "aws_eip" "dev-nat-eip" {
	vpc = "true"
}

resource "aws_nat_gateway" "dev-nat" {
        allocation_id = "${aws_eip.dev-nat-eip.id}"
        subnet_id = "${aws_subnet.dev-sn-pub.id}"
	tags {
		Name = "dev-nat"
	}
}

resource "aws_route_table" "dev-rt-pri" {
	vpc_id = "${aws_vpc.dev-vpc.id}"
        
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_nat_gateway.dev-nat.id}"		
	}
		
	tags {
		Name = "dev-sn-pri"
	}	
}

resource "aws_route_table" "dev-rt-pub" {
	vpc_id = "${aws_vpc.dev-vpc.id}"
	
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.dev-igw.id}"
	}

	tags {
		Name = "dev-rt-pub"
	}
}

resource "aws_route_table_association" "dev-rt-pub-assoc" {
	subnet_id = "${aws_subnet.dev-sn-pub.id}"
	route_table_id = "${aws_route_table.dev-rt-pub.id}"
}

resource "aws_route_table_association" "dev-rt-pri-assoc" {
	subnet_id = "${aws_subnet.dev-sn-pri.id}"
	route_table_id = "${aws_route_table.dev-rt-pri.id}"
}
