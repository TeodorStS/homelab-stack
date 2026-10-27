.PHONY: up down restart status logs

up:
	@echo "Starting all services..."
	cd nginx && docker compose up -d && cd ..
	cd beszel && docker compose up -d && cd ..
	cd homepage && docker compose up -d && cd ..
	cd ittoolkit && docker compose up -d && cd ..
	cd portfolio && docker compose up -d && cd ..
	cd typetest && docker compose up -d && cd ..
	@echo "All services started!"

down:
	@echo "Stopping all services..."
	cd nginx && docker compose down && cd ..
	cd typetest && docker compose down && cd ..
	cd portfolio && docker compose down && cd ..
	cd ittoolkit && docker compose down && cd ..
	cd homepage && docker compose down && cd ..
	cd beszel && docker compose down && cd ..
	@echo "All services stopped!"

status:
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

logs:
	@docker compose ls

restart: down up

disk:
	free -h
	df -h /
