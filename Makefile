build:
	docker build -t tylerfowler/superset:0.22.1 .

run:
	docker run -d --name superset -p 8088:8088 tylerfowler/superset
	echo "Superset now running at http://localhost:8088"

stop:
	docker stop superset
